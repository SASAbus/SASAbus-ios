import Foundation

extension Decimal {
    
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}

extension Double {
    
    func roundTo(places: Int) -> Double {
        let factor = pow(10.0, places).doubleValue
        return (self * factor).rounded() / factor
    }
}
