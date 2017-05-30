import Foundation

class LineDetail {
    
    var currentStation: String?
    var delay: Int!
    var lastStation: String?
    var lastTime: String?
    var additionalData: String?
    var vehicle: Int
    var color: Bool
    
    init(currentStation: String?, delay: Int, lastStation: String?, lastTime: String?,
         additionalData: String?, vehicle: Int, color: Bool) {
        
        self.currentStation = currentStation
        self.delay = delay
        self.lastStation = lastStation
        self.lastTime = lastTime
        self.additionalData = additionalData
        self.vehicle = vehicle
        self.color = color
    }
}
