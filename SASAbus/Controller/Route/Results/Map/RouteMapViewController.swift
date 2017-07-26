import UIKit
import MapKit
import SwiftyJSON
import RxSwift
import RxCocoa

class RouteMapViewController: UIViewController, MKMapViewDelegate, BottomSheetPrimaryContentControllerDelegate {

    @IBOutlet var mapView: MKMapView!

    var parentVC: RouteResultsViewController!
    var items = [RealtimeBus]()

    var markers = [Int: MapAnnotation]()

    var selectedBus: RealtimeBus?


    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapType = MapUtils.getMapType()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
}

extension RouteMapViewController {

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
    }
}