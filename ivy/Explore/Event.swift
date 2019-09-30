//
//  Event.swift
//  ivy
//
//  Created by paul dan on 2019-08-25.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//deals with the logic corresponding to when you actually click on an event

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class Event: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Variables and Constants
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()             //reference to storage
    
    public var eventID: String?
    public var event = Dictionary<String, Any>()                                 //actual event that was clicked
    public var userProfile = Dictionary<String, Any>()                           //holds the current user profile
    public var goingFriends = [String]()                                         //global that will hold all the friends that are going to the event
    private var whosGoingProfileClickedID = ""                                   //holds the other profile id that was clicked from the suggested friends collection

    
    @IBOutlet weak var eventImageHeightConstr: NSLayoutConstraint!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var whosGoingCollection: UICollectionView!
    @IBOutlet weak var eventLogo: UIImageView!
    @IBOutlet weak var keywords: UILabel!
    @IBOutlet weak var eventInfo: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var whosGoingLabel: UILabel!
    @IBOutlet weak var goingCheckButton: UIButton!
    @IBOutlet weak var imGoingButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    
    
    
    
    // MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    
    
    
    
    
    // MARK: Data Acquisition Functions
    
    func getData(){
        if let uniDomain = userProfile["uni_domain"] as? String, let eve = event as? Dictionary<String, Any>, let evId = eve["id"] as? String{
            baseDatabaseReference.collection("universities").document(uniDomain).collection("events").document(evId).getDocument { (docSnap, err) in
                if err != nil{
                    print("Error getting event: ", err)
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "Sorry we couldn't retrieve your event. Try restarting the app.", context: self)
                }else{
                    if let evDat = docSnap?.data(){
                        self.event = evDat
                        self.setUp()
                        
                        self.bindData()
                        self.setUpGoingList()
                        self.registerButton.addTarget(self, action: #selector(self.registerButtonClicked), for: .touchUpInside)//on click fro register button
                        if let goingIdList = self.event["going_ids"] as? [String], let thisUserId = self.userProfile["id"] as? String, goingIdList.contains(thisUserId){
                            self.setThisUserGoing()
                        }else{
                            self.setThisUserNotGoing()
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    // MARK: Set Up Functions
    
    private func setUp(){
        whosGoingCollection.delegate = self
        whosGoingCollection.dataSource = self
        whosGoingCollection.register(UINib(nibName: "profileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionViewCell")
        self.goingCheckButton.imageView?.contentMode = .scaleAspectFit
        let imgWidth = eventImage.frame.width
        eventImageHeightConstr.constant = imgWidth
    }
    
    private func setUpNavigationBar(eventName: String){
        let titleView = MediumGreenLabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        titleView.text = eventName
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
    }
    
    func bindData() { //populate the front end with the data from the event
        if let evName = self.event["name"] as? String{ //set up the name of the event as the VC's title in the navigation bar
            setUpNavigationBar(eventName: evName)
        }else{
            setUpNavigationBar(eventName: "Event")
        }
        
        
        if let eventImage = self.event["image"] as? String{
            self.baseStorageReference.child(eventImage).getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    self.eventImage.image  = UIImage(data: data!)
                }
            }
        }

        if let eventLogo = self.event["logo"] as? String {
            self.baseStorageReference.child(eventLogo).getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    self.eventLogo.image  = UIImage(data: data!)
                    //add on cick lsiteener
                    let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.onClickLogo))
                    self.eventLogo.isUserInteractionEnabled = true
                    self.eventLogo.addGestureRecognizer(singleTap)
                }
            }
        }
        
        
        self.eventDescription.text = self.event["description"] as? String
        self.eventInfo.text = compileInfoRow()
        var keyWCombined = ""
        
        
        
        if let keyWList = self.event["keywords"] as? [String]{
            if (!keyWList.isEmpty){
                for keyword in keyWList{
                    keyWCombined = keyWCombined + "#" + keyword + " "
                }
            }
            keywords.text = keyWCombined
        }
        
        

    }

    func setUpGoingList() { //populate the collection view with the people that are going to this current event
        
        if let uniDomain = self.userProfile["uni_domain"] as? String {
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(self.userProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
                if let document = document, document.exists {
                    var friends = document.data()
                    
        
                    
                    if let goingIds = self.event["going_ids"] as? [String]{
                        //if  my friends are going to this event, then add them to the list
                        if (!goingIds.isEmpty && goingIds.count > 0){
                            for (friendId, conversationId) in friends!{
                                if goingIds.contains(friendId){    //friends[0] is his id: and friend[1] is the conversation id
                                    self.goingFriends.append(friendId)
                                }
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                    }

                
                if (self.goingFriends.count > 0) {
                    self.whosGoingCollection.reloadData() //notify the collectionview that we have items to display
                    
                    self.whosGoingLabel.isHidden = false
                    self.collectionViewHeightConstraint.constant = 150 //set the standard height to the collectionview
                }else{
                    self.whosGoingLabel.isHidden = true
                    self.collectionViewHeightConstraint.constant = 0 //collapse the collectionview
                }
            }
        }
        

    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Interaction Methods
    
    @objc func onClickLogo() {
        self.performSegue(withIdentifier: "eventToOrganization" , sender: self) //pass data over to
    }
    
    func setThisUserGoing() { //make checkmark visible, hide going button, set listener to layout that removes user from "going_ids" if they click on it
        self.imGoingButton.isHidden = true
        self.goingCheckButton.isHidden = false
        self.imGoingButton.removeTarget(self, action: #selector(imGoingButtonClicked), for: .touchUpInside)
        self.goingCheckButton.addTarget(self, action: #selector(goingCheckButtonClicked), for: .touchUpInside)
    }
    
    func setThisUserNotGoing() { //dont add the guy to the list
        self.imGoingButton.isHidden = false
        self.goingCheckButton.isHidden = true
        self.imGoingButton.addTarget(self, action: #selector(imGoingButtonClicked), for: .touchUpInside)
        self.goingCheckButton.removeTarget(self, action: #selector(goingCheckButtonClicked), for: .touchUpInside)
    }
    
    @objc func imGoingButtonClicked(_ sender: UIButton) { //on click of the im going button clicked
//        self.goingFriends.append(self.userProfile["id"] as! String)
        
        if let uniDomain = self.userProfile["uni_domain"] as? String {
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("events").document(self.event["id"] as! String).updateData(["going_ids":FieldValue.arrayUnion([self.userProfile["id"]])])
            self.setThisUserGoing()
        }
        


    }
    
    @objc func goingCheckButtonClicked(_ sender: UIButton) { //on click of the im going button clicked
//        self.goingFriends.(self.userProfile["id"] as! String)
//        self.goingFriends = self.goingFriends.filter { $0 != self.userProfile["id"] as! String }
        if let uniDomain = self.userProfile["uni_domain"] as? String {
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("events").document(self.event["id"] as! String).updateData(["going_ids":FieldValue.arrayRemove([self.userProfile["id"]])])
            self.setThisUserNotGoing()
        }

    }
    
    @objc func registerButtonClicked(_ sender: UIButton) {//on click of the im going button clicked
        if self.event.contains(where: { $0.key == "link"}) {    //check if the event even contains a link to be clicked on
            if let url = URL(string: event["link"] as! String) { //open link
                UIApplication.shared.open(url, options: [:])
            }
            
            if let uniDomain = self.userProfile["uni_domain"] as? String {
                self.baseDatabaseReference.collection("universities").document(uniDomain).collection("events").document(self.event["id"] as! String).updateData(["clicks":FieldValue.arrayUnion([Date().timeIntervalSince1970])]) //update counter to indicate it was clicked on
            }

            

        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Info Row Methods
    
    func compileInfoRow() -> String { //construct the format of when the event is occuring... date, time, etc.
        let startMillis = self.event["start_time"]
        let endMillis  = self.event["end_time"]
        if (startMillis is CLong && endMillis is CLong){
            var retVal = ""
            
            let startTime = Date.init(milliseconds: Int64(startMillis as! CLong)) //start time
            var calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: startTime)
            var month = startTime.monthMedium //these work beautifully except that they're missing the day getter for some reason
            var hour = startTime.hour12
            var minute = startTime.minute0x
            var amPm = startTime.amPM
            var day = "Unknown Day"
            var year = "Unknown Year"
            if let dayInt = calendarDate.day{
                day = String(dayInt)
            }
            if let yearInt = calendarDate.year{
                year = String(yearInt)
            }
            retVal = "from: "+month+" "+day+" "+year+" "+hour+":"+minute+amPm
            
            let endTime = Date.init(milliseconds: Int64(endMillis as! CLong)) //end time
            calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: endTime)
            month = endTime.monthMedium
            hour = endTime.hour12
            minute = endTime.minute0x
            amPm = endTime.amPM
            day = "Unknown Day"
            year = "Unknown Year"
            if let dayInt = calendarDate.day{
                day = String(dayInt)
            }
            if let yearInt = calendarDate.year{
                year = String(yearInt)
            }
            retVal = retVal + " to: "+month+" "+day+" "+year+" "+hour+":"+minute+amPm
    
            var location = "Unknown Location" //location
            if let loc = self.event["location"] as? String{
                location = loc
            }
            if(location != ""){
                retVal = retVal+" at: "+location
            }
            return retVal
        }else{
            return "Time and location not available."
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: Collection View Delegate and Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.goingFriends.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let profilePrevCard = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCollectionViewCell", for: indexPath) as! profileCollectionViewCell
        profilePrevCard.setUp(userGoingId: self.goingFriends[indexPath.item], thisUserProfile: self.userProfile)
        return profilePrevCard
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 130, height: self.whosGoingCollection.frame.size.height)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //on click of the event, pass the data from the event through a segue to the event.swift page
            self.whosGoingProfileClickedID = self.goingFriends[indexPath.item]  //use currently clicked index to get conversation id
            self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        if segue.identifier == "viewFullProfileSegue" {
            let vc = segue.destination as! ViewFullProfileActivity
            vc.isFriend = true
            vc.thisUserProfile = self.userProfile
            vc.otherUserID = self.whosGoingProfileClickedID
        }
        
        if segue.identifier == "eventToOrganization" {
            let vc = segue.destination as! organizationPage
            vc.userProfile = self.userProfile
            vc.organizationId = self.event["organization_id"] as! String
        }
    }
}







extension Formatter {
    static let monthMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL"
        return formatter
    }()
    static let hour12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    static let minute0x: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    static let amPM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
}
extension Date {
    var monthMedium: String  { return Formatter.monthMedium.string(from: self) }
    var hour12:  String      { return Formatter.hour12.string(from: self) }
    var minute0x: String     { return Formatter.minute0x.string(from: self) }
    var amPM: String         { return Formatter.amPM.string(from: self) }
}
