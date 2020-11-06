//
//  EventListViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class EventTabViewModel: ObservableObject {
    
    var currentUni = Utils.getCampusUni()
    @Published var eventRepo = EventRepo()
    @Published var upcomingEventVMs = [EventItemViewModel]()
    @Published var thisWeekEventVMs = [EventItemViewModel]()
    @Published var todayEventVMs = [EventItemViewModel]()
    @Published var featuredEventVMs = [EventItemViewModel]()
    @Published var exploreAllEventsVMs = [EventItemViewModel]()
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        
        //explore all
        eventRepo.$exploreAllEvents.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.exploreAllEventsVMs, on: self)
        .store(in: &cancellables)
        
        //featured
        eventRepo.$featuredEvents.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.featuredEventVMs, on: self)
        .store(in: &cancellables)
        
        //upcoming
        eventRepo.$upcomingEvents.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.upcomingEventVMs, on: self)
        .store(in: &cancellables)

        //this week
        eventRepo.$thisWeekEvents.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.thisWeekEventVMs, on: self)
        .store(in: &cancellables)
        
        //today
        eventRepo.$todayEvents.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.todayEventVMs, on: self)
        .store(in: &cancellables)
    }
    
    func reloadData(){
        eventRepo.loadFeatured()
        eventRepo.loadTodayEvents()
        eventRepo.loadThisWeekEvents()
        eventRepo.loadUpcomingEvents()
    }
    
    func refresh(){
        eventRepo.refresh()
    }
}
