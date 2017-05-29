import RealmSwift
import ObjectMapper

class BBusStop {

    var id = 0
    var family = 0

    var nameDe: String?
    var nameIt: String?
    var municDe: String?
    var municIt: String?

    var lat: Float = 0.0
    var lng: Float = 0.0

    init(id: Int, name: String, munic: String, lat: Float, lng: Float, family: Int) {
        self.id = id
        nameDe = name
        nameIt = name
        municDe = munic
        municIt = munic
        self.lat = lat
        self.lng = lng
        self.family = family
    }

    init(fromRealm: BusStop) {
        id = fromRealm.id
        nameDe = fromRealm.nameDe
        nameIt = fromRealm.nameIt
        municDe = fromRealm.municDe
        municIt = fromRealm.municIt
        lat = fromRealm.lat
        lng = fromRealm.lng
        family = fromRealm.family
    }

    func name(locale: String = Utils.locale()) -> String {
        return (locale == "de" ? nameDe : nameIt)!
    }

    func munic(locale: String = Utils.locale()) -> String {
        return (locale == "de" ? municDe : municIt)!
    }
}

extension BBusStop: Hashable {

    var hashValue: Int {
        return family
    }

    public static func ==(lhs: BBusStop, rhs: BBusStop) -> Bool {
        return lhs.family == rhs.family
    }
}
