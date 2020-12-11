//
//  MessageViewModel.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine


class MessageViewModel: ObservableObject, Identifiable {
    
    @Published var message: Message
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(message: Message) {
        self.message = message
        
        $message.compactMap { msg in
            msg.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}
