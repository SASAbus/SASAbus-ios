import Foundation

class LineCourse {

    let id: Int

    let busStop: BBusStop
    let time: String

    let active: Bool
    let pin: Bool
    let bus: Bool

    var lineText: NSAttributedString? = nil

    init(id: Int, busStop: BBusStop, time: String, active: Bool, pin: Bool, bus: Bool) {
        self.id = id
        self.busStop = busStop
        self.time = time
        self.active = active
        self.pin = pin
        self.bus = bus
    }
}
