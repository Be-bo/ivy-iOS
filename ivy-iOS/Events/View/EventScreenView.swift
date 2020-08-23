//
//  EventScreenView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct EventScreenView: View {
    @ObservedObject var eventVM: EventItemViewModel
    var screenWidth: CGFloat = 300
    @State var imageUrl = ""
    @State var authorUrl = ""
    @State private var isShareSheetShowing = false
    @State private var showingCalendarAlert = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            
            VStack{
                
                
                //MARK: Image
                WebImage(url: URL(string: self.imageUrl))
                    .resizable()
                    .placeholder(AssetManager.logoWhite)
                    .background(AssetManager.ivyLightGrey)
                    .frame(width: self.screenWidth, height: self.screenWidth)
                    .onAppear(){
                        let storage = Storage.storage().reference()
                        storage.child(self.eventVM.event.visual).downloadURL { (url, err) in
                            if err != nil{
                                print("Error loading featured image.")
                                return
                            }
                            self.imageUrl = "\(url!)"
                        }
                }
                
                
                Group{
                    //MARK: Author Row
                    HStack(){
                        WebImage(url: URL(string: authorUrl))
                            .resizable()
                            .placeholder(Image(systemName: "person.crop.circle.fill"))
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .onAppear(){
                                let storage = Storage.storage().reference()
                                storage.child(Utils.userPreviewImagePath(userId: self.eventVM.event.author_id)).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading event image.")
                                        return
                                    }
                                    self.authorUrl = "\(url!)"
                                }
                        }
                        Text(self.eventVM.event.author_name)
                        Spacer()
                    }
                    
                    
                    
                    //MARK: Time Row
                    HStack{
                        Image(systemName: "clock.fill")
                        Text(Utils.getEventDate(millis:eventVM.event.start_millis) + " - " + Utils.getEventDate(millis:eventVM.event.end_millis))
                        Spacer()
                    }
                    
                    
                    //MARK: Location Row
                    HStack{
                        Image(systemName: "location.fill")
                        Text(eventVM.event.location)
                        Spacer()
                    }
                    
                    //MARK: Text
                    Text(eventVM.event.text)
                }
                .padding(.leading)
                .padding(.trailing)
                
                
                
                //MARK: Going
                if(eventVM.event.going_ids.count < 1){
                    Text("Nobody's going to this event yet.").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
                }else{
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(eventVM.event.going_ids, id: \.self) { currentId in
                                PersonCircleView(personId: currentId)
                            }
                        }
                        .padding(.top, 30).padding(.bottom, 30)
                    }
                }
            }
            
            
            
            //MARK: Button Row
            HStack{
                
                //MARK: Share
                Spacer()
                Button(action: {//TODO: time formatting
                    self.isShareSheetShowing.toggle()
                    let av = UIActivityViewController(activityItems: [self.eventVM.event.name, "from: \(Utils.getEventDate(millis:self.eventVM.event.start_millis)) to: \(Utils.getEventDate(millis:self.eventVM.event.end_millis)),", "at: \(self.eventVM.event.location),", self.eventVM.event.text, "link: \(self.eventVM.event.link)"], applicationActivities: nil)
                    
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                }) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen)
                }
                
                //MARK: Link
                Spacer()
                if(Utils.verifyUrl(urlString: eventVM.event.link)){ //if link is valid, only then show the link button
                    Button(action: {
                        if let url = URL(string: self.eventVM.event.link) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "link").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen)
                    }
                    Spacer()
                }
                
                //MARK: Calendar
                Button(action: {
                    self.showingCalendarAlert.toggle()
                    CalendarUtil.addToCalendar(startDate: Date(timeIntervalSince1970: TimeInterval(self.eventVM.event.start_millis/1000)), endDate: Date(timeIntervalSince1970: TimeInterval(self.eventVM.event.end_millis/1000)), eventName: self.eventVM.event.name, extras: "Location: \(self.eventVM.event.location), Link: \(self.eventVM.event.link), Description: \(self.eventVM.event.text)")
                }) {
                    Image(systemName: "calendar.badge.plus").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen)
                }
                .alert(isPresented: $showingCalendarAlert){
                    Alert(title: Text("Event Added"), message: Text("\(self.eventVM.event.name) is now in your default calendar"), dismissButton: .default(Text("OK")))
                }
                
                //MARK: Going
                //TODO: together with interaction
                Spacer()
                Button(action: {}) {
                    Image(systemName: "checkmark.circle").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen)
                }
                Spacer()
            }
            .padding()
            
            Divider().padding(.top, 20).padding(.bottom, 20)
            
            
            
            
            
            
            //MARK: Comments
            //TODO
            
        }
    }
}



//struct EventScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventScreenView(eventVM: EventItemViewModel(event: Event()))
//    }
//}

