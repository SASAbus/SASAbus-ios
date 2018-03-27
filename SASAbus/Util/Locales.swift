import Foundation

class Locales {
    
    static func get() -> String {
        let fullLocale: String = Locale.preferredLanguages.first! as String
        return String(fullLocale.prefix(2))
    }
    
    static func getDeIt() -> String {
        let fullLocale: String = Locale.preferredLanguages.first! as String
        let shortLocale = String(fullLocale.prefix(2))
        
        return shortLocale == "de" ? "de" : "it"
    }
}
