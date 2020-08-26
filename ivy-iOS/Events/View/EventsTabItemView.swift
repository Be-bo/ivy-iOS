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
    @ObservedObject var eventItemVM: EventItemViewModel
    @State var url = ""
    @State var authorUrl = ""
    @State var selection: Int? = nil
    var screenWidth: CGFloat = 300
    var onCommit: (Event) -> (Void) = {_ in}
    
    var body: some View {
        
        VStack(alignment: .leading){
            NavigationLink(destination: EventScreenView(eventVM: eventItemVM).navigationBarTitle(eventItemVM.event.name), tag: 1, selection: self.$selection) {
                Button(action: {
                    self.selection = 1
                }){
                    WebImage(url: URL(string: url))
                        .resizable()
                        .placeholder(AssetManager.logoWhite)
                        .aspectRatio(1, contentMode: .fit)
                        .background(AssetManager.ivyLightGrey)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(self.eventItemVM.event.visual).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading event image.")
                                    return
                                }
                                self.url = "\(url!)"
                            }
                    }

                    .buttonStyle(PlainButtonStyle()) //an extremely reta*ded situation, only doesn't overlay the image with button color when all 3 of these have PlainButtonStyle applied at the same time
                }
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
            
            
        
            HStack{
                WebImage(url: URL(string: authorUrl))
                    .resizable()
                    .placeholder(Image(systemName: "person.crop.circle.fill"))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onAppear(){
                        let storage = Storage.storage().reference()
                        storage.child(Utils.userPreviewImagePath(userId: self.eventItemVM.event.author_id)).downloadURL { (url, err) in
                            if err != nil{
                                print("Error loading event image.")
                                return
                            }
                            self.authorUrl = "\(url!)"
                        }
                }
                TextField("Name", text: $eventItemVM.event.name, onCommit: {
                    self.onCommit(self.eventItemVM.event)
                })
                    .disabled(true)
                    .frame(width: 140, height: 50, alignment: .leading)
                    .padding(.leading, 5)
            }
        }
    }
}


//struct EventsTabItem_Previews: PreviewProvider {
//    static var previews: some View {
//        EventsTabItemView()
//    }
//}
