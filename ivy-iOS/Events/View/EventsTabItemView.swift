//
//  EventsTabItem.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct EventsTabItemView: View {
    @ObservedObject var thisUserRepo = ThisUserRepo()
    @ObservedObject var eventItemVM: EventItemViewModel
    @State var url = ""
    @State var authorUrl = ""
    @State var selection: Int? = nil
    var onCommit: (Event) -> (Void) = {_ in}
    
    var body: some View {
        
        VStack(alignment: .leading) {
            NavigationLink( destination: EventScreenView(eventVM: eventItemVM).navigationBarTitle(Text(eventItemVM.event.name), displayMode: .inline), tag: 1, selection: self.$selection) {
                Button(action: {
                    self.selection = 1
                }){
                    
                    FirebasePostImage(
                        path: self.eventItemVM.event.visual,
                        width: 200,
                        height: 200
                    )
                    .buttonStyle(PlainButtonStyle()) //an extremely reta*ded situation, only doesn't overlay the image with button color when all 3 of these have PlainButtonStyle applied at the same time
                }
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
            
            
        
            HStack{
                
                FirebaseImage(
                    path: Utils.userPreviewImagePath(userId: self.eventItemVM.event.author_id),
                    placeholder: Image(systemName: "person.crop.circle.fill"),
                    width: 40,
                    height: 40,
                    shape: RoundedRectangle(cornerRadius: 25)
                )
                
                Text(eventItemVM.event.name)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 50, alignment: .leading)
                    .padding(.leading, 5)
            }
        }
    }
}
