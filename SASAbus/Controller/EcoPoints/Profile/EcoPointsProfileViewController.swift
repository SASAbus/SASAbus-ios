
import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift
import CoreLocation

class EcoPointsProfileViewController: UITableViewController {

    var parentVC: EcoPointsViewController!

    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var pointsImage: UIImageView!
    @IBOutlet weak var rankImage: UIImageView!
    @IBOutlet weak var badgesImage: UIImageView!

    @IBOutlet weak var pointsText: UILabel!
    @IBOutlet weak var rankText: UILabel!
    @IBOutlet weak var badgesText: UILabel!

    var profile: Profile?
    var showStatistics: Bool = false

    var distance: Double = 0
    var emissions: Double = 0
    var money: Double = 0
    var trips = 0


    init() {
        super.init(nibName: "EcoPointsProfileViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "EcoPointsProfileCell", bundle: nil), forCellReuseIdentifier: "eco_points_profile_header")
        tableView.register(UINib(nibName: "EcoPointsStatsCell", bundle: nil), forCellReuseIdentifier: "eco_points_stats")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0

        initRefreshControl()

        parseProfile()
        parseStatistics()
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "Statistics"
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return showStatistics ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eco_points_profile_header") as! EcoPointsProfileCell

            if let profile = self.profile {
                cell.nameText.text = profile.username
                cell.levelText.text = profile.cls

                cell.pointsText.text = "\(profile.points)"
                cell.badgesText.text = "\(profile.badges)"
                cell.rankText.text = "\(profile.rank)"

                let profileId: Int = (self.profile?.profile)!
                let url = URL(string: Endpoint.API + Endpoint.ECO_POINTS_PROFILE_PICTURE_USER + String(profileId))!
                cell.profilePicture.kf.setImage(with: url)

                cell.loadingView.alpha = 0
            } else {
                cell.loadingView.alpha = 1
            }

            cell.onButtonTapped = {
                print("Click")
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eco_points_stats") as! EcoPointsStatsCell

            if distance < 1000 {
                cell.distanceText.text = "\(distance) m"
            } else {
                let rounded = Utils.roundToPlaces((distance / 1000), places: 2)
                cell.distanceText.text = String(describing: rounded).replacingOccurrences(of: ".", with: ",") + " km"
            }

            let roundedEmissions = emissions
            let roundedMoney = Utils.roundToPlaces(money, places: 2)

            cell.totalTripsText.text = "\(trips)"
            cell.co2Text.text = "\(roundedEmissions) g"
            cell.moneyText.text = "\(roundedMoney) €"

            return cell
        }
    }


    func parseProfile() {
        if !NetUtils.isOnline() {
            Log.error("Device offline")
            return
        }

        _ = EcoPointsApi.getProfile()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { profile in
                    if let profile = profile {
                        self.profile = profile
                    } else {
                        Log.warning("No profile loaded")
                    }

                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }, onError: { error in
                    Log.error("Couldn't load profile: \(error)")
                })
    }

    func parseStatistics() {
        _ = Observable.create { _ in
                    let realm = try! Realm()
                    let trips = realm.objects(Trip.self)

                    if trips.count == 0 {
                        return Disposables.create()
                    }

                    for trip: Trip in trips {
                        var tripDistance: Double = 0
                        var tripEmission: Double = 0
                        var tripMoney: Double = 0

                        // Calculate driven distance
                        let tripList = trip.path!.components(separatedBy: Config.DELIMITER)

                        var busStops = tripList.map {
                            BusStopRealmHelper.getBusStop(id: Int($0) ?? -1 )
                        }

                        var i = 0
                        let busStopsSize = busStops.count

                        while i < busStopsSize {
                            let busStop = busStops[i]

                            if i < busStopsSize - 1 {
                                let next = busStops[i + 1]

                                let start = CLLocation(latitude: Double(busStop.lat), longitude: Double(busStop.lng))
                                let stop = CLLocation(latitude: Double(next.lat), longitude: Double(next.lng))

                                tripDistance += start.distance(from: stop)
                            }

                            i += 1
                        }

                        // Calculate CO2 emissions and price
                        let bus = Buses.getBus(id: trip.vehicle)
                        let vehicle = bus?.vehicle

                        if let vehicle = vehicle {
                            let co2 = Double(vehicle.emission) * tripDistance / 1000
                            let co2Car = 120 * tripDistance / 1000
                            let fuelOffset = co2Car - co2

                            let fuelConsumption = 0.119
                            let fuelPrice = fuelConsumption * tripDistance / 1000.0 * Double(trip.fuelPrice)

                            tripEmission += fuelOffset
                            tripMoney += fuelPrice
                        }

                        self.distance += tripDistance
                        self.emissions += tripEmission
                        self.money += tripMoney

                        self.trips += 1
                    }

                    self.showStatistics = true

                    return Disposables.create()
                }
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {
                    self.tableView.reloadData()
                }, onError: { error in
                    Log.error("Could not compute trip statistics: \(error)")
                })
    }


    func initRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])
        refreshControl.addTarget(self, action: #selector(EcoPointsProfileViewController.parseProfile), for: UIControlEvents.valueChanged)

        self.refreshControl = refreshControl
    }

    func goToSettings() {
        let settingsViewController = EcoPointsSettingsViewController()
        self.navigationController!.pushViewController(settingsViewController, animated: true)
    }


    func buttonClicked(sender: UIButton!) {
        print("Button tapped")
    }
}
