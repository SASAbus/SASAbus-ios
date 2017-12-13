import Foundation

extension Array where Element : Hashable {
    
    func uniques() -> [Element] {
        return Array(Set(self))
    }
}
