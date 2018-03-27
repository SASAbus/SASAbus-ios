import RealmSwift
import ObjectMapper

class BBusStop: Mappable {

    var id = 0
    var family = 0

    var nameDe: String = ""
    var nameIt: String = ""
    var municDe: String = ""
    var municIt: String = ""

    var lat: Float = 0.0
    var lng: Float = 0.0


    required convenience init?(map: Map) {
        self.init()
    }

    convenience init(id: Int, name: String, munic: String, lat: Float, lng: Float, family: Int) {
        self.init()

        self.id = id
        self.family = family
        
        nameDe = name
        nameIt = name
        municDe = munic
        municIt = munic
        
        self.lat = lat
        self.lng = lng
    }

    convenience init(fromRealm: BusStop) {
        self.init()

        self.id = fromRealm.id
        self.family = fromRealm.family
        
        self.nameDe = fromRealm.nameDe!
        self.nameIt = fromRealm.nameIt!
        self.municDe = fromRealm.municDe!
        self.municIt = fromRealm.municIt!
        
        self.lat = fromRealm.lat
        self.lng = fromRealm.lng
    }


    func name(locale: String = Locales.get()) -> String {
        return locale == "de" ? nameDe : nameIt
    }

    func munic(locale: String = Locales.get()) -> String {
        return locale == "de" ? municDe : municIt
    }


    func mapping(map: Map) {
        id <- map["id"]
        family <- map["family"]
        
        nameDe <- map["nameDe"]
        nameIt <- map["nameIt"]
        municDe <- map["municDe"]
        municIt <- map["municIt"]
        
        lat <- map["lat"]
        lng <- map["lng"]
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
