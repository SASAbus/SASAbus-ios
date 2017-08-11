import UIKit
import MapKit
import SwiftyJSON
import RxSwift
import RxCocoa

import Realm
import RealmSwift

class MapViewController: UIViewController, MKMapViewDelegate, BottomSheetPrimaryContentControllerDelegate {

    @IBOutlet var mapView: MKMapView!

    var parentVC: MainMapViewController!
    var items = [RealtimeBus]()

    var markers = [Int: MapAnnotation]()

    var selectedBus: RealtimeBus?

    var allMapOverlaysEnabled: Bool = false

    var tileOverlay: BusTileOverlay?

    var tileOverlayRenderer: MKTileOverlayRenderer?


    override func viewDidLoad() {
        super.viewDidLoad()

        allMapOverlaysEnabled = MapUtils.allMapOverlaysEnabled()

        mapView.delegate = self
        mapView.mapType = MapUtils.getMapType()

        if MapUtils.mapOverlaysEnabled() {
            tileOverlay = BusTileOverlay(parent: self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        parseData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Map position needs to be set here because in viewDidLoad() the true map bounds
        // have not yet been calculated, because pulley modifies the view bounds.
        mapView.setRegion(MapUtils.getRegion(), animated: false)
    }


    func openViewController() {
        parentVC.setDrawerPosition(position: .open, animated: true)
    }

    func parseData() {
        if !NetUtils.isOnline() {
            return
        }

        parentVC.activityIndicator?.startAnimating()

        _ = RealtimeApi.get()
                .subscribeOn(MainScheduler.asyncInstance)
                .map { buses in
                    let realm = Realm.busStops()

                    for item in buses {
                        item.busStopString = BusStopRealmHelper.getName(id: item.busStop, realm: realm)
                        item.destinationString = BusStopRealmHelper.getName(id: item.destination, realm: realm)
                    }

                    return buses
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { buses in
                    self.onSuccess(buses: buses)
                }, onError: { error in
                    Log.error(error)

                    self.parentVC.activityIndicator?.stopAnimating()
                })
    }

    func onSuccess(buses: [RealtimeBus]) {
        items.removeAll()
        items.append(contentsOf: buses)

        var updatedMarkers = [Int: MapAnnotation]()

        for item in self.items {
            var annotation: MapAnnotation? = self.markers[item.trip]

            if annotation != nil {
                annotation?.busData = item
                annotation?.title = Lines.line(name: item.lineName)

                UIView.animate(withDuration: 0.25) {
                    var loc = annotation?.coordinate
                    loc?.latitude = item.latitude
                    loc?.longitude = item.longitude
                    annotation?.coordinate = loc!
                }
            } else {
                annotation = MapAnnotation(
                        title: Lines.line(name: item.lineName),
                        coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                        pinColor: Color.from(rgb: item.colorHex),
                        data: item
                )

                self.mapView.addAnnotation(annotation!)
            }

            updatedMarkers[item.trip] = annotation
            self.markers.removeValue(forKey: item.trip)
        }

        for (_, marker) in self.markers {
            self.mapView.removeAnnotation(marker)
        }

        self.markers = updatedMarkers

        for (_, marker) in self.markers where marker.selected {
            let bottomSheet = self.parentVC?.childViewControllers[1] as! MapBottomSheetViewController
            bottomSheet.updateBottomSheet(bus: marker.busData)
        }

        self.parentVC.activityIndicator?.stopAnimating()
    }
}

extension MapViewController {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let marker = annotation as! MapAnnotation

        let annotationView: MKPinAnnotationView = MKPinAnnotationView()
        annotationView.pinTintColor = marker.pinColor
        annotationView.annotation = annotation
        annotationView.canShowCallout = true

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }

        let annotation = view.annotation as! MapAnnotation
        annotation.selected = true

        if tileOverlay != nil {
            mapView.add(tileOverlay!, level: .aboveLabels)
        }

        if tileOverlayRenderer != nil {
            tileOverlayRenderer?.reloadData()
        }

        selectedBus = annotation.busData

        let bottomSheet = parentVC?.childViewControllers[1] as! MapBottomSheetViewController
        bottomSheet.updateBottomSheet(bus: selectedBus!)

        parentVC.setDrawerPosition(position: .partiallyRevealed, animated: true)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }

        let annotation = view.annotation as! MapAnnotation
        annotation.selected = false

        let bottomSheet = parentVC?.childViewControllers[1] as! MapBottomSheetViewController
        bottomSheet.selectedBus = nil

        self.parentVC.setDrawerPosition(position: .collapsed, animated: true)

        if tileOverlay != nil {
            mapView.remove(tileOverlay!)
        }

        if tileOverlayRenderer != nil {
            tileOverlayRenderer?.reloadData()
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer()
        }

        tileOverlayRenderer = MKTileOverlayRenderer(tileOverlay: tileOverlay)
        return tileOverlayRenderer!
    }
}

class BusTileOverlay: MKTileOverlay {

    let cache = NSCache<NSString, NSData>()
    let operationQueue = OperationQueue()

    var parent: MapViewController!

    init(parent: MapViewController) {
        super.init(urlTemplate: "")

        self.parent = parent

        self.tileSize = CGSize(width: 512, height: 512)
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let urlFormatted: String

        if parent.allMapOverlaysEnabled {
            let url = Endpoint.dataApiUrl + Endpoint.MAP_TILES_ALL
            urlFormatted = String(format: url, path.x, path.y, path.z)

        } else {
            let url = Endpoint.dataApiUrl + Endpoint.MAP_TILES
            urlFormatted = String(format: url, path.x, path.y, path.z,
                    parent.selectedBus!.lineId, parent.selectedBus!.variant)
        }

        return URL(string: urlFormatted)!
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Swift.Void) {
        let url = self.url(forTilePath: path)

        if let cachedData = cache.object(forKey: url.absoluteString as NSString) as? Data {
            result(cachedData, nil)
        } else {
            let session = URLSession.shared

            let request = NSURLRequest(url: url)

            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error -> Void in
                if let data = data {
                    self.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                }

                result(data, error)
            })

            task.resume()
        }
    }

    func checkTileExists(zoom: Int) -> Bool {
        let minZoom = 10
        let maxZoom = 16

        if zoom < minZoom || zoom > maxZoom {
            return false
        }

        return parent.allMapOverlaysEnabled || parent.selectedBus != nil
    }
}
