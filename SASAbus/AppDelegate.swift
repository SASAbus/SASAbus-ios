//
// AppDelegate.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus. If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CoreLocation
import UserNotifications

import DrawerController

import Fabric
import Crashlytics

import RxSwift
import RxCocoa

import Firebase
import Google

import AlamofireNetworkActivityIndicator

// TODO: News: Check if empty state is working
// TODO: Add translations
// TODO: Update vehicle list
// TODO: Add proper sync
// TODO: Check if beacon stuff works
// TODO: Add beacon telemetry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerController: DrawerController!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Settings.registerDefaults()
        
        setupLogging()
        setupFirebase()
        setupRealm()
        setupModels()
        setupNotifications()
        
        setupBeacons()

        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.5

        self.window = UIWindow(frame: UIScreen.main.bounds)

        if !Settings.isIntroFinished() {
            startIntro()
        } else if PlannedData.isUpdateAvailable() || !PlannedData.planDataExists() {
            startIntro(dataOnly: true)
        } else {
            window!.backgroundColor = UIColor.white
            window!.makeKeyAndVisible()

            startApplication()
        }

        GIDSignIn.sharedInstance().signOut()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        BeaconHandler.instance.save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        BeaconHandler.instance.save()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(
                url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
    }


    func startApplication() {
        let appearance = UINavigationBar.appearance()
        appearance.isTranslucent = false
        appearance.tintColor = Theme.white
        appearance.barTintColor = Theme.orange
        appearance.titleTextAttributes = [NSForegroundColorAttributeName: Theme.white]

        CLLocationManager().requestAlwaysAuthorization()
        CLLocationManager().requestWhenInUseAuthorization()
        
        let startIndex = Settings.getStartScreen()
        let selectedMenuItem: IndexPath = IndexPath(row: startIndex, section: 0)

        let navigationController = getNavigationController(Menu.items[startIndex].viewController!)
        let menuController: MenuViewController! = MenuViewController(nibName: "MenuViewController", bundle: nil)
        self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: menuController)

        menuController.tableView.selectRow(at: selectedMenuItem, animated: false, scrollPosition: UITableViewScrollPosition.none)
        menuController.tableView.cellForRow(at: menuController.tableView.indexPathForSelectedRow!)?.setSelected(true, animated: false)

        self.drawerController.showsShadows = false
        self.drawerController.openDrawerGestureModeMask = OpenDrawerGestureMode.bezelPanningCenterView
        self.drawerController.closeDrawerGestureModeMask = CloseDrawerGestureMode.panningCenterView

        self.window!.rootViewController = self.drawerController
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationSettings.askForPermissionIfNeeded()
        }
    }

    func startIntro(dataOnly: Bool = false) {
        let storyboard = UIStoryboard(name: "Intro", bundle: nil)
        let viewController = storyboard.instantiateViewController(
                withIdentifier: "intro_parent_controller") as! IntroParentViewController

        viewController.dataOnly = dataOnly

        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }


    func setupBeacons() {
        BeaconHandler.instance.start()
    }

    func setupLogging() {
        Log.setup()
        
        #if DEBUG
            Log.info("SASAbus running in debug configuration")
        #elseif RELEASE
            Log.info("SASAbus running in release configuration")
            
            Fabric.with([Crashlytics.self])
            Crashlytics.sharedInstance().setUserIdentifier(Settings.getCrashlyticsDeviceId())
        #else
            fatalError("Debug or release flag not specified")
        #endif
    }

    func setupFirebase() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        // assert(configureError == nil, "Error configuring Google services: \(configureError)")

        GIDSignIn.sharedInstance().delegate = self

        FirebaseApp.configure()

        let remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)!

        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")

        remoteConfig.fetch(withExpirationDuration: TimeInterval(86400)) { (status, error) -> Void in
            if status == .success {
                Log.error("Remote config fetch succeeded.")

                remoteConfig.activateFetched()

                let url = Endpoint.apiUrl
                Log.warning("Api url: \(url)")

                let realtimeUrl = Endpoint.realtimeApiUrl
                Log.warning("Realtime api url: \(realtimeUrl)")

                let dataUrl = Endpoint.dataApiUrl
                Log.warning("Data api url: \(dataUrl)")

                let reportsUrl = Endpoint.reportsApiUrl
                Log.warning("Reports api url: \(reportsUrl)")

                let telemetryUrl = Endpoint.telemetryApiUrl
                Log.warning("Telemetry api url: \(telemetryUrl)")

                let databaseUrl = Endpoint.databaseApiUrl
                Log.warning("Database api url: \(databaseUrl)")
            } else {
                Log.error("Remote config fetch failed: \(error!.localizedDescription)")
            }
        }
    }

    func setupRealm() {
        BusStopRealmHelper.setup()
        UserRealmHelper.setup()
    }

    func setupModels() {
        Buses.setup()
        Lines.setup()

        _ = VdvHandler.load()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .subscribe(onError: { error in
                    Log.error(error)
                })
    }

    func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self

        UIApplication.shared.registerForRemoteNotifications()
        Notifications.clearAll()

        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        DispatchQueue.main.async {
            FcmUtils.checkForNewsSubscription()
        }
    }


    func navigateTo(_ viewController: UIViewController) {
        self.drawerController!.centerViewController = self.getNavigationController(viewController)
        let menuViewController = self.drawerController!.leftDrawerViewController as! MenuViewController

        let row = Menu.items.index(where: { object_getClassName($0.viewController!) == object_getClassName(viewController) })

        if row != nil {
            menuViewController.tableView.selectRow(at: IndexPath(row: row!, section: 0),
                    animated: false, scrollPosition: UITableViewScrollPosition.none)
        }

        if self.drawerController!.openSide != DrawerSide.none {
            self.drawerController!.toggleDrawerSide(DrawerSide.left, animated: true, completion: nil)
        }
    }

    func getNavigationController(_ viewController: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: viewController)
    }
}


