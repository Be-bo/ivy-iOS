//
//  AppDelegate.swift
//  ivy
//
//  Created by Robert on 2019-06-02.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotificationsUI
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"


    //has to be done here to ensure the reference to the database is setup.
    override init() {
        super.init()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        


        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.ivyGreen
        UIBarButtonItem.appearance().tintColor = UIColor.ivyGreen
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.ivyGreen
        UITabBar.appearance().unselectedItemTintColor = UIColor.ivyGrey
        

        
        //Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        //delete old token
        let instance = InstanceID.instanceID()
        instance.deleteID { (error) in
            print(error.debugDescription)
        }
        //Request for new token
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        application.registerForRemoteNotifications()
        
        

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("user info: ", userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("unable to register for notfications", error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let baseDatabaseReference = Firestore.firestore()   //reference to the database

        print("APNS token retrieved",deviceToken)
        Messaging.messaging().apnsToken = deviceToken
        

        
        if let id = Auth.auth().currentUser?.uid as? String{
            //on token refresh update the auth users FCM token
            if let refreshedToken = Messaging.messaging().fcmToken {
                print("InstanceID token: \(refreshedToken)")
                var tokenMerger = Dictionary<String,Any>()
                tokenMerger["messaging_token"] = refreshedToken
                baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(id).setData(tokenMerger, merge: true)
            }
        }
        
    }

   

}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        debugPrint(userInfo)
        //Handle the notification ON APP
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([.sound,.alert,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let baseDatabaseReference = Firestore.firestore()
                 
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        
        
        //main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        

        // instantiate the view controller we want to show from storyboard
        // root nav is the main navigation controller we have
        //then extract the main tab bar controller so we can get the next navivation controller
        //then get the chat navigation controller from that tab bar
        //our order is NAV --> TAB BAR --> NAV. Thats why our root is the first nav and we go from there
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "ChatRoom") as? ChatRoom,
            let rootNav = self.window?.rootViewController as? UINavigationController,
            let mainTabBarController = rootNav.topViewController as? UITabBarController,
            let chatNavController = mainTabBarController.selectedViewController as? UINavigationController{
            
                //from the request being sent in, extract the conversation id so we know which chat to goto
                conversationVC.conversationID = response.notification.request.content.userInfo["conversationID"] as! String
            
                
                //TODO: change the domain to be grabbed dynamically not jsut "ucalgary.ca"
                //get the current signed in user to pull that persons user object so that can be passed to the chat
                var user = Auth.auth().currentUser;
                if let user = user {
                    let uid = user.uid  //user id unique to firebase project
                    
                    baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let userObject = document.data()
                            conversationVC.thisUserProfile = userObject!    //must exist here of doc data wont exists
                            
                            
                            //actually push the view controller after the user object is loadeed
                            // you can access custom data of the push notification by using userInfo property
                            // response.n otification.request.content.userInfo
                            chatNavController.popViewController(animated: true)    //pop first so it doesn't add a bunch in a row.
                            chatNavController.pushViewController(conversationVC, animated: true)
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
                
        }
        
        //Handle the notification ON BACKGROUND
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
    

    
    
    
}
// [END ios_10_message_handling]


extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let baseDatabaseReference = Firestore.firestore()   //reference to the database

        //when new registration token is made update it for the user
        if let id = Auth.auth().currentUser?.uid as? String{
            var tokenMerger = Dictionary<String,Any>()
            tokenMerger["messaging_token"] = fcmToken
            baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(id).setData(tokenMerger, merge: true)
        }
        
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Message Data", remoteMessage.appData)
    }
    
    
    
}

