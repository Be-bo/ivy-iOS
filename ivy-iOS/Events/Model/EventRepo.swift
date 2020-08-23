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
    let db = Firestore.firestore()
    @Published var upcomingEvents = [Event]()
    @Published var thisWeekEvents = [Event]()
    @Published var todayEvents = [Event]()
    @Published var featuredEvents = [Event]()
    @Published var exploreAllEvents = [Event]()
    
    init() {
        print("calling load events")
        self.loadUpcomingEvents()
        self.loadThisWeekEvents()
        self.loadTodayEvents()
        self.loadFeatured()
    }
    
    func loadExploreAll(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("start_millis", isGreaterThan: Utils.getCurrentTimeInMillis())
            .order(by: "start_millis").getDocuments{(querySnapshot, error) in
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
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("is_featured", isEqualTo: false).whereField("start_millis", isGreaterThan: Int(Utils.getEndOfThisWeekMillis())) //end of this week's millis
            .order(by: "start_millis").limit(to: 20).getDocuments{(querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        self.upcomingEvents.append(newEvent)
                    }
                    //TODO: set up Codable once we have more time, and add it to the other loads
                    //                    self.events = querSnap.documents.compactMap{document in
                    //                        print(document.data())
                    //                        return try? document.data(as: Event.self)
                    //                    }
                }
        }
    }
    
    func loadThisWeekEvents(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("start_millis", isGreaterThan: Utils.getTodayMidnightMillis()).whereField("start_millis", isLessThan: Utils.getEndOfThisWeekMillis())
            .order(by: "start_millis").getDocuments{(querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        self.thisWeekEvents.append(newEvent)
                    }
                }
        }
    }
    
    func loadTodayEvents(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: true).whereField("start_millis", isGreaterThan: Utils.getCurrentTimeInMillis()).whereField("start_millis", isLessThan: Utils.getTodayMidnightMillis())
            .order(by: "start_millis").getDocuments{(querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newEvent = Event()
                        newEvent.docToObject(doc: currentDoc)
                        self.todayEvents.append(newEvent)
                    }
                }
        }
    }
    
    func loadFeatured(){
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
}
