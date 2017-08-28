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
import GoogleSignIn

import AlamofireNetworkActivityIndicator

// TODO: Departures: Filter not persistent
// TODO: News: Check if empty state is working

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerController: DrawerController!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupLogging()
        setupFirebase()
        setupRealm()
        setupModels()
        setupBeacons()
        setupNotifications()

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


    func applicationWillResignActive(_ application: UIApplication) {
        Log.warning("applicationWillResignActive()")

        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Log.warning("applicationDidEnterBackground()")

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application
        // state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution,
        // this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Log.warning("applicationWillEnterForeground()")

        // Called as part of the transition from the background to the inactive state;
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Log.warning("applicationDidBecomeActive()")

        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Log.warning("applicationWillTerminate()")

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(
                url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
    }


    func startIntro(dataOnly: Bool = false) {
        let storyboard = UIStoryboard(name: "Intro", bundle: nil)
        let viewController = storyboard.instantiateViewController(
                withIdentifier: "intro_parent_controller") as! IntroParentViewController

        viewController.dataOnly = dataOnly

        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }

    func startApplication() {
        let appearance = UINavigationBar.appearance()
        appearance.isTranslucent = false
        appearance.tintColor = Theme.white  // Back buttons and such
        appearance.barTintColor = Theme.orange  // Bar's background color
        appearance.titleTextAttributes = [NSForegroundColorAttributeName: Theme.white]  // Title's text color

        CLLocationManager().requestAlwaysAuthorization()
        CLLocationManager().requestWhenInUseAuthorization()

        let navigationController = getNavigationController(Menu.items[0].viewController!)
        let menuController: MenuViewController! = MenuViewController(nibName: "MenuViewController", bundle: nil)
        self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: menuController)

        let startIndex = Settings.getStartScreen()
        let selectedMenuItem: IndexPath = IndexPath(row: startIndex, section: 0)

        menuController.tableView.selectRow(at: selectedMenuItem, animated: false, scrollPosition: UITableViewScrollPosition.none)
        menuController.tableView.cellForRow(at: menuController.tableView.indexPathForSelectedRow!)?.setSelected(true, animated: false)

        self.drawerController.showsShadows = false
        self.drawerController.openDrawerGestureModeMask = OpenDrawerGestureMode.bezelPanningCenterView
        self.drawerController.closeDrawerGestureModeMask = CloseDrawerGestureMode.panningCenterView

        self.window!.rootViewController = self.drawerController
    }


    func setupBeacons() {
        BeaconHandler.instance.start()
    }

    func setupLogging() {
#if !DEBUG
        Fabric.with([Crashlytics.self])
#endif
    }

    func setupFirebase() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

        GIDSignIn.sharedInstance().delegate = self

        // TODO: Fix Firebase Remote Config
        // FirebaseApp.configure()

        let remoteConfig = FIRRemoteConfig.remoteConfig()
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!

        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaultsFromPlistFileName("RemoteConfigDefaults")

        remoteConfig.fetch(withExpirationDuration: TimeInterval(86400)) { (status, error) -> Void in
            if status == .success {
                Log.error("Remote config fetch succeeded.")

                let oldUrl = Endpoint.apiUrl

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

                if oldUrl != url {
                    Log.error("Api url changed from \(oldUrl) to \(url)")
                }
            } else {
                print("Remote config fetch failed: \(error)")
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

        Settings.registerDefaults()

        _ = VdvHandler.load()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .subscribe(onError: { error in
                    Log.error(error)
                })
    }

    func setupNotifications() {
        // UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })

        UIApplication.shared.registerForRemoteNotifications()
        Notifications.clearAll()

        // TODO: Fix Firebbase Cloud Messaging
        // FIRMessaging.messaging().delegate = self
        // FIRMessaging.messaging().shouldEstablishDirectChannel = true

        // FIRMessaging.messaging().subscribe(toTopic: "/topics/general")
        // FIRMessaging.messaging().subscribe(toTopic: "general")

        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
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


extension AppDelegate: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            Log.info("Login success: userId=\(userId)")
            
            let userId = user.userID
            let idToken = user.authentication.idToken

            NotificationCenter.default.post(
                    name: LoginViewController.googleLoginSuccess,
                    object: nil,
                    userInfo: ["user_id": idToken]
            )
        } else {
            print("Login error: \(error.localizedDescription)")
            
            AuthHelper.logout()

            NotificationCenter.default.post(name: LoginViewController.googleLoginError, object: nil)
        }
    }

    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: Error!) {
        AuthHelper.logout()
        
        if (error == nil) {
            print("Logout successful")
        } else {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}


/*extension AppDelegate: UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        Log.warning("willPresent withCompletionHandler: \(notification.request.identifier)")
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        Log.warning("didReceive withCompletionHandler: \(response.actionIdentifier)")
        completionHandler()
    }
}*/

/*extension AppDelegate: FIRMessagingDelegate {

    func messaging(_ messaging: FIRMessaging, didRefreshRegistrationToken fcmToken: String) {
        Log.error("Firebase registration token: \(fcmToken)")
    }

    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: FIRMessaging, didReceive remoteMessage: FIRMessagingRemoteMessage) {
        Log.error("Received data message: \(remoteMessage.appData)")
    }
}*/
