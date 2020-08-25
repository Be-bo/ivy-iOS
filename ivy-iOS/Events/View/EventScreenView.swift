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
    @State var selection: Int? = nil
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
                    .aspectRatio(contentMode: .fit)
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
                
                
                VStack(alignment: .leading){
                    
                    
                    
                    
                    //MARK: Author Row
                    ZStack{
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
                         .onTapGesture {
                            self.selection = 1
                        }
                        
                        
                        if (eventVM.event.author_is_organization) {
                            NavigationLink(
                                destination: OrganizationProfile(
                                    userRepo: UserRepo(userid: eventVM.event.author_id),
                                    postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_ORG, uni_domain: eventVM.event.uni_domain, user_id: eventVM.event.author_id)
                                )
                                    .navigationBarTitle("Profile"),
                                tag: 1,
                                selection: self.$selection) {
                                    EmptyView()
                            }
                        } else {
                            NavigationLink(
                                    destination: StudentProfile(
                                        userRepo: UserRepo(userid: eventVM.event.author_id),
                                        postListVM: PostListViewModel(limit: Constant.PROFILE_POST_LIMIT_STUDENT, uni_domain: eventVM.event.uni_domain, user_id: eventVM.event.author_id)
                                    )
                                        .navigationBarTitle("Profile"),
                                    tag: 1,
                                    selection: self.$selection) {
                                            EmptyView()
                                        }
                        }
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
                    .padding(.bottom, 10)
                    
                    //MARK: Text
                    Text(eventVM.event.text)
                }
                .padding(.leading)
                .padding(.trailing)
                
                
                
                //MARK: Going
                if(eventVM.event.going_ids.count < 1 && !eventVM.thisUserGoing){ //special edge case, when user is the first to go, "thisUserGoing" is listened to and will make sure the Nobody going text disappears
                    Text("Nobody's going to this event yet.").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
                }else{
                    ScrollView(.horizontal){
                        HStack{
                            if(eventVM.thisUserGoing){ //have this user as going always as the last item but decide whether to make them visible or not based on a bool value
                                PersonCircleView(personId: Auth.auth().currentUser!.uid)
                            }
                            ForEach(eventVM.goingIdsWithoutThisUser, id: \.self) { currentId in
                                PersonCircleView(personId: currentId)
                            }
                        }
                        .padding(.top, 30).padding(.bottom, 30)
                    }
                    .frame(width: screenWidth)
                }
            }
            
            
            
            //MARK: Button Row
            HStack(alignment: .center){
                
                Spacer()
                //MARK: Share
                Button(action: {//TODO: time formatting
                    self.isShareSheetShowing.toggle()
                    let av = UIActivityViewController(activityItems: [self.eventVM.event.name, "from: \(Utils.getEventDate(millis:self.eventVM.event.start_millis)) to: \(Utils.getEventDate(millis:self.eventVM.event.end_millis)),", "at: \(self.eventVM.event.location),", self.eventVM.event.text, "link: \(self.eventVM.event.link)"], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                }) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen).padding(.bottom, 10)
                }
                Spacer()
                
                
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
                Spacer()
                
                //MARK: Link
                if(Utils.verifyUrl(urlString: eventVM.event.link)){ //if link is valid, only then show the link button
                    Button(action: {
                        if let url = URL(string: self.eventVM.event.link) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "link").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen).padding(.bottom, 5)
                    }
                    Spacer()
                }
                
                
                //MARK: Going
                if(Auth.auth().currentUser != nil){
                    Button(action: {
                        if(self.eventVM.thisUserGoing){
                            self.eventVM.removeFromGoing()
                        }else{
                            self.eventVM.addToGoing()
                        }
                    }) {
                        Image(systemName: self.eventVM.thisUserGoing ? "checkmark.circle.fill" : "checkmark.circle").font(.system(size: 40)).foregroundColor(AssetManager.ivyGreen).padding(.bottom, 5)
                    }
                    Spacer()
                }
            }
            .padding()
            
            Divider().padding(.top, 20).padding(.bottom, 20)
            
            
            
            
            
            
            Text("Comments coming soon!").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
            
        }
    }
}



//struct EventScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventScreenView(eventVM: EventItemViewModel(event: Event()))
//    }
//}

