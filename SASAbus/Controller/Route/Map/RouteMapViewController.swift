import UIKit
import MapKit
import SwiftyJSON
import RxSwift
import RxCocoa
import Pulley

class RouteMapViewController: UIViewController, MKMapViewDelegate, PulleyPrimaryContentControllerDelegate {

    @IBOutlet var mapView: MKMapView!

    var parentVC: MainRouteViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapType = MapUtils.getMapType()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Map position needs to be set here because in viewDidLoad() the true map bounds
        // have not yet been calculated, because pulley modifies the view bounds.
        mapView.setRegion(MapUtils.getRegion(), animated: false)
    }
}
