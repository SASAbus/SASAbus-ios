import UIKit
import MapKit
import SwiftyJSON
import RxSwift
import RxCocoa
import Pulley

import RealmSwift
import Realm

import MapKit
import Contacts
import LocationPickerViewController

class RouteFeedViewController: UIViewController {

    var parentVC: MainRouteViewController!

    @IBOutlet weak var departureView: UIView!
    @IBOutlet weak var departureText: UILabel!

    @IBOutlet weak var arrivalView: UIView!
    @IBOutlet weak var arrivalText: UILabel!

    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var timeText: UILabel!

    var busStops = [LocationItem]()

    var departureBusStop: Int?
    var arrivalBusStop: Int?


    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.backgroundColor = Theme.orange

        let departureClick = UITapGestureRecognizer(target: self, action: #selector(showDeparturePicker(_:)))
        departureClick.numberOfTapsRequired = 1

        let arrivalClick = UITapGestureRecognizer(target: self, action: #selector(showArrivalPicker(_:)))
        arrivalClick.numberOfTapsRequired = 1

        departureView.addGestureRecognizer(departureClick)
        arrivalView.addGestureRecognizer(arrivalClick)

        // loadBusStops()
    }


    func loadBusStops() {
        let realm = try! Realm(configuration: BusStopRealmHelper.CONFIG)
        let busStops = realm.objects(BusStop.self)

        let mapped = busStops.map { bus -> LocationItem in
            let item = LocationItem(coordinate: (Double(bus.lat), Double(bus.lng)), addressDictionary: [:])
            item.mapItem.name = bus.name()
            item.id = bus.id

            return item
        }

        self.busStops.removeAll()
        self.busStops.append(contentsOf: mapped)
    }

    func calculateRoute() {

    }
}

extension RouteFeedViewController {

    func getLocationPicker() -> LocationPicker {
        let locationPicker = LocationPicker()

        locationPicker.isAllowArbitraryLocation = true

        locationPicker.addBarButtons()
        locationPicker.alternativeLocations = busStops

        return locationPicker
    }

    @IBAction func showDeparturePicker(_ sender: AnyObject) {
        let locationPicker = getLocationPicker()

        locationPicker.pickCompletion = { item in
            self.departureBusStop = item.id

            self.departureText.text = item.mapItem.name
            self.departureText.textColor = .white

            if self.arrivalBusStop != nil {
                self.calculateRoute()
            }
        }

        navigationController!.pushViewController(locationPicker, animated: true)
    }

    @IBAction func showArrivalPicker(_ sender: AnyObject) {
        let locationPicker = getLocationPicker()

        locationPicker.pickCompletion = { item in
            self.arrivalBusStop = item.id

            self.arrivalText.text = item.mapItem.name
            self.arrivalText.textColor = .white

            if self.departureBusStop != nil {
                self.calculateRoute()
            }
        }

        navigationController!.pushViewController(locationPicker, animated: true)
    }
}
