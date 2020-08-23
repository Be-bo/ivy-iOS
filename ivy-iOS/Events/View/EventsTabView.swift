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
    @ObservedObject var eventTabVM = EventTabViewModel();
    var screenWidth: CGFloat = 300.0
    @State var url = ""
    @State var exploreAllPresented = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .leading){
                
                
                // MARK: Featured
                ForEach(eventTabVM.featuredEventVMs){ eventItemVM in
                    Text("Featured").font(.system(size: 25)).padding(.leading)
                    WebImage(url: URL(string: self.url))
                        .resizable()
                        .placeholder(AssetManager.logoWhite)
                        .background(AssetManager.ivyLightGrey)
                        .frame(width: self.screenWidth-20, height: self.screenWidth - 20)
                        .cornerRadius(30)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 30)
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(eventItemVM.event.visual).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading featured image.")
                                    return
                                }
                                self.url = "\(url!)"
                            }
                    }
                }
                
                
                
                // MARK: Tuday
                Group{
                    Text("Today").font(.system(size: 25)).padding(.leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(eventTabVM.todayEventVMs) { eventItemVM in
                                EventsTabItemView(eventItemVM: eventItemVM)
                            }
                        }.padding()
                            .frame(width: CGFloat(eventTabVM.todayEventVMs.count*210 + 10) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
                                , height: 260, alignment: .leading)
                    }
                    .padding(.bottom, 30)
                }
                
                
                
                // MARK: This Week
                Group{
                    Text("This Week").font(.system(size: 25)).padding(.leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(eventTabVM.thisWeekEventVMs) { eventItemVM in
                                EventsTabItemView(eventItemVM: eventItemVM)
                            }
                        }.padding()
                            .frame(width: CGFloat(eventTabVM.thisWeekEventVMs.count*210 + 10) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
                                , height: 260, alignment: .leading)
                    }
                    .padding(.bottom, 30)
                }
                
                
                
                // MARK: Upcoming
                Group{
                    Text("Upcoming").font(.system(size: 25)).padding(.leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(eventTabVM.upcomingEventVMs) { eventItemVM in
                                EventsTabItemView(eventItemVM: eventItemVM)
                            }
                        }.padding()
                            .frame(width: CGFloat(eventTabVM.upcomingEventVMs.count*210 + 10) //need specified height, behaves weirdly otherwise, each item is 200 width + 10 for padding, + 10 for trailing padding
                                , height: 260, alignment: .leading)
                    }
                    .padding(.bottom, 30)
                }
                
                
                
                // MARK: Explore All
                if eventTabVM.upcomingEventVMs.count > 0{
                    Button(action: {
                        self.exploreAllPresented.toggle()
                        if (self.eventTabVM.exploreAllEventsVMs.count < 1){ //if we haven't loaded explore all events yet, load them now
                            self.eventTabVM.eventRepo.loadExploreAll()
                        }
                    }){
                        Text("Explore All")
                            .sheet(isPresented: $exploreAllPresented){
                                ExploreAllEventsView(eventTabVM: self.eventTabVM)
                        }
                    }
                        .disabled(eventTabVM.upcomingEventVMs.count < 1) //button is disabled either when input not ok or when we're waiting for a Firebase result
                        .buttonStyle(StandardButtonStyle(disabled: eventTabVM.upcomingEventVMs.count < 1)) //setting button style where background color changes based on if input is ok
                        .padding()
                }
            }
            
        }
        
    }
}


struct EventsTabView_Previews: PreviewProvider {
    static var previews: some View {
        EventsTabView()
    }
}
