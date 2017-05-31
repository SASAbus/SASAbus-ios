import Foundation

class LineCourse {

    let id: Int

    let busStop: BusStop
    let time: String

    let active: Bool
    let dot: Bool

    var lineText: NSAttributedString? = nil

    init(id: Int, busStop: BusStop, time: String, active: Bool, dot: Bool) {
        self.id = id
        self.busStop = busStop
        self.time = time
        self.active = active
        self.dot = dot
    }
}
