//
//  ExploreAllEventsItemView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ExploreAllEventsItemView: View {
    @ObservedObject var eventItemVM: EventItemViewModel
    @State var url = ""
    @State var authorUrl = ""
    @State var selection: Int? = nil
    var onCommit: (Event_new) -> (Void) = {_ in}
    
    var body: some View {
        
        NavigationLink(destination: EventScreenView(eventVM: eventItemVM).navigationBarTitle(Text(eventItemVM.event.name), displayMode: .inline), tag: 1, selection: self.$selection) {
                Button(action: {
                    self.selection = 1
                }){
                    HStack(){
                        
                        FirebaseImage(
                            path: self.eventItemVM.event.visual,
                            placeholder: AssetManager.logoGreen,
                            width: 100,
                            height: 100,
                            shape: RoundedRectangle(cornerRadius: 25)
                        )
                        
                        TextField("placeholder", text: $eventItemVM.event.name, onCommit: {
                            self.onCommit(self.eventItemVM.event)
                        })
                            .disabled(true)
                            .frame(width: 140, height: 50, alignment: .leading)
                            .padding(.leading, 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
    }
}

