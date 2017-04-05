import RealmSwift
import ObjectMapper

class LocalBusStop: Mappable, Hashable {

    var id = 0
    var family = 0

    var nameDe: String?
    var nameIt: String?
    var municDe: String?
    var municIt: String?

    var lat: Float = 0.0
    var lng: Float = 0.0


    required convenience init?(map: Map) {
        self.init()
    }

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

    convenience init(realm: BusStop) {
        self.init()

        self.id = realm.id
        self.nameDe = realm.nameDe
        self.nameIt = realm.nameIt
        self.municDe = realm.municDe
        self.municIt = realm.municIt
        self.lat = realm.lat
        self.lng = realm.lng
        self.family = realm.family
    }


    func name(locale: String = Utils.locale()) -> String {
        return (locale == "de" ? nameDe : nameIt)!
    }

    func munic(locale: String = Utils.locale()) -> String {
        return (locale == "de" ? municDe : municIt)!
    }

    func mapping(map: Map) {
        id <- map["id"]
        family <- map["family"]
        nameDe <- map["nameDe"]
        nameIt <- map["nameIt"]
        municDe <- map["municIt"]
        lat <- map["lat"]
        lng <- map["lng"]
    }


    var hashValue: Int {
        return family
    }

    public static func ==(lhs: LocalBusStop, rhs: LocalBusStop) -> Bool {
        return lhs.family == rhs.family
    }

}
