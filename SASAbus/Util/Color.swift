import Foundation
import UIKit

class Color {
    
    // MARK: - Apple Colors
    
    static let red: UIColor = UIColor(red: 1, green: 59 / 255, blue: 48 / 255, alpha: 1)
    static let orange: UIColor = UIColor(red: 1, green: 149 / 255, blue: 0, alpha: 1)
    static let yellow: UIColor = UIColor(red: 1, green: 204 / 255, blue: 0, alpha: 1)
    static let green: UIColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    static let tealBlue: UIColor = UIColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1)
    static let blue: UIColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
    static let purple: UIColor = UIColor(red: 88 / 255, green: 86 / 255, blue: 214 / 255, alpha: 1)
    static let pink: UIColor = UIColor(red: 1, green: 45 / 255, blue: 85 / 255, alpha: 1)
    
    // MARK: - Material Colors
    
    static let materialIndigo500: UIColor = UIColor(red: 0.247, green: 0.318, blue: 0.71, alpha: 1)
    static let materialOrange500: UIColor = UIColor(red: 1, green: 0.596, blue: 0, alpha: 1)
    static let materialGreen500: UIColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1)
    static let materialBlue500: UIColor = UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1)
    static let materialAmber500: UIColor = UIColor(red: 1, green: 0.757, blue: 0.027, alpha: 1)
    static let materialTeal500: UIColor = UIColor(red: 0, green: 0.588, blue: 0.533, alpha: 1)
    static let materialRed500: UIColor = UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1)
    
    static let materialGrey500: UIColor = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1)
    static let materialGrey600: UIColor = UIColor(red: 0.459, green: 0.459, blue: 0.459, alpha: 1)
    
    // MARK: - Various colors
    
    static let textPrimary = UIColor.black
    static let textSecondary = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
    
    static let lightWhite: UIColor = UIColor(red: 235, green: 235, blue: 235, alpha: 1)
    static let delayAmber: UIColor = UIColor(red: 1, green: 0.627, blue: 0, alpha: 1)
    static let iconDark = UIColor.darkGray
    static let activeLineBackground = UIColor(red: 0.89, green: 0.949, blue: 0.992, alpha: 1)
    
    static let loginBackground: UIColor = UIColor(red: 0.118, green: 0.137, blue: 0.176, alpha: 1)
    
    
    // MARK: - Color methods
    
    static func color(forDelay: Int) -> UIColor {
        if forDelay > 3 {
            return materialRed500
        } else if forDelay > 0 {
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
}
