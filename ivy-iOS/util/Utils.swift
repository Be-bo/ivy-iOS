//
//  Utils.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import SwiftUI

final class Utils {
    private init(){}
    
    static func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    static func getCampusUni() -> String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "campus_uni") ?? "ucalgary.ca"
    }
    
    static func setCampusUni(newUni: String){
        let defaults = UserDefaults.standard
        defaults.set(newUni, forKey: "campus_uni")
    }
    
    static func getCurrentTimeInMillis() -> Double{
        let since1970 = Date().timeIntervalSince1970*1000
        return since1970
    }
    
    static func convertDateToMillis(date: Date) -> Double {
        return date.timeIntervalSince1970*1000
    }
    
    static func convertMillisToDate(millis: Double) -> Date {
        return Date(timeIntervalSince1970: millis)
    }
    
    static func getEndOfThisWeekMillis() -> Double{
        if let thisWeekStartDate = Date(timeIntervalSince1970: getCurrentTimeInMillis()/1000).startOfWeek{ //set date to current time and set it to start of this week
            return thisWeekStartDate.timeIntervalSince1970*1000 + Constant.millisInAWeek //set time to exactly 1 week away from now
        }else{
            return getCurrentTimeInMillis() + Constant.millisInAWeek //if getting week start date fails -> simply use 1 week away from now
        }
    }
    
    static func getTodayMidnightMillis() -> Double{
        let cal = Calendar(identifier: .gregorian)
        let midnightMillis = cal.startOfDay(for: Date(timeIntervalSince1970: (getCurrentTimeInMillis()/1000) + Constant.millisInADay/1000)).timeIntervalSince1970 * 1000 //get start of tomorrow millis = midnight today
        return midnightMillis
    }
    
    
    static func postPath(postId: String, uni: String) -> String {
        return "universities/\(uni)/posts/\(postId)"
    }
    
    static func postFullVisualPath(postId: String) -> String {
        return "postfiles/\(postId)/\(postId).jpg"
    }
    
    static func postPreviewImagePath(postId: String) -> String {
        return "postfiles/\(postId)/previewimage.jpg"
    }
    
    static func postCommentsPath(commentId: String, uni: String, postId: String) -> String {
        return postPath(postId: postId, uni: uni) + "/comments/" + commentId
    }
    
    static func userPreviewImagePath(userId: String) -> String {
        return  "userfiles/" + userId + "/previewimage.jpg"
    }
    
    static func userProfileImagePath(userId: String) -> String {
        return  "userfiles/" + userId + "/profileimage.jpg"
    }
    
    static func getEventDate(millis: Int) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(millis/1000))
        return date.getFormattedDate(format: "yyyy-MM-dd HH:mm")
    }
    
    static func getUserPath(userId: String) -> String {
        return "users/\(userId)"
    }
    
    static func uniLogoPath() -> String{
        return "unilogos/\(Utils.getCampusUni()).png"
    }
    
    
}

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
