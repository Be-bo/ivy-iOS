//
//  QuadCardView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct QuadCardView: View {
    
    @ObservedObject var userVM: UserViewModel
    
    
    var body: some View {
        ZStack {
            
            FirebaseCardImage(
                path: Utils.userProfileImagePath(userId: self.userVM.id),
                width: .infinity,
                shape: RoundedRectangle(cornerRadius: 25)
            )
            
            VStack {
                Spacer()
                Text(userVM.user.name).foregroundColor(.red)
            }

        }
        
        /* TODO:
         * display as cards: large event items
         * person's name, degree, chat button
         * remove from quad if chat created
         * if tapped, go to profile
         
         */
    }
}
