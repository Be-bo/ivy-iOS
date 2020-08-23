//
//  CalendarUtil.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//

import EventKit
import SwiftUI

final class CalendarUtil {
    private init(){}
    
    static func addToCalendar(startDate: Date, endDate: Date, eventName: String, extras: String){
        checkPermission(startDate: startDate, endDate: endDate, eventName: eventName, extras: extras)
    }
    
    static func checkPermission(startDate: Date, endDate: Date, eventName: String, extras: String){
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event){
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (status, error) in
                if status{
                    self.insertEvent(store: eventStore, startDate: startDate, endDate: endDate, eventName: eventName, extras: extras)
                }
                else{
                    print(error?.localizedDescription)
                }
            }
            break
        case .restricted:
            print("Calendar restricted.")
            break
        case .denied:
            print("Calendar denied.")
            break
        case .authorized:
            self.insertEvent(store: eventStore, startDate: startDate, endDate: endDate, eventName: eventName, extras: extras)
            break
        @unknown default:
            print("Unknown.")
        }
    }
    
    static func insertEvent(store: EKEventStore, startDate: Date, endDate: Date, eventName: String, extras: String){
        let event = EKEvent(eventStore: store)
        event.calendar = store.defaultCalendarForNewEvents
        event.notes = extras
        event.startDate = startDate
        event.title = eventName
        event.endDate = endDate
        do{
            try store.save(event, span: .thisEvent)
        }catch{
            print(error.localizedDescription)
        }
    }
}
