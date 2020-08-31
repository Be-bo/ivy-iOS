//
//  NotificationSender.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-30.
//  Copyright © 2020 ivy. All rights reserved.
//

import UIKit
class NotificationSender {
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
        request.setValue("key=AAAAnkRkLE8:APA91bHIsRG-JlN8SzFMgjhNFDYgfLMFz3EIl6FF3Urg-LmuE9iGcPPbaiQOQVvVpfBjL8aG27VDObBXBakaZP3j-vsRd1EhESey2e21FJt5N_Eb84pVo2x8MEvMc4mEto9gfL2BtUNT", forHTTPHeaderField: "Authorization")
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

//self.sender.sendPushNotification(to: usersMessagingToken, title: authorFirstName + " " + authorLastName, body: messageText, conversationID: conversationID)

