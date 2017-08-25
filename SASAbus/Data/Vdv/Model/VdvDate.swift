import Foundation

class VdvDate: CustomStringConvertible {

    var id: Int
    var date: Date

    init(id: Int, date: Date) {
        self.id = id
        self.date = date
    }

    public var description: String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"

        return "{id=\(id), date=\(format.string(from: date))}"
    }
}
