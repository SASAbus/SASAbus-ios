import UIKit

import RxSwift
import RxCocoa

import Realm
import RealmSwift

class LineCourseViewController: UIViewController {

    @IBOutlet weak var containerList: UIView!
    @IBOutlet weak var containerMap: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentedBackground: UIView!

    var hairLineImage: UIImageView!

    var vehicle: Int = 0
    var lineId: Int = 0
    var tripId: Int = 0

    var currentBusStop: Int = 0
    var busStopGroup: Int = 0

    var tempBusStop: Int = 0

    var listController: LineCourseListViewController!
    var mapController: LineCourseMapViewController!


    init(tripId: Int, lineId: Int, vehicle: Int, currentBusStop: Int, busStopGroup: Int) {
        self.tripId = tripId
        self.lineId = lineId
        self.vehicle = vehicle
        self.currentBusStop = currentBusStop
        self.busStopGroup = busStopGroup

        super.init(nibName: "LineCourseViewController", bundle: nil)

        title = "Line course"
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedBackground.backgroundColor = Color.materialTeal500

        for parent in navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if childView is UIImageView && childView.bounds.height <= 1 {
                    hairLineImage = childView as! UIImageView
                    break
                }
            }
        }

        prepareListViewController()
        prepareMapViewController()

        parseData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialTeal500
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }

        hairLineImage.alpha = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialOrange500
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }

        hairLineImage.alpha = 1
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        listController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerList.frame.width, height: containerList.frame.height)
        )

        mapController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerMap.frame.width, height: containerMap.frame.height)
        )
    }


    func prepareListViewController() {
        listController = LineCourseListViewController(parent: self, lineId: lineId, vehicle: vehicle)
        let view = listController.view!

        view.translatesAutoresizingMaskIntoConstraints = true

        containerList.addSubview(view)
        self.addChildViewController(listController)

        self.view.setNeedsLayout()
        view.setNeedsLayout()
    }

    func prepareMapViewController() {
        mapController = LineCourseMapViewController(lineId: lineId)
        let view = mapController.view!

        view.translatesAutoresizingMaskIntoConstraints = true

        containerMap.addSubview(view)
        self.addChildViewController(mapController)

        self.view.setNeedsLayout()
        view.setNeedsLayout()
    }


    // MARK: - Data loading

    func parseData() {
        parseFromPlanData(vehicle: vehicle, busStopGroup: busStopGroup, currentBusStop: currentBusStop, tripId: tripId)
                .subscribeOn(MainScheduler.background)
                .map(passingLinesMap)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { items in
                    self.listController.onSuccess(items: items)
                    self.mapController.onSuccess(items: items)
                }, onError: { error in
                    self.listController.onError(error: error as NSError)
                    self.mapController.onError(error: error as NSError)
                })
    }

    private func parseFromPlanData(vehicle: Int, busStopGroup: Int, currentBusStop: Int, tripId: Int) -> Observable<[LineCourse]> {
        return Observable.create { subscriber in
            var currentBusStopNew = currentBusStop

            guard Api2.todayExists() else {
                PlannedData.setUpdateAvailable(true)
                subscriber.on(.error(NSError(domain: "com.davale.sasabus", code: 0, userInfo: [:])))
                return Disposables.create()
            }

            if (vehicle != 0) {
                Log.warning("Getting bus position for \(vehicle)")

                RealtimeApi.vehicle(vehicle: vehicle)
                        .subscribe(onNext: { bus in
                            guard let bus = bus else {
                                Log.warning("Bus \(vehicle) is not in service")
                                return
                            }

                            currentBusStopNew = bus.busStop

                            Log.warning("Got bus position for \(vehicle): \(currentBusStopNew)")
                        }, onError: { error in
                            Log.warning("Could not get bus position: \(error)")
                        })
            }

            var items = [LineCourse]()
            var path: [VdvBusStop] = Api2.getTrip(tripId: tripId).calcTimedPath()

            var realm = Realm.busStops()

            var active = currentBusStopNew == 0

            for stop in path {
                var busStop = BBusStop(fromRealm: BusStopRealmHelper.getBusStop(id: stop.id, realm: realm))

                var bus = false
                var pin = false

                // Iterate all times to see at which bus stop the bus currently is, and mark it
                // to make it stand out in the list (by either a dot or a bus depending if it
                // currently is in service).

                if (busStop.id == currentBusStopNew) {
                    active = true
                    bus = true
                }

                if (busStop.family == busStopGroup) {
                    pin = true
                }

                items.append(LineCourse(
                        id: stop.id,
                        busStop: busStop,
                        time: stop.time,
                        active: active,
                        pin: pin,
                        bus: bus
                ))
            }

            subscriber.on(.next(items))
            subscriber.onCompleted()

            return Disposables.create()
        }
    }


    // MARK: - Click handlers

    @IBAction func showComponent(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.containerList.alpha = 1
            self.containerMap.alpha = 0
        } else {
            self.containerList.alpha = 0
            self.containerMap.alpha = 1
        }
    }


    // MARK: - RxSwift

    func passingLinesMap(lineCourses: [LineCourse]) -> [LineCourse] {
        for lineCourse in lineCourses {
            let family = BusStopRealmHelper.getBusStopGroup(id: lineCourse.id)

            let passingLines: [Int] = Api2.getPassingLines(group: family)

            var lines = ""

            for line in passingLines {
                let lineName = Lines.lidToName(id: line)
                let coloredLineName = getColoredString(text: lineName, color: "#" + Lines.getColorForId(id: line))
                lines += "\(coloredLineName), "
            }

            if lines.characters.count > 2 {
                lines = String(lines.characters.dropLast())
                lines = String(lines.characters.dropLast())
            }

            lines = Lines.lines(name: lines)

            let data = lines.data(using: String.Encoding.utf8)!
            let attributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]

            do {
                let attributedString = try NSAttributedString(data: data, options: attributes, documentAttributes: nil)

                let fullRange = NSRange(location: 0, length: attributedString.length)
                let mutableAttributeText = NSMutableAttributedString(attributedString: attributedString)

                attributedString.enumerateAttribute(
                        NSFontAttributeName,
                        in: fullRange,
                        options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) {

                    (attribute: Any?, range: NSRange, _: UnsafeMutablePointer<ObjCBool>) -> Void in

                    if attribute is UIFont {
                        let scaledFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                        mutableAttributeText.addAttribute(NSFontAttributeName, value: scaledFont, range: range)
                    }
                }

                lineCourse.lineText = mutableAttributeText
            } catch {
                Log.error("Could not format string")
            }
        }

        return lineCourses
    }

    func getColoredString(text: String, color: String) -> String {
        return "<font color=\"\(color)\">\(text)</font>"
    }
}
