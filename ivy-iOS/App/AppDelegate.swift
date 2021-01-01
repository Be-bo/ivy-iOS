//
//  AppDelegate.swift
//  ivy-iOS
//
//  Created by Robert on 2020-07-08.
//  Copyright © 2020 ivy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotificationsUI
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    override init() {
        super.init()
    }
    
    
    // MARK: didFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
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
        
        Messaging.messaging().token { (token, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let token = token {
                print("Remote instance ID token: \(token)")
            }
        }
        
        
        
        //Messaging.messaging().shouldEstablishDirectChannel = true
        application.registerForRemoteNotifications()
        
        return true
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
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    // MARK: didReceiveRegistrationToken
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if(Auth.auth().currentUser != nil){ //update token in db
            let db = Firestore.firestore()
            if let thisUserID = Auth.auth().currentUser?.uid {
                if !thisUserID.isEmpty {
                    db.document(Utils.getUserPath(userId: thisUserID)).updateData([
                        "messaging_token": fcmToken
                    ])
                }
            }
        }
        //Messaging.messaging().shouldEstablishDirectChannel = true
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    private func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }    
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        //if let messageID = userInfo[gcmMessageIDKey] {
            //            debugPrint("Message ID: \(messageID)")
        //}
        //        debugPrint(userInfo)
        //Handle the notification ON APP
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([.sound,.alert,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //let baseDatabaseReference = Firestore.firestore()
        
        let userInfo = response.notification.request.content.userInfo
        
        //Handle the notification ON BACKGROUND
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
    
}
