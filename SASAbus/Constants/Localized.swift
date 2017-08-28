// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {

  enum About {
    /// Privacy policy
    static let privacyPolicy = L10n.tr("Localizable", "about.privacy_policy")
    /// Terms of service
    static let termsOfService = L10n.tr("Localizable", "about.terms_of_service")
    /// About
    static let title = L10n.tr("Localizable", "about.title")
  }

  enum BusDetails {
    /// Color
    static let color = L10n.tr("Localizable", "bus_details.color")
    /// Fuel
    static let fuel = L10n.tr("Localizable", "bus_details.fuel")
    /// License plate
    static let licensePlate = L10n.tr("Localizable", "bus_details.license_plate")
    /// Manufacturer
    static let manufacturer = L10n.tr("Localizable", "bus_details.manufacturer")
    /// Model
    static let model = L10n.tr("Localizable", "bus_details.model")
    /// Specifications
    static let specifications = L10n.tr("Localizable", "bus_details.specifications")
    /// Bus #%d
    static func titleFormatted(_ p1: Int) -> String {
      return L10n.tr("Localizable", "bus_details.title_formatted", p1)
    }
  }

  enum Changelog {
    /// Changelog
    static let title = L10n.tr("Localizable", "changelog.title")
  }

  enum Credits {
    /// © 2015 - 2016 Markus Windegger, Raiffeisen OnLine Gmbh (Norman Marmsoler, Jürgen Sprenger, Aaron Falk)
    static let copyright = L10n.tr("Localizable", "credits.copyright")
    /// SASAbus - %@
    static func header(_ p1: String) -> String {
      return L10n.tr("Localizable", "credits.header", p1)
    }
    /// For suggestions or help please mail to ios@sasabz.it
    static let help = L10n.tr("Localizable", "credits.help")
    /// Credits
    static let title = L10n.tr("Localizable", "credits.title")

    enum Licenses {
      /// • DrawerController (MIT)\r\n• AlamoFire (MIT)\r\n• zipzap (BSD)\r\n• KDCircularProgress (MIT)\r\n• SwiftValidator (MIT)
      static let subtitle = L10n.tr("Localizable", "credits.licenses.subtitle")
      /// The following sets forth attribution notices for third party software that may be contained in portions of the product. We thank the open source community for all their contributions.
      static let title = L10n.tr("Localizable", "credits.licenses.title")
    }
  }

  enum Departures {
    /// Departures
    static let title = L10n.tr("Localizable", "departures.title")

    enum Button {
      /// Cancel
      static let cancel = L10n.tr("Localizable", "departures.button.cancel")
      /// Done
      static let done = L10n.tr("Localizable", "departures.button.done")
    }

    enum Cell {
      /// No data
      static let noData = L10n.tr("Localizable", "departures.cell.no_data")
    }

    enum Favorites {
      /// Select a bus stop from your favorites
      static let header = L10n.tr("Localizable", "departures.favorites.header")
      /// Bus stop favorites
      static let title = L10n.tr("Localizable", "departures.favorites.title")
    }

    enum Gps {
      /// Select a nearby bus stop
      static let header = L10n.tr("Localizable", "departures.gps.header")
      /// Bus stop near your
      static let title = L10n.tr("Localizable", "departures.gps.title")
    }

    enum Header {
      /// Favorites
      static let favorites = L10n.tr("Localizable", "departures.header.favorites")
      /// GPS
      static let gps = L10n.tr("Localizable", "departures.header.gps")
      /// Map
      static let map = L10n.tr("Localizable", "departures.header.map")
    }

    enum Map {
      /// Bus stop map
      static let title = L10n.tr("Localizable", "departures.map.title")
    }
  }

  enum Ecopoints {
    /// Eco points
    static let title = L10n.tr("Localizable", "ecopoints.title")

    enum Badges {
      /// View all badges
      static let viewAll = L10n.tr("Localizable", "ecopoints.badges.view_all")

      enum Section {
        /// Earned badges
        static let earned = L10n.tr("Localizable", "ecopoints.badges.section.earned")
        /// Next badges
        static let next = L10n.tr("Localizable", "ecopoints.badges.section.next")
      }
    }

    enum LeaderBoard {
      /// %d points
      static func points(_ p1: Int) -> String {
        return L10n.tr("Localizable", "ecopoints.leader_board.points", p1)
      }
    }

    enum Login {
      /// Log in
      static let button = L10n.tr("Localizable", "ecopoints.login.button")
      /// By loggin in you agree to our terms of service and privacy policy
      static let footerWarning = L10n.tr("Localizable", "ecopoints.login.footer_warning")
      /// Forgot your password?
      static let forgotPassword = L10n.tr("Localizable", "ecopoints.login.forgot_password")

      enum Email {
        /// john@appleseed.com
        static let placeholder = L10n.tr("Localizable", "ecopoints.login.email.placeholder")
      }

      enum Error {
        /// Please retry in a few minutes
        static let subtitle = L10n.tr("Localizable", "ecopoints.login.error.subtitle")
        /// Could not log in
        static let title = L10n.tr("Localizable", "ecopoints.login.error.title")
      }

      enum Password {
        /// ••••••••
        static let placeholder = L10n.tr("Localizable", "ecopoints.login.password.placeholder")
      }
    }

    enum Profile {
      /// BADGES
      static let badges = L10n.tr("Localizable", "ecopoints.profile.badges")
      /// POINTS
      static let points = L10n.tr("Localizable", "ecopoints.profile.points")
      /// RANK
      static let rank = L10n.tr("Localizable", "ecopoints.profile.rank")
      /// View profile details
      static let viewProfileDetails = L10n.tr("Localizable", "ecopoints.profile.view_profile_details")

      enum Section {
        /// Statistics
        static let statistics = L10n.tr("Localizable", "ecopoints.profile.section.statistics")
      }

      enum Settings {
        /// Change password
        static let changePassword = L10n.tr("Localizable", "ecopoints.profile.settings.change_password")
        /// Change profile picture
        static let changeProfilePicture = L10n.tr("Localizable", "ecopoints.profile.settings.change_profile_picture")
        /// Delete my account
        static let deleteAccount = L10n.tr("Localizable", "ecopoints.profile.settings.delete_account")
        /// Log out
        static let logOut = L10n.tr("Localizable", "ecopoints.profile.settings.log_out")
        /// Log out from all devices
        static let logOutAll = L10n.tr("Localizable", "ecopoints.profile.settings.log_out_all")

        enum Delete {
          /// Are you sure? This cannot be undone.
          static let subtitle = L10n.tr("Localizable", "ecopoints.profile.settings.delete.subtitle")
          /// Delete account?
          static let title = L10n.tr("Localizable", "ecopoints.profile.settings.delete.title")
        }

        enum Error {

          enum Delete {
            /// Please retry again later.
            static let subtitle = L10n.tr("Localizable", "ecopoints.profile.settings.error.delete.subtitle")
            /// Couldn't delete account
            static let title = L10n.tr("Localizable", "ecopoints.profile.settings.error.delete.title")
          }

          enum Internet {
            /// Please connect to the internet to continue
            static let subtitle = L10n.tr("Localizable", "ecopoints.profile.settings.error.internet.subtitle")
            /// No internet connection
            static let title = L10n.tr("Localizable", "ecopoints.profile.settings.error.internet.title")
          }

          enum Logout {
            /// Please retry again later.
            static let subtitle = L10n.tr("Localizable", "ecopoints.profile.settings.error.logout.subtitle")
            /// Couldn't log out
            static let title = L10n.tr("Localizable", "ecopoints.profile.settings.error.logout.title")
          }
        }

        enum Section {
          /// Account
          static let account = L10n.tr("Localizable", "ecopoints.profile.settings.section.account")
          /// Profile
          static let profile = L10n.tr("Localizable", "ecopoints.profile.settings.section.profile")
          /// Settings
          static let settings = L10n.tr("Localizable", "ecopoints.profile.settings.section.settings")
        }
      }
    }

    enum TabBar {
      /// Badges
      static let badges = L10n.tr("Localizable", "ecopoints.tab_bar.badges")
      /// Leaderboard
      static let leaderboard = L10n.tr("Localizable", "ecopoints.tab_bar.leaderboard")
      /// Profile
      static let profile = L10n.tr("Localizable", "ecopoints.tab_bar.profile")
    }
  }

  enum EmptyState {

    enum LineFavorites {
      /// Tap and hold a line to add it to the favorites so you can easily access it later
      static let subtitle = L10n.tr("Localizable", "empty_state.line_favorites.subtitle")
      /// No favorite lines
      static let title = L10n.tr("Localizable", "empty_state.line_favorites.title")
    }
  }

  enum Feedback {
    /// This page is only for reporting bugs or requesting app features. If you need to open a complaint, please contact reclami.beschwerden@sasabz.it
    static let complaintText = L10n.tr("Localizable", "feedback.complaint_text")
    /// Done
    static let done = L10n.tr("Localizable", "feedback.done")
    /// Submit
    static let submit = L10n.tr("Localizable", "feedback.submit")
    /// Feedback
    static let title = L10n.tr("Localizable", "feedback.title")

    enum Category {
      /// Report a bug
      static let bug = L10n.tr("Localizable", "feedback.category.bug")
      /// Suggest a feature
      static let feature = L10n.tr("Localizable", "feedback.category.feature")
      /// Please first let us know what you'd like to do:
      static let title = L10n.tr("Localizable", "feedback.category.title")
    }

    enum Email {
      /// john@appleseed.com
      static let placeholder = L10n.tr("Localizable", "feedback.email.placeholder")
    }

    enum Error {
      /// Please retry in a few minutes
      static let subtitle = L10n.tr("Localizable", "feedback.error.subtitle")
      /// Upload failed
      static let title = L10n.tr("Localizable", "feedback.error.title")
    }

    enum Name {
      /// John Appleseed
      static let placeholder = L10n.tr("Localizable", "feedback.name.placeholder")
    }

    enum Success {
      /// We will get back to you as soon as possible.
      static let subtitle = L10n.tr("Localizable", "feedback.success.subtitle")
      /// Thanks!
      static let title = L10n.tr("Localizable", "feedback.success.title")
    }

    enum TextArea {
      /// Even though we can't reply to all messages, all suggestions are more than welcome and are taken into serious consideration
      static let placeholder = L10n.tr("Localizable", "feedback.text_area.placeholder")
    }
  }

  enum General {
    /// %d' delayed
    static func delayDelayed(_ p1: Int) -> String {
      return L10n.tr("Localizable", "general.delay_delayed", p1)
    }
    /// %d' early
    static func delayEarly(_ p1: Int) -> String {
      return L10n.tr("Localizable", "general.delay_early", p1)
    }
    /// Punctual
    static let delayPunctual = L10n.tr("Localizable", "general.delay_punctual")
    /// Heading to %@
    static func headingTo(_ p1: String) -> String {
      return L10n.tr("Localizable", "general.heading_to", p1)
    }
    /// Line %@
    static func line(_ p1: String) -> String {
      return L10n.tr("Localizable", "general.line", p1)
    }
    /// Lines %@
    static func lines(_ p1: String) -> String {
      return L10n.tr("Localizable", "general.lines", p1)
    }
    /// Now at %@
    static func nowAt(_ p1: String) -> String {
      return L10n.tr("Localizable", "general.now_at", p1)
    }
    /// pull to refresh
    static let pullToRefresh = L10n.tr("Localizable", "general.pullToRefresh")
  }

  enum Line {
    /// Line
    static let title = L10n.tr("Localizable", "line.title")

    enum Course {
      /// Line course
      static let title = L10n.tr("Localizable", "line.course.title")

      enum Header {
        /// List
        static let list = L10n.tr("Localizable", "line.course.header.list")
        /// Map
        static let map = L10n.tr("Localizable", "line.course.header.map")
      }
    }

    enum Details {

      enum Header {
        /// Buses
        static let buses = L10n.tr("Localizable", "line.details.header.buses")
        /// Line path
        static let path = L10n.tr("Localizable", "line.details.header.path")
      }

      enum Info {
        /// Additional info
        static let additional = L10n.tr("Localizable", "line.details.info.additional")
      }
    }

    enum TabBar {
      /// Bolzano
      static let bolzano = L10n.tr("Localizable", "line.tab_bar.bolzano")
      /// Favorites
      static let favorites = L10n.tr("Localizable", "line.tab_bar.favorites")
      /// Merano
      static let merano = L10n.tr("Localizable", "line.tab_bar.merano")
    }
  }

  enum Map {
    /// Map
    static let title = L10n.tr("Localizable", "map.title")

    enum Sheet {
      /// Bus #%d
      static func bus(_ p1: Int) -> String {
        return L10n.tr("Localizable", "map.sheet.bus", p1)
      }
      /// COURSE
      static let course = L10n.tr("Localizable", "map.sheet.course")
      /// %d' delayed
      static func delayed(_ p1: Int) -> String {
        return L10n.tr("Localizable", "map.sheet.delayed", p1)
      }
      /// LINE
      static let line = L10n.tr("Localizable", "map.sheet.line")
      /// Trip #%d
      static func trip(_ p1: Int) -> String {
        return L10n.tr("Localizable", "map.sheet.trip", p1)
      }
      /// Updated %d' ago
      static func updated(_ p1: Int) -> String {
        return L10n.tr("Localizable", "map.sheet.updated", p1)
      }
      /// Variant #%d
      static func variant(_ p1: Int) -> String {
        return L10n.tr("Localizable", "map.sheet.variant", p1)
      }
      /// VEHICLE
      static let vehicle = L10n.tr("Localizable", "map.sheet.vehicle")
    }
  }

  enum News {
    /// News
    static let title = L10n.tr("Localizable", "news.title")

    enum Detail {
      /// News detail
      static let title = L10n.tr("Localizable", "news.detail.title")
    }

    enum TabBar {
      /// Bolzano
      static let bolzano = L10n.tr("Localizable", "news.tab_bar.bolzano")
      /// Merano
      static let merano = L10n.tr("Localizable", "news.tab_bar.merano")
    }
  }

  enum Parking {
    /// Parking
    static let title = L10n.tr("Localizable", "parking.title")

    enum Detail {
      /// Parking lot detail
      static let title = L10n.tr("Localizable", "parking.detail.title")
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
