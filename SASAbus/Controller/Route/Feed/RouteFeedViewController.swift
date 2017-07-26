import UIKit
import MapKit
import SwiftyJSON
import RxSwift
import RxCocoa
import Pulley

class RouteFeedViewController: UIViewController {

    var parentVC: MainRouteViewController!

    @IBOutlet weak var departureView: UIView!
    @IBOutlet weak var departureText: UITextField!
    
    @IBOutlet weak var arrivalView: UIView!
    @IBOutlet weak var arrivalText: UITextField!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.backgroundColor = Theme.orange

        // departureView.backgroundColor = Color.routeInputBackground
        // arrivalView.backgroundColor = Color.routeInputBackground
    }
}
