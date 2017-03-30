/*
 Serializes an array to JSON making use of the Serializable class
 */

import Foundation

extension Array where Element: Serializable {

    public func toNSDictionaryArray() -> [NSDictionary] {
        var subArray = [NSDictionary]()
        for item in self {
            subArray.append(item.toDictionary())
        }
        return subArray
    }

    /**
     Converts the array to JSON.
     
     :returns: The array as JSON, wrapped in NSData.
     */
    public func toJson(prettyPrinted: Bool = false) -> Data? {
        let subArray = self.toNSDictionaryArray()

        if JSONSerialization.isValidJSONObject(subArray) {
            do {
                return try JSONSerialization.data(withJSONObject: subArray,
                        options: (prettyPrinted ? .prettyPrinted: JSONSerialization.WritingOptions()))
            } catch let error as NSError {
                Log.error("Unable to serialize json, error: \(error)")
            }
        }

        return nil
    }

    /**
     Converts the array to a JSON string.
     
     :returns: The array as a JSON string.
     */
    public func toJsonString(prettyPrinted: Bool = false) -> String? {
        if let jsonData = toJson(prettyPrinted: prettyPrinted) {
            return NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as String?
        }

        return nil
    }
}
