//
//  EventItemViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class EventItemViewModel: ObservableObject, Identifiable{
    @Published var event: Event //published means that this var will be listened to
    var id = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Event){
        self.event = event
        
        $event.compactMap { event in
            event.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}
