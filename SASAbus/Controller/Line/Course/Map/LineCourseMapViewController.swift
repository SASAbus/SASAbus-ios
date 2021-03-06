import UIKit
import MapKit

class LineCourseMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!

    var parentVC: LineCourseViewController!

    var lineId: Int = 0

    var activePoints = [CLLocationCoordinate2D]()
    var inactivePoints = [CLLocationCoordinate2D]()

    var activePolyLine: MKGeodesicPolyline!
    var inactivePolyLine: MKGeodesicPolyline!


    init(lineId: Int) {
        self.lineId = lineId

        super.init(nibName: "LineCourseMapViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if lineId == 0 {
            fatalError("lineId == 0")
        }

        mapView.delegate = self
        mapView.mapType = MapUtils.getMapType()

        mapView.setRegion(MapUtils.defaultCamera(), animated: false)
    }


    // MARK: - Data loading

    func onSuccess(items: [LineCourse]) {
        var activePoints = [CLLocationCoordinate2D]()
        var inactivePoints = [CLLocationCoordinate2D]()

        let locale = Locales.get()
        
        var wasBus = false

        for item in items {
            let busStop = item.busStop

            let title = locale == "de" ? busStop.nameDe : busStop.nameIt
            let munic = locale == "de" ? busStop.municDe : busStop.municIt

            var color = item.active ? Theme.skyBlue : Color.materialGrey500
            if item.pin {
                color = Theme.red
            }

            let coordinate = CLLocationCoordinate2D(latitude: Double(busStop.lat), longitude: Double(busStop.lng))

            self.mapView.addAnnotation(BusStopAnnotation(
                    title: title,
                    subtitle: munic,
                    coordinate: coordinate,
                    busStop: busStop,
                    color: color
            ))
            
            if item.active {
                activePoints.append(coordinate)
                
                if !wasBus {
                    inactivePoints.append(coordinate)
                    wasBus = true
                }
            } else {
                inactivePoints.append(coordinate)
            }
        }

        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

        if !activePoints.isEmpty {
            activePolyLine = MKGeodesicPolyline(coordinates: UnsafeMutablePointer(mutating: activePoints),
                    count: activePoints.count)
            self.mapView.add(activePolyLine)
        }

        if !inactivePoints.isEmpty {
            inactivePolyLine = MKGeodesicPolyline(coordinates: UnsafeMutablePointer(mutating: inactivePoints),
                    count: inactivePoints.count)
            self.mapView.add(inactivePolyLine)
        }
    }

    func onError(error: NSError) {
        Log.error("onError: \(error)")
    }


    // MARK: - MapView

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let pinView = MKPinAnnotationView()
        pinView.annotation = annotation
        pinView.canShowCallout = true
        pinView.pinTintColor = (annotation as! BusStopAnnotation).color

        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton

        return pinView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlay = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        if overlay == activePolyLine {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = Color.materialBlue500
            polylineRenderer.lineWidth = 2
            
            return polylineRenderer
        } else if overlay == inactivePolyLine {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = Color.materialGrey500
            polylineRenderer.lineWidth = 2
            
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation as? BusStopAnnotation else {
            return
        }

        let viewController = BusStopViewController(busStop: annotation.busStop)
        (UIApplication.shared.delegate as! AppDelegate).navigateTo(viewController)
    }
}