extension AppDelegate {

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        FcmUtils.handleFcmMessage(userInfo: userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        FcmUtils.handleFcmMessage(userInfo: userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.error("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        Log.warning("willPresent withCompletionHandler: \(notification.request.identifier)")
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let identifier = response.notification.request.identifier
        Log.warning("didReceive withCompletionHandler: '\(identifier)'")
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            Log.warning("Dismissed notification '\(identifier)'")
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            Log.warning("Clicked on notification '\(identifier)'")
            
            switch identifier {
            case "news":
                // TODO: Highlight the news the user clicked on?
                if let controller = Menu.items[3].viewController {
                    navigateTo(controller)
                }
            default:
                Log.error("Unknown identifier '\(identifier)'")
            }
        }
        
        completionHandler()
    }
}


extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        Log.error("Got firebase registration token: \(fcmToken)")
        
        FcmSettings.setFcmToken(token: fcmToken)
        FcmUtils.checkForNewsSubscription()
        
        DispatchQueue.main.async {
            Log.warning("Subscribing to general topic")
            Messaging.messaging().subscribe(toTopic: "general")
        }
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Log.error("Received data message: \(remoteMessage.appData)")
    }
}

extension AppDelegate: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID
            let idToken = user.authentication.idToken
            let email = user.profile.email

            Log.info("Login success: userId=\(userId)")

            NotificationCenter.default.post(
                    name: LoginViewController.googleLoginSuccess,
                    object: nil,
                    userInfo: ["user_id": idToken, "email": email]
            )
        } else {
            Log.error("Login error: \(error.localizedDescription)")

            AuthHelper.logout()

            NotificationCenter.default.post(name: LoginViewController.googleLoginError, object: nil)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        AuthHelper.logout()

        if (error == nil) {
            Log.warning("Logout successful")
        } else {
            Log.error("Logout error: \(error.localizedDescription)")
        }
    }
}
