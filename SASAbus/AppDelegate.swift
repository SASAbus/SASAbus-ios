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

    // var beaconObserver: BusBeaconObserver! = BusBeaconObserver(BusBeaconHandler(surveyAction: NotificationAction()))
    // var beaconObserverStation: BusStopBeaconObserver! = BusStopBeaconObserver(BusStopBeaconHandler())

    var busBeaconHandler = BusBeaconHandler()
    var busStopBeaconHandler = BusStopBeaconHandler()

    var notificationHandlers: [String : NotificationProtocol] = [String: NotificationProtocol]()

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        Notifications.clearAll()

        let domainName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domainName)

        Buses.setup()
        Lines.setup()
        BusStopRealmHelper.setup()
        UserRealmHelper.setup()

        VdvHandler.load()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .subscribe(onError: { error in
                    Log.error(error)
                })

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

            self.startDownloadSplashScreen()
        }

        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
        // gai?.logger?.logLevel = GAILogLevel.verbose

        busBeaconHandler.startObserving()
        busStopBeaconHandler.startObserving()

        registerForRemoteNotification()

        return true
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Notifications.clearAll()

        if notificationHandlers.keys.contains(notification.category!) {
            let notificationHandler = notificationHandlers[notification.category!]

            notificationHandler!.handleNotificationForeground(self.window!.rootViewController!,
                    userInfo: notification.userInfo as? [String : Any])
        }
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        Notifications.clearAll()

        if notificationHandlers.keys.contains(notification.category!) {
            let notificationHandler = notificationHandlers[notification.category!]
            notificationHandler?.handleNotificationBackground(identifier, userInfo: notification.userInfo as? [String : Any])
        }

        completionHandler()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application
        // state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution,
        // this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state;
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.

        self.saveContext()
    }


    func startDownloadSplashScreen() {
        let delegate = DownloadDataFinished()
        delegate.appDelegate = self

        let downloadViewController = DownloadViewController(nibName: "DownloadViewController", bundle: nil,
                downloader: SasaBusDownloader(), downloadFinishedDelegate: delegate, canBeCanceled: false, showFinishedDialog: false)

        downloadViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.window!.rootViewController = downloadViewController
    }

    func startApplication() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.tintColor = Theme.white  // Back buttons and such
        navigationBarAppearance.barTintColor = Theme.orange  // Bar's background color
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: Theme.white]  // Title's text color

        // start listening to beacons
        // self.beaconObserver.startObserving()
        // self.beaconObserverStation.startObserving()
        self.registerForLocalNotifications()

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


    // MARK: - Core Data stack

    func getApplicationDocumentsDirectory() -> URL {
        // The directory the application uses to store the Core Data store file.
        // This code uses a directory named "it.sasabz.ios.SASAbus" in the application's documents
        // Application Support directory.

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }

    func getManagedObjectModel() -> NSManagedObjectModel {
        // The managed object model for the application. This property is not optional. It is a fatal error for the
        // application not to be able to find and load its model.

        let modelURL = Bundle.main.url(forResource: "SASAbus", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }

    func getPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator,
        // having added the store for the application to it. This property is optional since there are legitimate error
        // conditions that could cause the creation of the store to fail.
        // Create the coordinator and store

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: getManagedObjectModel())
        let url = getApplicationDocumentsDirectory().appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            Log.error("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }

    func getManagedObjectContext() -> NSManagedObjectContext {
        // Returns the managed object context for the application (which is already bound to the persistent store
        // coordinator for the application.) This property is optional since there are legitimate error conditions that
        // could cause the creation of the context to fail.

        let coordinator = getPersistentStoreCoordinator()
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }


    // MARK: - Core Data Saving support

    func saveContext() {
        if getManagedObjectContext().hasChanges {
            do {
                try getManagedObjectContext().save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.
                Log.error("Unresolved error \(error)")
                abort()
            }
        }
    }

    func registerForLocalNotifications() {
        // Specify the notification actions.
        let notificationYes = UIMutableUserNotificationAction()
        notificationYes.identifier = "Yes"
        notificationYes.title = NSLocalizedString("Yes", comment: "")
        notificationYes.activationMode = UIUserNotificationActivationMode.background
        notificationYes.isDestructive = false
        notificationYes.isAuthenticationRequired = false

        let notificationNo = UIMutableUserNotificationAction()
        notificationNo.identifier = "No"
        notificationNo.title = NSLocalizedString("No", comment: "")
        notificationNo.activationMode = UIUserNotificationActivationMode.foreground
        notificationNo.isDestructive = true
        notificationNo.isAuthenticationRequired = false

        // Create a category with the above actions
        let surveyNotificationHandler = SurveyNotificationHandler(name: "surveyCategory")
        let surveyCategory = UIMutableUserNotificationCategory()
        surveyCategory.identifier = surveyNotificationHandler.getName()
        surveyCategory.setActions([notificationYes, notificationNo], for: UIUserNotificationActionContext.default)
        surveyCategory.setActions([notificationYes, notificationNo], for: UIUserNotificationActionContext.minimal)

        self.notificationHandlers[surveyNotificationHandler.getName()] = surveyNotificationHandler

        // Register for notification: This will prompt for the user's consent to receive notifications from this app.
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge],
                categories: [surveyCategory])

        // Registering UIUserNotificationSettings more than once results in previous settings being overwritten.
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
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


    func registerForRemoteNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (_, error) in
            if error == nil {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        var content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Buy some milk"
        content.sound = UNNotificationSound.default()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
                repeats: false)

        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                content: content, trigger: trigger)

        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }

    // Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("User Info = ", notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }

    // Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        print("User Info = ", response.notification.request.content.userInfo)
        completionHandler()
    }
}
