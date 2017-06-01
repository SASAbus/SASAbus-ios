import UIKit
import Realm
import RealmSwift

class RouteSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var busStops: [BBusStop] = []

    var realm = Realm.busStops()

    var parentVC: MainRouteViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        updateFoundBusStations("")
    }

    func collapseAndSearch() {
        searchBar.endEditing(true)

        parentVC.setDrawerPosition(position: .collapsed, animated: true, index: drawerIndex())
        parentVC.setDrawerPosition(position: .collapsed, animated: true, index: parentVC.resultsController.drawerIndex())
    }
}


extension RouteSearchViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 206
    }

    func drawerIndex() -> Int {
        return 0
    }

    func initialPosition() -> PulleyPosition {
        return PulleyPosition.collapsed
    }

    func drawerPositionDidChange(drawer: MultiplePulleyViewController) {
        tableView.isScrollEnabled = drawer.drawerPosition[drawerIndex()] == .open

        if drawer.drawerPosition[drawerIndex()] != .open {
            searchBar.resignFirstResponder()
        }
    }
}


extension RouteSearchViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        Log.error("searchBarShouldBeginEditing")

        parentVC.setDrawerPosition(position: .open, animated: true, index: drawerIndex())

        return true
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateFoundBusStations(searchText)
    }

    fileprivate func updateFoundBusStations(_ searchText: String) {
        let found: Results<BusStop>

        if searchText.isEmpty {
            found = realm.objects(BusStop.self)
        } else {
            found = realm.objects(BusStop.self)
                    .filter("nameDe CONTAINS[c] '\(searchText)' OR nameIt CONTAINS[c] '\(searchText)'")
        }

        let mapped = found.map {
            BBusStop(fromRealm: $0)
        }

        let array = Array(Set(mapped))

        busStops = array.sorted(by: {
            $0.name() < $1.name()
        })

        tableView.reloadData()
    }
}

extension RouteSearchViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busStop = busStops[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "lol")

        cell.backgroundColor = UIColor.clear
        cell.textLabel!.text = busStop.name()
        cell.detailTextLabel!.text = busStop.munic()

        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busStops.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collapseAndSearch()
    }
}
