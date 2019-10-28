//
//  PushNotificationSender.swift
//  ivy-iOS
//
//  Created by paul dan on 2019-10-25.
//  Copyright © 2019 ivy social network. All rights reserved.
//inspired from : https://www.iosapptemplates.com/blog/ios-development/push-notifications-firebase-swift-5

import UIKit
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, conversationID: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id", "conversationID": conversationID]

        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAVv0nWDk:APA91bFOjyt6MDIE_Y_gzg_akV__aqs-KCd5LUS9yysqa2L1EQJgca6lWJ3Fvyy6AY90AvD31CeQvVv-A98uTb93xh24VUOnDezXV1fX4Lms3yrT-_1-YbKCVxlVdsXFQ9jTDaiR8Zqh", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
