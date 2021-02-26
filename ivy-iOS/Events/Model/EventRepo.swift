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
    
    //Pagination
    let loadLimit = 20
    var lastPulledDoc: DocumentSnapshot?
    @Published var exploreAllEventsLoaded = false
    
    init() {
        self.loadFeatured()
        self.loadTodayEvents()
        self.loadThisWeekEvents()
        self.loadUpcomingEvents()
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
                    
                    
                    /*
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        if(!newEvent.is_featured){
                            self.upcomingEvents.append(newEvent)
                        }
                    }*/
                    self.upcomingEvents = querSnap.documents.compactMap{ document -> Event? in
                        if (document.get("is_featured") ?? false) as! Bool {
                            return try? document.data(as: Event.self)
                        }
                        return nil
                    }
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
                    self.thisWeekEvents = querSnap.documents.compactMap{ document -> Event? in
                        if (document.get("is_featured") as? Bool) ?? false  {
                            return try? document.data(as: Event.self)
                        }
                        return nil
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
                    self.todayEvents = querSnap.documents.compactMap{ document -> Event? in
                        if (document.get("is_featured") as? Bool) ?? false {
                            return try? document.data(as: Event.self)
                        }
                        return nil
                    }
                }
        }
    }
    
    func loadFeatured(){
        eventsLoaded = false
        
        db.collection("universities").document(Utils.getCampusUni()).getDocument(completion: { (docSnap, error) in
            if error != nil{
                print("Error loading this uni.")
                return
            }
            
            if let featuredId = docSnap?.get("featured_id") as? String{
                self.db.document(Post.postPath(featuredId)).getDocument(completion: { (docSnap1, error1) in
                    if error1 != nil{
                        print("Error loading featured event.")
                        return
                    }
                    if let doc = docSnap1 {
                        let newEvent = try? doc.data(as: Event.self)
                        if (newEvent != nil){
                            self.featuredEvents.append(newEvent!)
                        } else {
                            print("Could not load event in EventRepo.refresh(): nil event")
                        }
                    }
                })
            }
        })
    }
    
    // Paginated: fetch events (start = true if this is first batch)
    func loadExploreAll(start: Bool = false){
        if start {
            exploreAllEventsLoaded = false
            exploreAllEvents = [Event]() // reset list (maybe for reloading later)
        }
        
        var query = db.collection("universities").document(Utils.getCampusUni()).collection("posts")
            .whereField("is_event", isEqualTo: true)
            .whereField("start_millis", isGreaterThan: Utils.getCurrentTimeInMillis())
            .order(by: "start_millis")
                        
        // Fetch next batch if this is not the first
        if (lastPulledDoc != nil && !start) {
            query = query.start(afterDocument: lastPulledDoc!)
        }
                
        query.limit(to: loadLimit).getDocuments{(querySnapshot, error) in
            if error != nil{
                print(error ?? "")
                self.exploreAllEventsLoaded = true
                return
            }
            if let querSnap = querySnapshot{
                self.exploreAllEvents.append(contentsOf: querSnap.documents.compactMap { document in
                    if (document.get("is_featured") as? Bool) ?? false {
                        return try? document.data(as: Event.self)
                    }
                    return nil
                })
                if !querSnap.isEmpty {
                    self.lastPulledDoc = querSnap.documents[querSnap.documents.count-1]
                }
                
                // i.e Did we pull all the events?
                if (querSnap.documents.count < self.loadLimit) {
                    self.exploreAllEventsLoaded = true
                }
            }
        }
    }
    
    // Refresh
    func refresh(){
        self.eventsLoaded = false
        db.collection("universities").document(Utils.getCampusUni()).collection("posts")
            .whereField("is_event", isEqualTo: true)
            .whereField("creation_millis", isGreaterThan: creationMillis)
            .whereField("is_featured", isEqualTo: false)
            .getDocuments{ (querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        
                        var newEvent : Event? = nil
                        do { try newEvent = currentDoc.data(as: Event.self)! }
                        catch { print("Could not load event in EventRepo.refresh(): \(error)") }
                        
                        if (newEvent == nil) { continue } // Skip the rest if didn't load properly
                        
                        var add = false
                        
                        if (newEvent!.start_millis > Int(self.creationMillis) && newEvent!.start_millis <= Int(Utils.getTodayMidnightMillis())){ //if the refreshed event is today
                            for todayEvent in self.todayEvents{
                                if(todayEvent.id == newEvent!.id){
                                    add = true
                                    break
                                }
                            }
                            if(add){
                                self.todayEvents.insert(newEvent!, at: 0)
                            }
                            
                        } else if (newEvent!.start_millis > Int(Utils.getTodayMidnightMillis()) && newEvent!.start_millis <= Int(Utils.getEndOfThisWeekMillis())){ //if the refreshed event is this week
                            for thisWeekEvent in self.thisWeekEvents{
                                if(thisWeekEvent.id == newEvent!.id){
                                    add = true
                                    break
                                }
                            }
                            if(add){
                                self.thisWeekEvents.insert(newEvent!, at: 0)
                            }
                            
                        } else { //if the refreshed event is upcoming
                            for upcomingEvent in self.upcomingEvents{
                                if(upcomingEvent.id == newEvent!.id){
                                    add = true
                                    break
                                }
                            }
                            if(add){
                                self.upcomingEvents.insert(newEvent!, at: 0)
                            }
                        }
                        self.eventsLoaded = true
                    }
                }
        }
    }
}
