//
//  EventsTabView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

//TODO: consider using this for loading
//struct ImgLoader: UIViewRepresentable{
//
//    func makeUIView(context: UIViewRepresentableContext<ImgLoader>) -> UIActivityIndicatorView {
//        let indicator = UIActivityIndicatorView(style: .medium)
//        indicator.startAnimating()
//        return indicator
//    }
//
//    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ImgLoader>) {
//
//    }
//}

struct EventsTabView: View {
    @ObservedObject var uniInfo = UniInfo()
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    @State private var settingsPresented = false
    @State private var createPostOrLoginPresented = false
    @State private var notificationCenterPresented = false
    @ObservedObject var eventTabVM = EventTabViewModel()
    var screenWidth: CGFloat = 300.0
    @State var featuredUrl = ""
    @State var eventScreenPresented = false
    @State var loginPresented = false
    @State var selection: Int? = nil
    @State private var loggedIn = false
    var onCommit: (User) -> (Void) = {_ in}
    
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false){
                
                // MARK: Loading
                if !eventTabVM.eventRepo.eventsLoaded {
                    LoadingSpinner().frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .center)
                }

                    // MARK: Empty Text
                if(eventTabVM.featuredEventVMs.count < 1 && eventTabVM.todayEventVMs.count < 1 && eventTabVM.thisWeekEventVMs.count < 1 && eventTabVM.upcomingEventVMs.count < 1){
                    Text("No events on this campus right now!").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(30)
                }
                
                // MARK: Featured
                if(eventTabVM.featuredEventVMs.count > 0){
                    HStack{
                        Text("Featured").font(.system(size: 25))
                        Spacer()
                    }.padding(.leading)
                }
                VStack(alignment: .leading){
                    ForEach(eventTabVM.featuredEventVMs){ eventItemVM in
                        NavigationLink(destination: EventScreenView(eventVM: eventItemVM).navigationBarTitle(eventItemVM.event.name), tag: 1, selection: self.$selection) {
                            Button(action: {
                                self.selection = 1
                            }){
                                WebImage(url: URL(string: self.featuredUrl))
                                    .resizable()
                                    .placeholder(AssetManager.logoWhite)
                                    .background(AssetManager.ivyLightGrey)
                                    .frame(width: self.screenWidth-20, height: self.screenWidth - 20)
                                    .cornerRadius(30)
                                    .onAppear(){
                                        let storage = Storage.storage().reference()
                                        storage.child(eventItemVM.event.visual).downloadURL { (url, err) in
                                            if err != nil{
                                                print("Error loading featured image.")
                                                return
                                            }
                                            self.featuredUrl = "\(url!)"
                                        }
                                }
                                    .buttonStyle(PlainButtonStyle()) //an extremely reta*ded situation, only doesn't overlay the image with button color when all 3 of these have PlainButtonStyle applied at the same time
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 30)
                
                
                
                
                // MARK: Today
                if(eventTabVM.todayEventVMs.count > 0){
                    VStack(alignment: .leading){
                        Text("Today").font(.system(size: 25)).padding(.leading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(eventTabVM.todayEventVMs) { eventItemVM in
                                    EventsTabItemView(eventItemVM: eventItemVM, screenWidth: self.screenWidth)
                                }
                            }.padding()
                                .frame(width: CGFloat(eventTabVM.todayEventVMs.count*210 + 10) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
                                    , height: 260, alignment: .leading)
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                
                
                
                // MARK: This Week
                if(eventTabVM.thisWeekEventVMs.count > 0){
                    VStack(alignment: .leading){
                        Text("This Week").font(.system(size: 25)).padding(.leading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(eventTabVM.thisWeekEventVMs) { eventItemVM in
                                    EventsTabItemView(eventItemVM: eventItemVM, screenWidth: self.screenWidth)
                                }
                            }.padding()
                                .frame(width: CGFloat(eventTabVM.thisWeekEventVMs.count*210 + 10) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
                                    , height: 260, alignment: .leading)
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                
                
                
                // MARK: Upcoming
                if(eventTabVM.upcomingEventVMs.count > 0){
                    VStack(alignment: .leading){
                        Text("Upcoming").font(.system(size: 25)).padding(.leading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(eventTabVM.upcomingEventVMs) { eventItemVM in
                                    EventsTabItemView(eventItemVM: eventItemVM, screenWidth: self.screenWidth)
                                }
                            }.padding()
                                .frame(width: CGFloat(eventTabVM.upcomingEventVMs.count*210 + 10) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
                                    , height: 260, alignment: .leading)
                        }
                        .padding(.bottom, 30)
                    }
                    
                    
                    
                    
                    // MARK: Explore All
                    NavigationLink(destination: ExploreAllEventsView(eventTabVM: self.eventTabVM, screenWidth: self.screenWidth).navigationBarTitle("All Events", displayMode: .large), tag: 2, selection: $selection) {
                        Button(action: {
                            self.selection = 2
                            if (self.eventTabVM.exploreAllEventsVMs.count < 1){ //if we haven't loaded explore all events yet, load them now
                                self.eventTabVM.eventRepo.loadExploreAll()
                            }
                        }){
                            Text("Explore All")
                        }
                            .buttonStyle(StandardButtonStyle(disabled: eventTabVM.upcomingEventVMs.count < 1)) //setting button style where background color changes based on if input is ok
                            .padding()
                    }
                }
            }
                
                
                //MARK: Nav Bar
                .navigationBarItems(leading:
                    HStack {
                        Button(action: {
                            self.settingsPresented.toggle()
                        }) {
                            Image(systemName: "gear").font(.system(size: 25))
                                .sheet(isPresented: $settingsPresented){
                                    SettingsView(uniInfo: self.uniInfo, thisUserRepo: self.thisUserRepo)
                            }
                        }
                        
                        WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                            .resizable()
                            .placeholder(AssetManager.uniLogoPlaceholder)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(.leading, (UIScreen.screenWidth/2 - 75))
                            .onAppear(){
                                let storage = Storage.storage().reference()
                                storage.child(Utils.uniLogoPath()).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading uni logo image.")
                                        return
                                    }
                                    self.uniInfo.uniLogoUrl = "\(url!)"
                                }
                        }
                        
                    }.padding(.leading, 0), trailing:
                    HStack {
                        Button(action: {
                            self.createPostOrLoginPresented.toggle()
                        }) {
                            Image(systemName: thisUserRepo.userLoggedIn ? "square.and.pencil" : "arrow.right.circle").font(.system(size: 25))
                                .sheet(isPresented: $createPostOrLoginPresented){
                                    if(self.thisUserRepo.userLoggedIn){
                                        CreatePostView(thisUser: self.thisUserRepo.user)
                                    }else{
                                        LoginView()
                                    }
                            }
                        }
                })
        }
    }
}
