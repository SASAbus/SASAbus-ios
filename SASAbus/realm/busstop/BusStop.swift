import RealmSwift

class BusStop: Object {

    dynamic var id = 0
    dynamic var family = 0

    dynamic var nameDe: String?
    dynamic var nameIt: String?
    dynamic var municDe: String?
    dynamic var municIt: String?

    dynamic var lat: Float = 0.0
    dynamic var lng: Float = 0.0

    convenience init(id: Int, name: String, munic: String, lat: Float, lng: Float, family: Int) {
        self.init()

        self.id = id
        nameDe = name
        nameIt = name
        municDe = munic
        municIt = munic
        self.lat = lat
        self.lng = lng
        self.family = family
    }

    override var hashValue: Int {
        return family
    }

    func name(locale: String) -> String {
        return (locale == "de" ? nameDe : nameIt)!
    }

    func munic(locale: String) -> String {
        return (locale == "de" ? municDe : municIt)!
    }

    override func isEqual(_ object: Any?) -> Bool {
        return (object as! BusStop).family == self.family
    }
}
