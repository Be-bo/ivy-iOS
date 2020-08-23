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
    var onCommit: (Event) -> (Void) = {_ in}
    
    var body: some View {
        
        VStack(alignment: .leading){
            WebImage(url: URL(string: url)) //TODO: event image
                .resizable()
                .placeholder(AssetManager.logoWhite)
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
            
            HStack{
                WebImage(url: URL(string: authorUrl)) //TODO: author image
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
                TextField("placeholder", text: $eventItemVM.event.name, onCommit: {
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
