import Foundation

public class Serializable: NSObject {

    private class SortedDictionary: NSMutableDictionary {

        var dict = [String: AnyObject]()

        override var count: Int {
            return dict.count
        }

        override func keyEnumerator() -> NSEnumerator {
            let sortedKeys: NSArray = NSArray(objects: dict.keys)
            return sortedKeys.objectEnumerator()
        }

        func setValue(value: AnyObject?, forKey key: String) {
            dict[key] = value
        }

        func objectForKey(aKey: AnyObject) -> AnyObject? {
            if let key = aKey as? String {
                return dict[key]
            }

            return nil
        }
    }

    convenience init(json: String) {
        self.init()

        if let jsonData = json.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                let data = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]

                // Loop
                for (key, value) in data {
                    let keyName = key as String
                    let keyValue: String = value as! String

                    // If property exists
                    if self.responds(to: NSSelectorFromString(keyName)) {
                        self.setValue(keyValue, forKey: keyName)
                    }
                }
            } catch let error {
                Log.error("Failed to load: \(error)")
            }
        } else {
            Log.error("json is of wrong format!")
        }
    }

    public func formatKey(key: String) -> String {
        return key
    }

    public func formatValue(value: AnyObject?, forKey: String) -> AnyObject? {
        return value
    }

    func setValue(dictionary: NSDictionary, value: AnyObject?, forKey: String) {
        dictionary.setValue(formatValue(value: value, forKey: forKey), forKey: formatKey(key: forKey))
    }

    public func toDictionary() -> NSDictionary {
        let propertiesDictionary = SortedDictionary()
        let mirror = Mirror(reflecting: self)


        for (propName, propValue) in mirror.children {
            let propValue = self.unwrap(any: propValue) as? AnyObject

            if let propName = propName {
                if let serializablePropValue = propValue as? Serializable {
                    setValue(dictionary: propertiesDictionary, value: serializablePropValue.toDictionary(), forKey: propName)
                } else if let arrayPropValue = propValue as? [Serializable] {
                    let subArray = arrayPropValue.toNSDictionaryArray()
                    setValue(dictionary: propertiesDictionary, value: subArray as AnyObject?, forKey: propName)
                } else if propValue is Int || propValue is Double || propValue is Float || propValue is Bool {
                    setValue(dictionary: propertiesDictionary, value: propValue, forKey: propName)
                } else if let dataPropValue = propValue as? NSData {
                    setValue(dictionary: propertiesDictionary,
                             value: dataPropValue.base64EncodedString(options: .lineLength64Characters) as AnyObject?, forKey: propName)
                } else if let datePropValue = propValue as? NSDate {
                    setValue(dictionary: propertiesDictionary, value: datePropValue.timeIntervalSince1970 as AnyObject?, forKey: propName)
                } else if let propValue: Int8 = propValue as? Int8 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: Int16 = propValue as? Int16 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: Int32 = propValue as? Int32 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: Int64 = propValue as? Int64 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: UInt8 = propValue as? UInt8 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: UInt16 = propValue as? UInt16 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: UInt32 = propValue as? UInt32 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if let propValue: UInt64 = propValue as? UInt64 {
                    setValue(dictionary: propertiesDictionary, value: NSNumber(value: propValue), forKey: propName)
                } else if isEnum(any: propValue) {
                    setValue(dictionary: propertiesDictionary, value: propValue as AnyObject?, forKey: propName)
                }
            }
        }

        return propertiesDictionary
    }

    public func toJson(prettyPrinted: Bool = false) -> Data? {
        let dictionary = self.toDictionary()

        if JSONSerialization.isValidJSONObject(dictionary) {
            do {
                let options = (prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions())
                return try JSONSerialization.data(withJSONObject: dictionary, options: options)
            } catch let error as NSError {
                Log.error("ERROR: Unable to serialize json, error: \(error)")
            }
        }

        return nil
    }

    public func toJsonString(prettyPrinted: Bool = false) -> String? {
        if let jsonData = self.toJson(prettyPrinted: prettyPrinted) {
            return NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as String?
        }

        return nil
    }

    func unwrap(any: Any) -> Any? {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }

        if mi.children.count == 0 { return nil }
        let (_, some) = mi.children.first!
        return some
    }

    func isEnum(any: Any) -> Bool {
        return Mirror(reflecting: any).displayStyle == .enum
    }
}
