import UIKit
import MapKit
import SwiftyJSON
import RxSwift
import RxCocoa

import Realm
import RealmSwift

class MapViewController: UIViewController, BottomSheetPrimaryContentControllerDelegate {

    @IBOutlet var mapView: MKMapView!

    var parentVC: MainMapViewController!
    var items = [RealtimeBus]()

    var markers = [Int: MapAnnotation]()

    var selectedBus: RealtimeBus?

    var allMapOverlaysEnabled: Bool = false

    var tileOverlay: BusTileOverlay?

    var tileOverlayRenderer: MKTileOverlayRenderer?

    var autoRefreshTimer: Timer?

    var isRefreshRunning = false


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

        if MapUtils.isAutoRefreshEnabled() {
            let interval = MapUtils.getAutoRefreshInterval()
            Log.info("Auto refresh is enabled, interval: \(interval)s")

            scheduleAutoRefreshTimer(interval: interval)
        }

        parseData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let timer = autoRefreshTimer {
            timer.invalidate()
        }
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
        guard NetUtils.isOnline() else {
            Log.error("No internet connection")
            return
        }

        guard !isRefreshRunning else {
            Log.error("Refresh already running")
            return
        }

        isRefreshRunning = true

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

                    self.isRefreshRunning = false
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

                mapView.addAnnotation(annotation!)
            }

            updatedMarkers[item.trip] = annotation
            markers.removeValue(forKey: item.trip)
        }

        for (_, marker) in markers {
            mapView.removeAnnotation(marker)
        }

        markers = updatedMarkers

        for (_, marker) in markers where marker.selected {
            let bottomSheet = parentVC?.childViewControllers[1] as! MapBottomSheetViewController
            bottomSheet.updateBottomSheet(bus: marker.busData)
        }

        isRefreshRunning = false
        parentVC.activityIndicator?.stopAnimating()
    }


    func scheduleAutoRefreshTimer(interval: TimeInterval) {
        autoRefreshTimer = Timer.scheduledTimer(
                timeInterval: interval,
                target: self,
                selector: #selector(self.parseData),
                userInfo: nil,
                repeats: true
        )
    }
}

extension MapViewController: MKMapViewDelegate {

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

        selectedBus = annotation.busData

        let bottomSheet = parentVC?.childViewControllers[1] as! MapBottomSheetViewController
        bottomSheet.updateBottomSheet(bus: selectedBus!)

        parentVC.setDrawerPosition(position: .partiallyRevealed, animated: true)

        if tileOverlayRenderer != nil {
            tileOverlayRenderer?.reloadData()
        }
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
