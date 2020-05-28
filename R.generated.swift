//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.image` struct is generated, and contains static references to 11 images.
  struct image {
    /// Image `avatar`.
    static let avatar = Rswift.ImageResource(bundle: R.hostingBundle, name: "avatar")
    /// Image `cell-tower`.
    static let cellTower = Rswift.ImageResource(bundle: R.hostingBundle, name: "cell-tower")
    /// Image `map-filled`.
    static let mapFilled = Rswift.ImageResource(bundle: R.hostingBundle, name: "map-filled")
    /// Image `map`.
    static let map = Rswift.ImageResource(bundle: R.hostingBundle, name: "map")
    /// Image `sites-filled`.
    static let sitesFilled = Rswift.ImageResource(bundle: R.hostingBundle, name: "sites-filled")
    /// Image `sites`.
    static let sites = Rswift.ImageResource(bundle: R.hostingBundle, name: "sites")
    /// Image `sort`.
    static let sort = Rswift.ImageResource(bundle: R.hostingBundle, name: "sort")
    /// Image `tasks-filled`.
    static let tasksFilled = Rswift.ImageResource(bundle: R.hostingBundle, name: "tasks-filled")
    /// Image `tasks`.
    static let tasks = Rswift.ImageResource(bundle: R.hostingBundle, name: "tasks")
    /// Image `user-filled`.
    static let userFilled = Rswift.ImageResource(bundle: R.hostingBundle, name: "user-filled")
    /// Image `user`.
    static let user = Rswift.ImageResource(bundle: R.hostingBundle, name: "user")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "avatar", bundle: ..., traitCollection: ...)`
    static func avatar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.avatar, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "cell-tower", bundle: ..., traitCollection: ...)`
    static func cellTower(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.cellTower, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "map", bundle: ..., traitCollection: ...)`
    static func map(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.map, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "map-filled", bundle: ..., traitCollection: ...)`
    static func mapFilled(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mapFilled, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "sites", bundle: ..., traitCollection: ...)`
    static func sites(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.sites, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "sites-filled", bundle: ..., traitCollection: ...)`
    static func sitesFilled(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.sitesFilled, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "sort", bundle: ..., traitCollection: ...)`
    static func sort(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.sort, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "tasks", bundle: ..., traitCollection: ...)`
    static func tasks(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tasks, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "tasks-filled", bundle: ..., traitCollection: ...)`
    static func tasksFilled(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tasksFilled, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "user", bundle: ..., traitCollection: ...)`
    static func user(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.user, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "user-filled", bundle: ..., traitCollection: ...)`
    static func userFilled(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.userFilled, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.info` struct is generated, and contains static references to 1 properties.
  struct info {
    struct uiApplicationSceneManifest {
      static let _key = "UIApplicationSceneManifest"
      static let uiApplicationSupportsMultipleScenes = false

      struct uiSceneConfigurations {
        static let _key = "UISceneConfigurations"

        struct uiWindowSceneSessionRoleApplication {
          struct defaultConfiguration {
            static let _key = "Default Configuration"
            static let uiSceneConfigurationName = infoPlistString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication", "Default Configuration"], key: "UISceneConfigurationName") ?? "Default Configuration"
            static let uiSceneDelegateClassName = infoPlistString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication", "Default Configuration"], key: "UISceneDelegateClassName") ?? "$(PRODUCT_MODULE_NAME).SceneDelegate"

            fileprivate init() {}
          }

          fileprivate init() {}
        }

        fileprivate init() {}
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  /// This `R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    /// This `R.string.localizable` struct is generated, and contains static references to 20 localization keys.
    struct localizable {
      /// en translation: ?action=check_if_user_exists&username='%s'&password='%s'
      ///
      /// Locales: en
      static let check_if_user_exists = Rswift.StringResource(key: "check_if_user_exists", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: ?action=get_all_sites
      ///
      /// Locales: en
      static let get_all_sites = Rswift.StringResource(key: "get_all_sites", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: ?action=get_all_users
      ///
      /// Locales: en
      static let get_all_users = Rswift.StringResource(key: "get_all_users", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: ?action=get_tasks_for_user&user_id=%d
      ///
      /// Locales: en
      static let get_tasks_for_user = Rswift.StringResource(key: "get_tasks_for_user", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: An error occurred while fetching data.
      ///
      /// Locales: en
      static let error_alert_message = Rswift.StringResource(key: "error_alert_message", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Error
      ///
      /// Locales: en
      static let error_alert_title = Rswift.StringResource(key: "error_alert_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Login
      ///
      /// Locales: en
      static let login = Rswift.StringResource(key: "login", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Login Failed
      ///
      /// Locales: en
      static let failed_login_alert_title = Rswift.StringResource(key: "failed_login_alert_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Map
      ///
      /// Locales: en
      static let map = Rswift.StringResource(key: "map", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Missing Fields
      ///
      /// Locales: en
      static let missing_data_alert_title = Rswift.StringResource(key: "missing_data_alert_title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: OK
      ///
      /// Locales: en
      static let alert_ok_action = Rswift.StringResource(key: "alert_ok_action", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Password
      ///
      /// Locales: en
      static let password = Rswift.StringResource(key: "password", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Please enter your username and password.
      ///
      /// Locales: en
      static let missing_data_alert_message = Rswift.StringResource(key: "missing_data_alert_message", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Search sites
      ///
      /// Locales: en
      static let search_sites_placeholder = Rswift.StringResource(key: "search_sites_placeholder", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Sites
      ///
      /// Locales: en
      static let sites = Rswift.StringResource(key: "sites", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Tasks
      ///
      /// Locales: en
      static let tasks = Rswift.StringResource(key: "tasks", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: The dequeued cell is not an instance of %s.
      ///
      /// Locales: en
      static let cell_error = Rswift.StringResource(key: "cell_error", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: The username or password is incorrect.
      ///
      /// Locales: en
      static let failed_login_alert_message = Rswift.StringResource(key: "failed_login_alert_message", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: User
      ///
      /// Locales: en
      static let user = Rswift.StringResource(key: "user", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)
      /// en translation: Username
      ///
      /// Locales: en
      static let username = Rswift.StringResource(key: "username", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en"], comment: nil)

      /// en translation: ?action=check_if_user_exists&username='%s'&password='%s'
      ///
      /// Locales: en
      static func check_if_user_exists(_ value1: UnsafePointer<CChar>, _ value2: UnsafePointer<CChar>, preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          let format = NSLocalizedString("check_if_user_exists", bundle: hostingBundle, comment: "")
          return String(format: format, locale: applicationLocale, value1, value2)
        }

        guard let (locale, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "check_if_user_exists"
        }

        let format = NSLocalizedString("check_if_user_exists", bundle: bundle, comment: "")
        return String(format: format, locale: locale, value1, value2)
      }

      /// en translation: ?action=get_all_sites
      ///
      /// Locales: en
      static func get_all_sites(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("get_all_sites", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "get_all_sites"
        }

        return NSLocalizedString("get_all_sites", bundle: bundle, comment: "")
      }

      /// en translation: ?action=get_all_users
      ///
      /// Locales: en
      static func get_all_users(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("get_all_users", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "get_all_users"
        }

        return NSLocalizedString("get_all_users", bundle: bundle, comment: "")
      }

      /// en translation: ?action=get_tasks_for_user&user_id=%d
      ///
      /// Locales: en
      static func get_tasks_for_user(_ value1: Int, preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          let format = NSLocalizedString("get_tasks_for_user", bundle: hostingBundle, comment: "")
          return String(format: format, locale: applicationLocale, value1)
        }

        guard let (locale, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "get_tasks_for_user"
        }

        let format = NSLocalizedString("get_tasks_for_user", bundle: bundle, comment: "")
        return String(format: format, locale: locale, value1)
      }

      /// en translation: An error occurred while fetching data.
      ///
      /// Locales: en
      static func error_alert_message(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("error_alert_message", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "error_alert_message"
        }

        return NSLocalizedString("error_alert_message", bundle: bundle, comment: "")
      }

      /// en translation: Error
      ///
      /// Locales: en
      static func error_alert_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("error_alert_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "error_alert_title"
        }

        return NSLocalizedString("error_alert_title", bundle: bundle, comment: "")
      }

      /// en translation: Login
      ///
      /// Locales: en
      static func login(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("login", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "login"
        }

        return NSLocalizedString("login", bundle: bundle, comment: "")
      }

      /// en translation: Login Failed
      ///
      /// Locales: en
      static func failed_login_alert_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("failed_login_alert_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "failed_login_alert_title"
        }

        return NSLocalizedString("failed_login_alert_title", bundle: bundle, comment: "")
      }

      /// en translation: Map
      ///
      /// Locales: en
      static func map(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("map", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "map"
        }

        return NSLocalizedString("map", bundle: bundle, comment: "")
      }

      /// en translation: Missing Fields
      ///
      /// Locales: en
      static func missing_data_alert_title(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("missing_data_alert_title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "missing_data_alert_title"
        }

        return NSLocalizedString("missing_data_alert_title", bundle: bundle, comment: "")
      }

      /// en translation: OK
      ///
      /// Locales: en
      static func alert_ok_action(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("alert_ok_action", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "alert_ok_action"
        }

        return NSLocalizedString("alert_ok_action", bundle: bundle, comment: "")
      }

      /// en translation: Password
      ///
      /// Locales: en
      static func password(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("password", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "password"
        }

        return NSLocalizedString("password", bundle: bundle, comment: "")
      }

      /// en translation: Please enter your username and password.
      ///
      /// Locales: en
      static func missing_data_alert_message(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("missing_data_alert_message", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "missing_data_alert_message"
        }

        return NSLocalizedString("missing_data_alert_message", bundle: bundle, comment: "")
      }

      /// en translation: Search sites
      ///
      /// Locales: en
      static func search_sites_placeholder(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("search_sites_placeholder", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "search_sites_placeholder"
        }

        return NSLocalizedString("search_sites_placeholder", bundle: bundle, comment: "")
      }

      /// en translation: Sites
      ///
      /// Locales: en
      static func sites(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("sites", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "sites"
        }

        return NSLocalizedString("sites", bundle: bundle, comment: "")
      }

      /// en translation: Tasks
      ///
      /// Locales: en
      static func tasks(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("tasks", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "tasks"
        }

        return NSLocalizedString("tasks", bundle: bundle, comment: "")
      }

      /// en translation: The dequeued cell is not an instance of %s.
      ///
      /// Locales: en
      static func cell_error(_ value1: UnsafePointer<CChar>, preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          let format = NSLocalizedString("cell_error", bundle: hostingBundle, comment: "")
          return String(format: format, locale: applicationLocale, value1)
        }

        guard let (locale, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "cell_error"
        }

        let format = NSLocalizedString("cell_error", bundle: bundle, comment: "")
        return String(format: format, locale: locale, value1)
      }

      /// en translation: The username or password is incorrect.
      ///
      /// Locales: en
      static func failed_login_alert_message(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("failed_login_alert_message", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "failed_login_alert_message"
        }

        return NSLocalizedString("failed_login_alert_message", bundle: bundle, comment: "")
      }

      /// en translation: User
      ///
      /// Locales: en
      static func user(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("user", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "user"
        }

        return NSLocalizedString("user", bundle: bundle, comment: "")
      }

      /// en translation: Username
      ///
      /// Locales: en
      static func username(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("username", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "username"
        }

        return NSLocalizedString("username", bundle: bundle, comment: "")
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
