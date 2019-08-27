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
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()             //reference to storage
    
    

//    var eventDate = UITextView()                                               //from --- to ----. date info
    public var eventID: String?
    public var event = Dictionary<String, Any>()                                 //actual event that was clicked
    public var userProfile = Dictionary<String, Any>()                           //holds the current user profile
    public var goingFriends = [String]()                                         //global that will hold all the friends that are going to the event
    private var whosGoingProfileClickedID = ""                                   //holds the other profile id that was clicked from the suggested friends collection

    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        self.setUp()
        
        //make sure the event actually exists
        if (!self.event.isEmpty){
            self.bindData()
            self.setUpGoingList()
            self.registerButton.addTarget(self, action: #selector(registerButtonClicked), for: .touchUpInside)//on click fro register button
            let goingIds = self.event["going_ids"] as! [String]
            if (!goingIds.isEmpty && goingIds.contains(self.userProfile["id"] as! String)){
                self.setThisUserGoing()
            }else{
                self.setThisUserNotGoing()
            }
        }

        
    }
    
    private func setUp(){
        whosGoingCollection.delegate = self
        whosGoingCollection.dataSource = self
        whosGoingCollection.register(UINib(nibName: "profileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionViewCell")
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
        // this retarded bs is not working
        let settingsBtn = SettingsButton()
        let settingsButton = UIBarButtonItem(customView: settingsBtn)
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    
    
    
    
    //populate the front end with the data from the event
    func bindData() {
        self.navigationItem.title = self.event["name"] as? String //TODO: put title in top bar. use ivy green: #2b9721
        self.baseStorageReference.child(self.event["image"] as! String).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.eventImage.image  = UIImage(data: data!)
            }
        }
        self.baseStorageReference.child(self.event["logo"] as! String).getData(maxSize: 1 * 1024 * 1024) { data, error in
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
        self.eventDescription.text = self.event["description"] as? String
        self.eventInfo.text = compileInfoRow()
        var keyWCombined = ""
        let keyWList = self.event["keywords"] as! [String]
        if (!keyWList.isEmpty){
            for keyword in keyWList{
                keyWCombined = keyWCombined + "#" + keyword + " "
            }
        }
        keywords.text = keyWCombined    //TODO: make the text color ivy green
    }
    
    
    //when user clicks logo, transition them to the organizationpage .swift view controller
    @objc func onClickLogo() {
        self.performSegue(withIdentifier: "eventToOrganization" , sender: self) //pass data over to
    }

    
    
    //populate the collection view with the people that are going to this current event.
    func setUpGoingList() {
        self.baseDatabaseReference.collection("universities").document(self.userProfile["uni_domain"] as! String).collection("userprofiles").document(self.userProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
            if let document = document, document.exists {
                var friends = document.data()
                var goingIds = self.event["going_ids"] as! [String]
                //if  my friends are going to this event, then add them to the list
                if (!goingIds.isEmpty && goingIds.count > 0){
                    for (friendId, conversationId) in friends!{
                        if goingIds.contains(friendId){    //friends[0] is his id: and friend[1] is the conversation id
                            self.goingFriends.append(friendId)
                        }
                    }
                }
                if (self.goingFriends.count > 0) {
                    //TODO: maybe collapse the label not jsut hide
                    self.whosGoingLabel.isHidden = false
                    self.whosGoingCollection.isHidden = false
                    self.whosGoingCollection.reloadData()
                }else{
                    //TODO: maybe collapse the label not jsut hide
                    self.whosGoingLabel.isHidden = true
                    self.whosGoingCollection.isHidden = true
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    //make checkmark visible, hide going button, set listener to layout that removes user from "going_ids" if they click on it
    func setThisUserGoing() {
        self.imGoingButton.isHidden = true
        self.goingCheckButton.isHidden = false
        self.imGoingButton.removeTarget(self, action: #selector(imGoingButtonClicked), for: .touchUpInside)
        self.goingCheckButton.addTarget(self, action: #selector(goingCheckButtonClicked), for: .touchUpInside)
    }
    

    //dont add the guy to the list
    func setThisUserNotGoing() {
        self.imGoingButton.isHidden = false
        self.goingCheckButton.isHidden = true
        self.imGoingButton.addTarget(self, action: #selector(imGoingButtonClicked), for: .touchUpInside)
        self.goingCheckButton.removeTarget(self, action: #selector(goingCheckButtonClicked), for: .touchUpInside)
    }
    
    
    
    //on click of the im going button clicked
    @objc func imGoingButtonClicked(_ sender: UIButton) {
//        self.goingFriends.append(self.userProfile["id"] as! String)
        self.baseDatabaseReference.collection("universities").document(self.userProfile["uni_domain"] as! String).collection("events").document(self.event["id"] as! String).updateData(["going_ids":FieldValue.arrayUnion([self.userProfile["id"]])])
        self.setThisUserGoing()

    }
    
    //on click of the im going button clicked
    @objc func goingCheckButtonClicked(_ sender: UIButton) {
//        self.goingFriends.(self.userProfile["id"] as! String)
//        self.goingFriends = self.goingFriends.filter { $0 != self.userProfile["id"] as! String }
        self.baseDatabaseReference.collection("universities").document(self.userProfile["uni_domain"] as! String).collection("events").document(self.event["id"] as! String).updateData(["going_ids":FieldValue.arrayRemove([self.userProfile["id"]])])
        self.setThisUserNotGoing()
    }
    
    //on click of the im going button clicked
    @objc func registerButtonClicked(_ sender: UIButton) {
        
        if self.event.contains(where: { $0.key == "link"}) {    //check if the event even contains a link to be clicked on
            if let url = URL(string: "http://www.google.com") { //open link
                UIApplication.shared.open(url, options: [:])
            }
            self.baseDatabaseReference.collection("universities").document(self.userProfile["uni_domain"] as! String).collection("events").document(self.event["id"] as! String).updateData(["clicks":FieldValue.arrayUnion([Date().timeIntervalSince1970])]) //update counter to indicate it was clicked on

        }
        
    }
    
    
    
    
    
    //TODO: format the date properly... right now its not accurate.
    //construct the format of when the event is occuring... date, time, etc.
    func compileInfoRow() -> String {
        let startTime = self.event["start_time"]
        let endTime  = self.event["end_time"]
        if (startTime is CLong && endTime is CLong){
            var retVal = ""
            
            //start time
            let calendar = Calendar.current
            let timeStart = Date(timeIntervalSinceNow: startTime as! Double)
            
            //TODO: get rid of this stuff and the extension down below if can figure out how to make it work with calendar
            let dateMonth = timeStart.monthMedium
            let dateHour = timeStart.hour12
            let dateMinute = timeStart.minute0x
            let dateAmPm = timeStart.amPM
            print(dateMonth, dateHour, dateMinute, dateAmPm)
            
            
            var components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute], from: timeStart)
            
            var month = components.month as! Int
            var day = components.day as! Int
            var year = components.year as! Int
            var hour = components.hour as! Int
            
            if ( hour == 0 ){
                hour = 12
            }
            var amPm = "AM"
            if (calendar.amSymbol == "AM"){
                //nothing
            }else{
                amPm = "PM"
            }
            var minute = components.minute as! Int
            
            retVal = "from: " + String(month)  + " "
            retVal = retVal + String(day) + " "
            retVal = retVal + String(year) + " " + String(hour)
            retVal = retVal + ":" + String(minute) + String(amPm)
            
            
            //endtime
            let timeEnd = Date(timeIntervalSinceNow: endTime as! Double)
            components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year,Calendar.Component.hour, Calendar.Component.minute], from: timeEnd)
            month = components.month as! Int
            day = components.day as! Int
            year = components.year as! Int
            hour = components.hour as! Int
            if ( hour == 0 ){
                hour = 12
            }
            amPm = "AM"
            if (calendar.amSymbol == "AM"){
                //nothing
            }else{
                amPm = "PM"
            }
            minute = components.minute as! Int
            
            retVal = retVal + " to: " + String(month) + " "
            retVal = retVal +  String(day) + " " + String(year) + " " + String(hour) + ":"
            retVal = retVal + String(minute) + String(amPm)
            retVal = retVal + " at: " + String(self.event["location"] as! String)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //item size has to adjust based on current collection view dimensions (90% of the its size, the rest is padding - see the setUp() function)
        let cellSize = CGSize(width: self.whosGoingCollection.frame.size.width * 0.50, height: self.whosGoingCollection.frame.size.height * 0.50)
        return cellSize
    }
    
    //TODO: deal with clicking of the events so that it responds to the right event being clicked on each time, right now it always registers the last clicked item????
    //on click of the event, pass the data from the event through a segue to the event.swift page
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
            self.whosGoingProfileClickedID = self.goingFriends[indexPath.item]  //use currentley clicked index to get conversation id
            self.performSegue(withIdentifier: "viewFullProfileSegue" , sender: self) //pass data over to
        
    }
    
    //called every single time a segue is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    




    // MARK: Collection View Behavior Functions

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionViewCenterX = self.whosGoingCollection.center.x //get the center of the collection view

        for cell in self.whosGoingCollection.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.whosGoingCollection.frame.size.width / 2.0 //get the center of the current cell
            let distance = abs(cellCenterX - collectionViewCenterX) //distance between them

            let tolerance : CGFloat = 0.02
            let multiplier : CGFloat = 0.105
            var scale = 1.00 + tolerance - ((distance/collectionViewCenterX)*multiplier) //scale the car based on how far it is from the center (tolerance and the multiplier are both arbitrary)
            if(scale > 1.0){ //don't go beyond 100% size
                scale = 1.0
            }
            cell.transform = CGAffineTransform(scaleX: scale, y: scale) //apply the size change
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
