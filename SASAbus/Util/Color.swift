import Foundation
import UIKit

class Color {

    static func delay(_ delay: Int) -> UIColor {
        if delay > 3 {
            return Theme.red
        } else if delay > 0 {
            return delayAmber
        } else {
            return materialGreen500
        }
    }

    static func from(rgb: String) -> UIColor {
        var hex = rgb

        if hex.hasPrefix("#") {
            hex = (hex as NSString).substring(from: 1)
        }

        if hex.characters.count != 6 {
            return UIColor.gray
        }

        let rString = (hex as NSString).substring(to: 2)
        let gString = ((hex as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((hex as NSString).substring(from: 4) as NSString).substring(to: 2)

        var r: CUnsignedInt = 0
        var g: CUnsignedInt = 0
        var b: CUnsignedInt = 0

        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)

        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }

    static func getHexColor(_ color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }
}

extension Color {

    // MARK: - Apple Colors

    static let red = UIColor(red: 1, green: 59 / 255, blue: 48 / 255, alpha: 1)
    static let orange = UIColor(red: 1, green: 149 / 255, blue: 0, alpha: 1)
    static let yellow = UIColor(red: 1, green: 204 / 255, blue: 0, alpha: 1)
    static let green = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    static let tealBlue = UIColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1)
    static let blue = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
    static let purple = UIColor(red: 88 / 255, green: 86 / 255, blue: 214 / 255, alpha: 1)
    static let pink = UIColor(red: 1, green: 45 / 255, blue: 85 / 255, alpha: 1)

    
    // MARK: - Material Colors

    static let materialGreen500 = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1)
    static let materialBlue500 = UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1)
    static let materialAmber500 = UIColor(red: 1, green: 0.757, blue: 0.027, alpha: 1)
    static let materialTeal500 = UIColor(red: 0, green: 0.588, blue: 0.533, alpha: 1)

    static let materialGrey500 = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1)
    static let materialGrey600 = UIColor(red: 0.459, green: 0.459, blue: 0.459, alpha: 1)

    
    // MARK: - Various colors

    static let textPrimary = UIColor.black
    static let textSecondary = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)

    static let lightWhite = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    static let delayAmber = UIColor(red: 1, green: 0.627, blue: 0, alpha: 1)
    static let iconDark = UIColor.darkGray
    static let activeLineBackground = UIColor(red: 0.89, green: 0.949, blue: 0.992, alpha: 1)

    static let loginBackground = UIColor(red: 0.118, green: 0.137, blue: 0.176, alpha: 1)

    static let borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    static let routeInputBackground: UIColor = UIColor(red: 0.976, green: 0.49, blue: 0, alpha: 1)
}
