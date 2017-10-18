import SwiftyJSON

extension JSON {

    func to<T>(type: T?) -> Any? {
        if let baseObj = type as? JSONable.Type {
            if self.type == .array {
                var arrObject: [Any] = []

                for obj in self.arrayValue {
                    let object = baseObj.init(parameter: obj)
                    arrObject.append(object)
                }

                return arrObject
            } else {
                return baseObj.init(parameter: self)
            }
        }

        return nil
    }
}

protocol JSONCollection {
    static func collection(parameter: JSON) -> [Self]
}

protocol JSONable {
    init(parameter: JSON)
}

extension Array {
    func find(_ predicate: (Array.Iterator.Element) throws -> Bool) rethrows -> Array.Iterator.Element? {
        return try index(where: predicate).map({ self[$0] })
    }
}
