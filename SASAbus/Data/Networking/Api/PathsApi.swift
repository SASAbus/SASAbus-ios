import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import SwiftyJSON

class PathsApi {

    static func getPath(line: Int) -> Observable<[Int]> {
        return RestClient.getJson(Endpoint.PATHS + "\(line)")
                .map { json -> [Int] in
                    var list: [Int] = []

                    for item in json["path"].arrayValue {
                        list.append(item.intValue)
                    }

                    return list
                }
    }
}
