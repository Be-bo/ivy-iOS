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
    var thisUserIsOrg: Bool
    @ObservedObject var eventItemVM: EventItemViewModel
    @State var url = ""
    @State var authorUrl = ""
    @State var selection: Int? = nil
    var onCommit: (Event) -> (Void) = {_ in}
    
    var body: some View {
        
        NavigationLink(destination: EventScreenView(thisUserIsOrg: self.thisUserIsOrg, eventVM: eventItemVM).navigationBarTitle(eventItemVM.event.name), tag: 1, selection: self.$selection) {
                Button(action: {
                    self.selection = 1
                }){
                    HStack(){
                        WebImage(url: URL(string: url))
                            .resizable()
                            .placeholder(AssetManager.logoWhite)
                            .background(AssetManager.ivyLightGrey)
                            .frame(width: 100, height: 100)
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

