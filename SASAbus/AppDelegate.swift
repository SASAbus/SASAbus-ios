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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CoreData
import DrawerController
import Alamofire
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , CLLocationManagerDelegate{

    var window: UIWindow?
    var drawerController: DrawerController!
    var beaconObserver:SurveyBeaconObserver! = SurveyBeaconObserver(beaconHandler:SurveyBeaconHandler(surveyAction: NotificationAction(), uuid:Configuration.beaconUid, identifier:Configuration.beaconIdentifier))
    var beaconObserverStation:BusStopBeaconObserver! = BusStopBeaconObserver(beaconHandler: StationDetectionBeaconHandler(uuid: Configuration.busStopBeaconUid, identifier: Configuration.busStopBeaconIdentifier))
    var notificationHandlers:[String:NotificationProtocol] = [String:NotificationProtocol]()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BadgeHelper.instance.clearBadges()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.translucent = false
        navigationBarAppearace.tintColor = Theme.colorWhite  // Back buttons and such
        navigationBarAppearace.barTintColor = Theme.colorOrange  // Bar's background color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:Theme.colorWhite]  // Title's text color
        self.startDownloadSplashScreen()
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        //let gai = GAI.sharedInstance()
        //gai.trackUncaughtExceptions = true  // report uncaught exceptions
        //gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        return true
    }
    
    func startDownloadSplashScreen() {
        
        let delegate = DownloadDataFinished()
        delegate.appDelegate = self;
        let downlodViewController = DownloadViewController(nibName: "DownloadViewController", bundle: nil, downloader: SasaBusDownloader(), downloadFinishedDelegate:delegate, canBeCanceled:false, showFinishedDialog:false);
        downlodViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.window!.rootViewController = downlodViewController
    }
    
    func startApplication() {
        
        //start listening to beacons
        self.beaconObserver.startObserving()
        self.beaconObserverStation.startObserving()
        self.registerForLocalNotifications()
        
        // Ask for Authorisation from the User.
        CLLocationManager().requestAlwaysAuthorization()
        // For use in foreground
        CLLocationManager().requestWhenInUseAuthorization()
        
        
        let navigationController = getNavigationController(Menu.items[0].viewController!)
        let menuViewController: MenuViewController! = MenuViewController(nibName: "MenuViewController", bundle: nil)
        self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: menuViewController)
        let selectedMenuItemIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        menuViewController.tableView.selectRowAtIndexPath(selectedMenuItemIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        menuViewController.tableView.cellForRowAtIndexPath(menuViewController.tableView.indexPathForSelectedRow!)?.setSelected(true, animated: false)
        self.drawerController.showsShadows = false;
        self.drawerController.openDrawerGestureModeMask = OpenDrawerGestureMode.BezelPanningCenterView
        self.drawerController.closeDrawerGestureModeMask = CloseDrawerGestureMode.PanningCenterView
        self.window!.rootViewController = self.drawerController
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "it.sasabz.ios.SASAbus" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SASAbus", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        BadgeHelper.instance.clearBadges()
        if notificationHandlers.keys.contains(notification.category!) {
            let notificationHandler = notificationHandlers[notification.category!]
            notificationHandler!.handleNotificationForeground(self.window!.rootViewController!, userInfo:notification.userInfo)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        BadgeHelper.instance.clearBadges()
        if notificationHandlers.keys.contains(notification.category!) {
            let notificationHandler = notificationHandlers[notification.category!]
            notificationHandler?.handleNotificationBackground(identifier, userInfo:notification.userInfo)
        }
        completionHandler()
    }

    
    func registerForLocalNotifications() {
        // Specify the notification actions.
        let notificatonYes = UIMutableUserNotificationAction()
        notificatonYes.identifier = "Yes"
        notificatonYes.title = NSLocalizedString("Yes", comment: "")
        notificatonYes.activationMode = UIUserNotificationActivationMode.Background
        notificatonYes.destructive = false
        notificatonYes.authenticationRequired = false
        
        let notificatonNo = UIMutableUserNotificationAction()
        notificatonNo.identifier = "No"
        notificatonNo.title = NSLocalizedString("No", comment: "")
        notificatonNo.activationMode = UIUserNotificationActivationMode.Foreground
        notificatonNo.destructive = true
        notificatonNo.authenticationRequired = false
        
        // Create a category with the above actions
        let surveyNotificationHandler = SurveyNotificationHandler(name:"surveyCategory")
        let surveyCategory = UIMutableUserNotificationCategory()
        surveyCategory.identifier = surveyNotificationHandler.getName()
        surveyCategory.setActions([notificatonYes, notificatonNo], forContext: UIUserNotificationActionContext.Default)
        surveyCategory.setActions([notificatonYes, notificatonNo], forContext: UIUserNotificationActionContext.Minimal)
        
        
        self.notificationHandlers[surveyNotificationHandler.getName()] = surveyNotificationHandler
        
        // Register for notification: This will prompt for the user's consent to receive notifications from this app.
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: Set(arrayLiteral: surveyCategory))
        // Registering UIUserNotificationSettings more than once results in previous settings being overwritten.
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func navigateTo(viewController: UIViewController) {
        self.drawerController!.centerViewController = self.getNavigationController(viewController)
        let menuViewController = self.drawerController!.leftDrawerViewController as! MenuViewController
        let row = Menu.items.indexOf({$0.viewController!.isKindOfClass(viewController.dynamicType)})
        if row != nil {
            menuViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: row!, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
        if self.drawerController!.openSide != DrawerSide.None {
            self.drawerController!.toggleDrawerSide(DrawerSide.Left, animated: true, completion: nil)
        }
    }
    
    func getNavigationController(viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    class DownloadMapFinished: DownloadFinishedProtocol {
        weak var appDelegate: AppDelegate! = nil
        func finished() {
            self.appDelegate.startApplication()
        }
        func error() {
            self.finished()
        }
    }
    
    class DownloadDataFinished: DownloadFinishedProtocol {
        
        weak var appDelegate: AppDelegate! = nil
        
        func finished() {
            //getting privacy
            Alamofire.request(PrivacyApiRouter.GetPrivacyHtml("ios")).responseString { response in
                if response.result.isSuccess {
                    let privacyHtml = response.result.value!
                    UserDefaultHelper.instance.setPrivacyHtml(privacyHtml)
                }
            }
            
            if UserDefaultHelper.instance.getMapDownloadStatus() == false &&
                UserDefaultHelper.instance.shouldAskForMapDownload() {
                let delegate = DownloadMapFinished()
                delegate.appDelegate = self.appDelegate;
                let downlodViewController = DownloadViewController(nibName: "DownloadViewController", bundle: nil, downloader: MapTilesDownloader(), downloadFinishedDelegate:delegate, canBeCanceled:true, showFinishedDialog:true, askForDownload:true);
                downlodViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                self.appDelegate.window!.rootViewController = downlodViewController
            } else {
                self.appDelegate.startApplication()
            }
        }
        
        func error() {
            exit(0)
        }
    }

}


protocol DownloadFinishedProtocol {
    func finished()
    func error()
}
