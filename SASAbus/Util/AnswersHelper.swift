import Foundation

// TODO add Fabric Answers
class AnswersHelper {

    var TYPE_LINE_DETAILS = "LineDetails"

    var TYPE_BUS_DETAILS = "BusDetails"

    var TYPE_INTRO_ECO_POINTS = "IntroEcoPoints"

    var CATEGORY_ROUTE = "Route"

    var CATEGORY_DEPARTURES = "Departures"

    static func logProfileAction(action: String) {
        /*if (!BuildConfig.DEBUG) {
            var event = CustomEvent("EcoPointsProfile")
                    .putCustomAttribute("Category", action)

            Answers.getInstance().logCustom(event)
        }*/
    }

    static func logCustom(category: String, action: String) {
/*        if (!BuildConfig.DEBUG) {
            val event = CustomEvent(category)
                    .putCustomAttribute("Action", action)

            Answers.getInstance().logCustom(event)
        }*/
    }

    static func logSearch(category: String, query: String) {
/*        if (!BuildConfig.DEBUG) {
            val event = SearchEvent()
                    .putCustomAttribute("Category", category)
                    .putQuery(query)

            Answers.getInstance().logSearch(event)
        }*/
    }

    static func logContentView(type: String, id: String) {
/*        if (!BuildConfig.DEBUG) {
            val event = ContentViewEvent()
                    .putContentType(type)
                    .putContentId(id)

            Answers.getInstance().logContentView(event)
        }*/
    }

    static func logLoginSuccess(isGoogleSignIn: Bool) {
        /*if (!BuildConfig.DEBUG) {
            val event = LoginEvent()
                    .putSuccess(true)
                    .putMethod(if (isGoogleSignIn) "Google" else "Default")

        Answers.getInstance().logLogin(event)*/
    }

    static func logLoginError(error: String) {
        /* if (!BuildConfig.DEBUG) {
             val event = LoginEvent()
                     .putSuccess(false)
                     .putCustomAttribute("Error", error)

             Answers.getInstance().logLogin(event)
         }*/
    }

    static func logSignUpSuccess() {
        /*if (!BuildConfig.DEBUG) {
            val event = SignUpEvent()
                    .putSuccess(true)

            Answers.getInstance().logSignUp(event)
        }*/
    }

    static func logSignUpError(error: String) {
/*        if (!BuildConfig.DEBUG) {
            val event = SignUpEvent()
                    .putSuccess(false)
                    .putCustomAttribute("Error", error)

            Answers.getInstance().logSignUp(event)
        }*/
    }
}
