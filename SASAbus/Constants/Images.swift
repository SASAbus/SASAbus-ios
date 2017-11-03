// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  #if swift(>=3.2)
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
  #endif
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  static let bgSidemenu = ImageAsset(name: "BG_sidemenu")
  static let alleIcon = ImageAsset(name: "alle_icon")
  static let alleIconFilled = ImageAsset(name: "alle_icon_filled")
  static let busIcon = ImageAsset(name: "bus_icon")
  static let busstopEnd = ImageAsset(name: "busstop_end")
  static let busstopMiddle = ImageAsset(name: "busstop_middle")
  static let busstopStart = ImageAsset(name: "busstop_start")
  static let emptyStateStar = ImageAsset(name: "empty_state_star")
  static let favoritIcon = ImageAsset(name: "favorit_icon")
  static let favoritIconFilled = ImageAsset(name: "favorit_icon_filled")
  static let filterIcon = ImageAsset(name: "filter_icon")
  static let icAccountCircleWhite = ImageAsset(name: "ic_account_circle_white")
  static let icAccountCircleWhite36pt = ImageAsset(name: "ic_account_circle_white_36pt")
  static let icAddWhite = ImageAsset(name: "ic_add_white")
  static let icApp = ImageAsset(name: "ic_app")
  static let icAssessmentWhite = ImageAsset(name: "ic_assessment_white")
  static let icAttachMoneyWhite = ImageAsset(name: "ic_attach_money_white")
  static let icBubbleChartWhite = ImageAsset(name: "ic_bubble_chart_white")
  static let icBubbleChartWhite48pt = ImageAsset(name: "ic_bubble_chart_white_48pt")
  static let icCallMadeWhite = ImageAsset(name: "ic_call_made_white")
  static let icChevronLeftWhite = ImageAsset(name: "ic_chevron_left_white")
  static let icChevronRightWhite = ImageAsset(name: "ic_chevron_right_white")
  static let icDirectionsBusWhite = ImageAsset(name: "ic_directions_bus_white")
  static let icDirectionsWalkWhite = ImageAsset(name: "ic_directions_walk_white")
  static let icDoneWhite = ImageAsset(name: "ic_done_white")
  static let icDoneWhite48pt = ImageAsset(name: "ic_done_white_48pt")
  static let icEventNoteWhite = ImageAsset(name: "ic_event_note_white")
  static let icEventNoteWhite48pt = ImageAsset(name: "ic_event_note_white_48pt")
  static let icEventWhite = ImageAsset(name: "ic_event_white")
  static let icExploreWhite = ImageAsset(name: "ic_explore_white")
  static let icFlagWhite = ImageAsset(name: "ic_flag_white")
  static let icFlagWhite48pt = ImageAsset(name: "ic_flag_white_48pt")
  static let icFontDownloadWhite = ImageAsset(name: "ic_font_download_white")
  static let icHydrogenWhite = ImageAsset(name: "ic_hydrogen_white")
  static let icInfoOutlineWhite = ImageAsset(name: "ic_info_outline_white")
  static let icLanguageWhite = ImageAsset(name: "ic_language_white")
  static let icListWhite36pt = ImageAsset(name: "ic_list_white_36pt")
  static let icLocalGasStationWhite = ImageAsset(name: "ic_local_gas_station_white")
  static let icLocationOnWhite = ImageAsset(name: "ic_location_on_white")
  static let icLoyaltyWhite = ImageAsset(name: "ic_loyalty_white")
  static let icLoyaltyWhite36pt = ImageAsset(name: "ic_loyalty_white_36pt")
  static let icLoyaltyWhite48pt = ImageAsset(name: "ic_loyalty_white_48pt")
  static let icMapWhite = ImageAsset(name: "ic_map_white")
  static let icNaturePeopleWhite = ImageAsset(name: "ic_nature_people_white")
  static let icNavigationBus = ImageAsset(name: "ic_navigation_bus")
  static let icNavigationBusstop = ImageAsset(name: "ic_navigation_busstop")
  static let icNavigationMap = ImageAsset(name: "ic_navigation_map")
  static let icNavigationNews = ImageAsset(name: "ic_navigation_news")
  static let icNavigationParking = ImageAsset(name: "ic_navigation_parking")
  static let icPaletteWhite = ImageAsset(name: "ic_palette_white")
  static let icPinDropWhite = ImageAsset(name: "ic_pin_drop_white")
  static let icPlaceWhite = ImageAsset(name: "ic_place_white")
  static let icQueryBuilderWhite = ImageAsset(name: "ic_query_builder_white")
  static let icRadioButtonCheckedWhite = ImageAsset(name: "ic_radio_button_checked_white")
  static let icRefreshWhite = ImageAsset(name: "ic_refresh_white")
  static let icReorderWhite = ImageAsset(name: "ic_reorder_white")
  static let icScheduleWhite = ImageAsset(name: "ic_schedule_white")
  static let icSettingsWhite = ImageAsset(name: "ic_settings_white")
  static let icStarBorderWhite = ImageAsset(name: "ic_star_border_white")
  static let icStarWhite = ImageAsset(name: "ic_star_white")
  static let icStarWhite48pt = ImageAsset(name: "ic_star_white_48pt")
  static let icStoreWhite = ImageAsset(name: "ic_store_white")
  static let icTimelineWhite = ImageAsset(name: "ic_timeline_white")
  static let icTrackChangesWhite = ImageAsset(name: "ic_track_changes_white")
  static let icTwosDotsWhite = ImageAsset(name: "ic_twos_dots_white")
  static let introAgreement = ImageAsset(name: "intro_agreement")
  static let introBluetooth = ImageAsset(name: "intro_bluetooth")
  static let introData = ImageAsset(name: "intro_data")
  static let introPermission = ImageAsset(name: "intro_permission")
  static let introRealtime = ImageAsset(name: "intro_realtime")
  static let lineCourseDot = ImageAsset(name: "line_course_dot")
  static let lineCourseDots = ImageAsset(name: "line_course_dots")
  static let lineCourseDots5 = ImageAsset(name: "line_course_dots_5")
  static let locationIcon = ImageAsset(name: "location_icon")
  static let locationIconFilled = ImageAsset(name: "location_icon_filled")
  static let mapIcon = ImageAsset(name: "map_icon")
  static let mapIconFilled = ImageAsset(name: "map_icon_filled")
  static let menuIcon = ImageAsset(name: "menu_icon")
  static let moreIcon = ImageAsset(name: "more_icon")
  static let moreIconFilled = ImageAsset(name: "more_icon_filled")
  static let parking = ImageAsset(name: "parking")
  static let pathBus = ImageAsset(name: "path_bus")
  static let pathBusStop = ImageAsset(name: "path_bus_stop")
  static let pathEnd = ImageAsset(name: "path_end")
  static let pathEtc = ImageAsset(name: "path_etc")
  static let pathStart = ImageAsset(name: "path_start")
  static let realTime2 = ImageAsset(name: "real-time2")
  static let sasaIconRound = ImageAsset(name: "sasa_icon_round")
  static let systemPreferenceLayer = ImageAsset(name: "system_preference_layer")
  static let unknownBus = ImageAsset(name: "unknown_bus")
  static let wappenBz = ImageAsset(name: "wappen_bz")
  static let wappenMe = ImageAsset(name: "wappen_me")
  static let wave = ImageAsset(name: "wave")

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    bgSidemenu,
    alleIcon,
    alleIconFilled,
    busIcon,
    busstopEnd,
    busstopMiddle,
    busstopStart,
    emptyStateStar,
    favoritIcon,
    favoritIconFilled,
    filterIcon,
    icAccountCircleWhite,
    icAccountCircleWhite36pt,
    icAddWhite,
    icApp,
    icAssessmentWhite,
    icAttachMoneyWhite,
    icBubbleChartWhite,
    icBubbleChartWhite48pt,
    icCallMadeWhite,
    icChevronLeftWhite,
    icChevronRightWhite,
    icDirectionsBusWhite,
    icDirectionsWalkWhite,
    icDoneWhite,
    icDoneWhite48pt,
    icEventNoteWhite,
    icEventNoteWhite48pt,
    icEventWhite,
    icExploreWhite,
    icFlagWhite,
    icFlagWhite48pt,
    icFontDownloadWhite,
    icHydrogenWhite,
    icInfoOutlineWhite,
    icLanguageWhite,
    icListWhite36pt,
    icLocalGasStationWhite,
    icLocationOnWhite,
    icLoyaltyWhite,
    icLoyaltyWhite36pt,
    icLoyaltyWhite48pt,
    icMapWhite,
    icNaturePeopleWhite,
    icNavigationBus,
    icNavigationBusstop,
    icNavigationMap,
    icNavigationNews,
    icNavigationParking,
    icPaletteWhite,
    icPinDropWhite,
    icPlaceWhite,
    icQueryBuilderWhite,
    icRadioButtonCheckedWhite,
    icRefreshWhite,
    icReorderWhite,
    icScheduleWhite,
    icSettingsWhite,
    icStarBorderWhite,
    icStarWhite,
    icStarWhite48pt,
    icStoreWhite,
    icTimelineWhite,
    icTrackChangesWhite,
    icTwosDotsWhite,
    introAgreement,
    introBluetooth,
    introData,
    introPermission,
    introRealtime,
    lineCourseDot,
    lineCourseDots,
    lineCourseDots5,
    locationIcon,
    locationIconFilled,
    mapIcon,
    mapIconFilled,
    menuIcon,
    moreIcon,
    moreIconFilled,
    parking,
    pathBus,
    pathBusStop,
    pathEnd,
    pathEtc,
    pathStart,
    realTime2,
    sasaIconRound,
    systemPreferenceLayer,
    unknownBus,
    wappenBz,
    wappenMe,
    wave,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX) || os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  #if swift(>=3.2)
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: asset.name, bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
  #endif
}

private final class BundleToken {}
