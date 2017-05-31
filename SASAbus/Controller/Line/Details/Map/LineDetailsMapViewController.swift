import UIKit
import MapKit
import SwiftyJSON
import RxCocoa
import RxSwift

class LineDetailsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var lineId: Int = 0


    init(lineId: Int) {
        self.lineId = lineId

        super.init(nibName: "LineDetailsMapViewController", bundle: nil)
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

        mapView.setRegion(MapUtils.getRegion(), animated: false)

        parseData()
    }

    func parseData() {
        _ = PathsApi.getPath(line: lineId)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { path in
                    var points = [CLLocationCoordinate2D]()

                    for item in path {
                        let busStop = BusStopRealmHelper.getBusStop(id: item)

                        let title = busStop.name()
                        let munic = busStop.munic()

                        let coordinate = CLLocationCoordinate2D(latitude: Double(busStop.lat), longitude: Double(busStop.lng))

                        self.mapView.addAnnotation(BusStopAnnotation(
                                title: title,
                                subtitle: munic,
                                coordinate: coordinate,
                                busStop: busStop
                        ))

                        points.append(coordinate)
                    }

                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)

                    if !points.isEmpty {
                        let polyLine = MKGeodesicPolyline(coordinates: UnsafeMutablePointer(mutating: points), count: points.count)
                        self.mapView.add(polyLine)
                    }
                }, onError: { error in
                    Log.error("Could not load path for line \(self.lineId): \(error)")
                })

    }
}

extension LineDetailsMapViewController {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let busStopAnnotation = annotation as! BusStopAnnotation

        let pinView = MKPinAnnotationView()
        pinView.annotation = busStopAnnotation
        pinView.canShowCallout = true
        pinView.pinTintColor = busStopAnnotation.color

        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton

        return pinView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 2

            return polylineRenderer
        }

        return MKOverlayRenderer()
    }
}
