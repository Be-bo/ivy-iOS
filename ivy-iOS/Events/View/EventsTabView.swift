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
    @State var shouldScroll = true
    @State private var uniUrl = ""
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    
    @State private var settingsPresented = false
    @State private var createPostPresented = false
    @State private var loginPresented = false
    @State private var notificationCenterPresented = false
    @State var eventScreenPresented = false
    
    @ObservedObject var eventTabVM = EventTabViewModel()
    @State var featuredUrl = ""
    @State private var showingFeaturedAlert = false
    @State var selection: Int? = nil
    @State private var loggedIn = false
    var onCommit: (User) -> (Void) = {_ in}
    
    
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false){
                
                VStack{
                    
                    
                    // MARK: Featured
                    HStack{
                        Text("Featured").font(.system(size: 25))
                        Spacer()
                    }.padding(.leading)
                    
                    VStack(alignment: .leading){
                        ForEach(eventTabVM.featuredEventVMs){ eventItemVM in
                            ZStack{
                                FirebaseImage(
                                    path: eventItemVM.event.visual,
                                    placeholder: AssetManager.logoGreen,
                                    width: (UIScreen.screenWidth-20),
                                    height: (UIScreen.screenWidth-20),
                                    shape: RoundedRectangle(cornerRadius: 25)
                                )
                                .onTapGesture{
                                    self.selection = 1
                                }
                                
                                NavigationLink(destination: EventScreenView(eventVM: eventItemVM).navigationBarTitle(eventItemVM.event.name), tag: 1, selection: self.$selection) {
                                    EmptyView()
                                }
                            }
                        }
                        .padding(.bottom, 30)
                        
                        if(eventTabVM.featuredEventVMs.count < 1){
                            Button(action: {
                                self.showingFeaturedAlert = true
                            }){
                                AssetManager.featuredPlaceholder.resizable().frame(width: UIScreen.screenWidth-20, height: UIScreen.screenWidth/2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .alert(isPresented: self.$showingFeaturedAlert) {
                                Alert(title: Text("Feature Your Event"), message: Text("Interested? Shoot us an email at theivysocialnetwork@gmail.com."), dismissButton: .default(Text("OK")))
                            }
                        }
                    }
                    
                    // MARK: Empty Text
                    if(eventTabVM.featuredEventVMs.count < 1 && eventTabVM.todayEventVMs.count < 1 && eventTabVM.thisWeekEventVMs.count < 1 && eventTabVM.upcomingEventVMs.count < 1){
                        Text("No events on this campus right now!").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(30)
                    }
                    
                    
                    
                    
                    
                    // MARK: Today
                    if(eventTabVM.todayEventVMs.count > 0){
                        VStack(alignment: .leading){
                            Text("Today").font(.system(size: 25)).padding(.leading)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(eventTabVM.todayEventVMs) { eventItemVM in
                                        EventsTabItemView(eventItemVM: eventItemVM)
                                    }
                                }.padding()
                                .frame(width: CGFloat(eventTabVM.todayEventVMs.count*210 + 200) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
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
                                        EventsTabItemView(eventItemVM: eventItemVM)
                                    }
                                }.padding()
                                .frame(width: CGFloat(eventTabVM.thisWeekEventVMs.count*210 + 200) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
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
                                        EventsTabItemView(eventItemVM: eventItemVM)
                                    }
                                }.padding()
                                .frame(width: CGFloat(eventTabVM.upcomingEventVMs.count*210 + 200) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding + extra trial and error padding
                                       , height: 260, alignment: .leading)
                            }
                            .padding(.bottom, 30)
                        }
                        
                        
                        
                        
                        // MARK: Explore All
                        NavigationLink(destination: ExploreAllEventsView(eventTabVM: self.eventTabVM, screenWidth: UIScreen.screenWidth).navigationBarTitle("All Events", displayMode: .large), tag: 2, selection: $selection) {
                            Button(action: {
                                self.selection = 2
                            }){
                                Text("Explore All")
                            }
                            .buttonStyle(StandardButtonStyle(disabled: eventTabVM.upcomingEventVMs.count < 1)) //setting button style where background color changes based on if input is ok
                            .padding()
                        }
                    }
                }.padding(.horizontal, 20)
                
                
            }
            .padding(.horizontal, -20)
            //MARK: Nav Bar
            .navigationBarItems(leading:
                                    HStack {
                                        Button(action: {
                                            self.settingsPresented.toggle()
                                        }) {
                                            Image(systemName: "gear").font(.system(size: 25))
                                                .sheet(isPresented: $settingsPresented, onDismiss: {
                                                    if(self.eventTabVM.currentUni != Utils.getCampusUni()){
                                                        self.eventTabVM.reloadData()
                                                        self.eventTabVM.currentUni = Utils.getCampusUni()
                                                        self.uniUrl = "test"
                                                    }
                                                }){
                                                    SettingsView(thisUserRepo: self.thisUserRepo)
                                                }
                                        }
                                        
                                        FirebaseImage(
                                            path: Utils.uniLogoPath(),
                                            placeholder: AssetManager.uniLogoPlaceholder,
                                            width: 40,
                                            height: 40,
                                            shape: RoundedRectangle(cornerRadius: 0)
                                        )
                                        .padding(.leading, (UIScreen.screenWidth/2 - 75))
                                        
                                        
                                    }.padding(.leading, 0), trailing:
                                        HStack {
                                            if thisUserRepo.userLoggedIn {
                                                Button(action: {
                                                    self.createPostPresented.toggle()
                                                }) {
                                                    Image(systemName: "square.and.pencil")
                                                        .font(.system(size: 25))
                                                        .sheet(isPresented: $createPostPresented, onDismiss: {
                                                            self.eventTabVM.refresh()
                                                        }) {
                                                            CreatePostView(typePick: 1, alreadyExistingEvent: Event(), alreadyExistingPost: Post(), editingMode: false)
                                                        }
                                                }
                                            }
                                            //                        else {
                                            //                            Button(action: {
                                            //                                self.loginPresented.toggle()
                                            //                            }) {
                                            //                                Image(systemName: "arrow.right.circle")
                                            //                                    .font(.system(size: 25))
                                            //                                    .sheet(isPresented: $loginPresented, onDismiss: {
                                            //                                        Utils.checkForUnverified()
                                            //                                    }) {
                                            //                                        LoginView(thisUserRepo: self.thisUserRepo)
                                            //                                }
                                            //                            }
                                            //                        }
                                        })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}



