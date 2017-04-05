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
import CoreData
import DrawerController
import Alamofire
import CoreLocation
import Fabric
import Crashlytics
import UserNotifications
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var drawerController: DrawerController!

    var notificationHandlers: [String : NotificationProtocol] = [String: NotificationProtocol]()

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        setupLogging()
        setupRealm()
        setupModels()
        setupGoogle()
        setupBeacons()
        setupNotifications()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        if !Settings.isIntroFinished() {
            let storyboard = UIStoryboard(name: "Intro", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "intro_parent_controller")
            as! IntroParentViewController

            viewController.dataOnly = false

            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        } else {
            self.window!.backgroundColor = UIColor.white
            self.window!.makeKeyAndVisible()

            self.startApplication()
        }

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


    func startApplication() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.tintColor = Theme.white  // Back buttons and such
        navigationBarAppearance.barTintColor = Theme.orange  // Bar's background color
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: Theme.white]  // Title's text color

        // Ask for Authorisation from the User.
        CLLocationManager().requestAlwaysAuthorization()

        // For use in foreground
        CLLocationManager().requestWhenInUseAuthorization()

        let navigationController = getNavigationController(Menu.items[0].viewController!)
        let menuViewController: MenuViewController! = MenuViewController(nibName: "MenuViewController", bundle: nil)
        self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: menuViewController)

        let selectedMenuItemIndexPath: IndexPath = IndexPath(row: 0, section: 0)

        menuViewController.tableView.selectRow(at: selectedMenuItemIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        menuViewController.tableView.cellForRow(at: menuViewController.tableView.indexPathForSelectedRow!)?.setSelected(true, animated: false)

        self.drawerController.showsShadows = false
        self.drawerController.openDrawerGestureModeMask = OpenDrawerGestureMode.bezelPanningCenterView
        self.drawerController.closeDrawerGestureModeMask = CloseDrawerGestureMode.panningCenterView
        self.window!.rootViewController = self.drawerController
    }


    func setupBeacons() {
        BeaconHandler.instance.start()
    }

    func setupLogging() {
        #if DEBUG
            Fabric.with([Crashlytics.self])
        #endif
    }

    func setupGoogle() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
        // gai?.logger?.logLevel = GAILogLevel.verbose
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
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.sound, .alert, .badge]) { (_, error) in
            if error == nil {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        Notifications.clearAll()
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


    // - MARK: UNUserNotificationCenterDelegate

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // Called when a notification is delivered to a foreground app.

        Log.warning("Got notification request: \(notification.request.identifier)")
        completionHandler([.alert, .badge, .sound])
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        // Called to let your app know which action was selected by the user for a given notification.

        Log.warning("Got notification action: \(response.actionIdentifier)")
        completionHandler()
    }
}
