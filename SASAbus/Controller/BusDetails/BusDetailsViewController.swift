import UIKit
import ChameleonFramework

class BusDetailsViewController: UIViewController {

    @IBOutlet weak var busImage: UIImageView!

    @IBOutlet weak var manufacturerImage: UIImageView!
    @IBOutlet weak var manufacturerText: UILabel!

    @IBOutlet weak var modelText: UILabel!

    @IBOutlet weak var licensePlateImage: UIImageView!
    @IBOutlet weak var licensePlateText: UILabel!

    @IBOutlet weak var fuelImage: UIImageView!
    @IBOutlet weak var fuelText: UILabel!

    @IBOutlet weak var colorImage: UIImageView!
    @IBOutlet weak var colorText: UILabel!

    @IBOutlet weak var specifications: UILabel!

    var vehicleId: Int


    init(vehicleId: Int) {
        self.vehicleId = vehicleId

        super.init(nibName: "BusDetailsViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        vehicleId = 0
        super.init(coder: aDecoder)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = Theme.orange
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if vehicleId == 0 {
            fatalError("vehicleId == 0")
        }

        parseData()
    }

    func parseData() {
        if let bus = Buses.getBus(id: vehicleId) {
            let vehicle = bus.vehicle

            var color = vehicle.color == 2 ?  FlatOrange() : vehicle.getColor()

            if let navController = self.navigationController {
                navController.navigationBar.barTintColor = color
            }

            manufacturerImage.tint(with: color)
            licensePlateImage.tint(with: color)
            fuelImage.tint(with: color)
            colorImage.tint(with: color)

            specifications.textColor = color

            busImage.image = UIImage(named: vehicle.code)

            manufacturerText.text = vehicle.manufacturer
            modelText.text = vehicle.model
            licensePlateText.text = "\(bus.licensePlate!) #\(vehicleId)"
            fuelText.text = vehicle.getFuelString()
            colorText.text = vehicle.getColorString()

            title = "Bus #\(vehicleId)"
        } else {
            Log.error("Vehicle \(vehicleId) does not exist")
        }
    }
}
