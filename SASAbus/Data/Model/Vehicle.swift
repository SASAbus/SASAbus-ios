import ChameleonFramework
import UIKit

class Vehicle {

    let FUEL_IT = [
        "Idrogeno",
        "Diesel",
        "Metano"
    ]

    let FUEL_DE = [
        "Wasserstoff",
        "Diesel",
        "Methan"
    ]

    let FUEL_EN = [
        "Hydrogen",
        "Diesel",
        "Methane"
    ]

    let COLOR_IT = [
        "Bianco e viola",
        "Giallo",
        "Arancione"
    ]

    let COLOR_DE = [
        "Weiß und violett",
        "Gelb",
        "Orange"
    ]

    let COLOR_EN = [
        "White and purple",
        "Yellow",
        "Orange"
    ]

    let COLOR = [
        FlatBlue(),
        FlatYellow(),
        FlatOrange()
    ]

    let manufacturer: String
    let model: String
    let fuel: Int
    let color: Int
    let emission: Int
    let code: String

    init(manufacturer: String, model: String, fuel: Int, color: Int, emission: Int, code: String) {
        self.manufacturer = manufacturer
        self.model = model
        self.fuel = fuel
        self.color = color
        self.emission = emission
        self.code = code
    }

    func getFuelString() -> String {
        switch Utils.locale() {
            case "it":
                return FUEL_IT[fuel]
            case "de":
                return FUEL_DE[fuel]
            default:
                return FUEL_EN[fuel]
        }
    }

    func getColorString() -> String {
        switch Utils.locale() {
            case "it":
                return COLOR_IT[color]
            case "de":
                return COLOR_DE[color]
            default:
                return COLOR_EN[color]
        }
    }

    func getColor() -> UIColor {
        return COLOR[color]
    }
}
