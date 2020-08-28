//
//  EventRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class EventRepo: ObservableObject{
    let creationMillis = Utils.getCurrentTimeInMillis()
    let db = Firestore.firestore()
    @Published var upcomingEvents = [Event]()
    @Published var thisWeekEvents = [Event]()
    @Published var todayEvents = [Event]()
    @Published var featuredEvents = [Event]()
    @Published var exploreAllEvents = [Event]()
    @Published var eventsLoaded = false
    
    init() {
        self.loadFeatured()
        self.loadTodayEvents()
        self.loadThisWeekEvents()
        self.loadUpcomingEvents()
    }
    
    func loadExploreAll(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("start_millis", isGreaterThan: Utils.getCurrentTimeInMillis())
            .order(by: "start_millis").getDocuments{(querySnapshot, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        self.exploreAllEvents.append(newEvent)
                    }
                }
        }
    }
    
    func loadUpcomingEvents(){
        upcomingEvents = [Event]()
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("is_featured", isEqualTo: false).whereField("start_millis", isGreaterThan: Int(Utils.getEndOfThisWeekMillis())) //end of this week's millis
            .order(by: "start_millis").limit(to: 15).getDocuments{(querySnapshot, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        if(!newEvent.is_featured){
                            self.upcomingEvents.append(newEvent)
                        }
                    }
                    //TODO: set up Codable once we have more time, and add it to the other loads
                    //                    self.events = querSnap.documents.compactMap{document in
                    //                        print(document.data())
                    //                        return try? document.data(as: Event.self)
                    //                    }
                }
                self.eventsLoaded = true
        }
    }
    
    func loadThisWeekEvents(){
        thisWeekEvents = [Event]()
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("start_millis", isGreaterThan: Utils.getTodayMidnightMillis()).whereField("start_millis", isLessThan: Utils.getEndOfThisWeekMillis())
            .order(by: "start_millis").getDocuments{(querySnapshot, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        if(!newEvent.is_featured){
                            self.thisWeekEvents.append(newEvent)
                        }
                    }
                }
        }
    }
    
    func loadTodayEvents(){
        todayEvents = [Event]()
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("start_millis", isGreaterThan: Utils.getCurrentTimeInMillis()).whereField("start_millis", isLessThan: Utils.getTodayMidnightMillis())
            .order(by: "start_millis").getDocuments{(querySnapshot, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        if(!newEvent.is_featured){
                            self.todayEvents.append(newEvent)
                        }
                    }
                }
        }
    }
    
    func loadFeatured(){
        eventsLoaded = false
        featuredEvents = [Event]()
        db.collection("universities").document(Utils.getCampusUni()).getDocument(completion: { (docSnap, error) in
            if error != nil{
                print("Error loading this uni.")
                return
            }
            
            if let featuredId = docSnap?.get("featured_id") as? String{
                self.db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(featuredId).getDocument(completion: { (docSnap1, error1) in
                    if error1 != nil{
                        print("Error loading featured event.")
                        return
                    }
                    if let doc = docSnap1 {
                        let featuredEvent = Event()
                        featuredEvent.docToObject(doc: doc)
                        self.featuredEvents.append(featuredEvent)
                    }
                })
            }
        })
    }
    
    func refresh(){
        self.eventsLoaded = false
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("creation_millis", isGreaterThan: creationMillis).whereField("is_featured", isEqualTo: false).getDocuments{(querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        var dontAdd = false
                        
                        if(newEvent.start_millis > Int(self.creationMillis) && newEvent.start_millis <= Int(Utils.getTodayMidnightMillis())){ //if the refreshed event is today
                            for todayEvent in self.todayEvents{
                                if(todayEvent.id == newEvent.id){
                                    dontAdd = true
                                    break
                                }
                            }
                            if(!dontAdd){
                                self.todayEvents.insert(newEvent, at: 0)
                            }
                            
                        }else if(newEvent.start_millis > Int(Utils.getTodayMidnightMillis()) && newEvent.start_millis <= Int(Utils.getEndOfThisWeekMillis())){ //if the refreshed event is this week
                            for thisWeekEvent in self.thisWeekEvents{
                                if(thisWeekEvent.id == newEvent.id){
                                    dontAdd = true
                                    break
                                }
                            }
                            if(!dontAdd){
                                self.thisWeekEvents.insert(newEvent, at: 0)
                            }
                            
                        }else{ //if the refreshed event is upcoming
                            for upcomingEvent in self.upcomingEvents{
                                if(upcomingEvent.id == newEvent.id){
                                    dontAdd = true
                                    break
                                }
                            }
                            if(!dontAdd){
                                self.upcomingEvents.insert(newEvent, at: 0)
                            }
                        }
                        
                        self.eventsLoaded = true
                    }
                }
        }
    }
}
