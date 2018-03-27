import Foundation
import SwiftyBeaver

class CrashlyticsLogTree: LogTree {
    
    override func log(level: SwiftyBeaver.Level, message: String) {
        if level.rawValue >= SwiftyBeaver.Level.info.rawValue {
            CLSLogv("%@", getVaList([message]))
        }
    }
}
