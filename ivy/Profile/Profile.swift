//
//  Profile.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class Profile: UIViewController {
    
    private var thisUserProfile = Dictionary<String, Any>()
    
    
    // MARK: Variables and Constants
    
    private let baseStorageReference = Storage.storage().reference()
    private var showingBack = false
    private var firstSetup = true
    
    let front = Bundle.main.loadNibNamed("profileCardFront", owner: nil, options: nil)?.first as! ProfileCardFront
    let back = Bundle.main.loadNibNamed("ProfileCardBack", owner: nil, options: nil)?.first as! ProfileCardBack
    
    
    @IBOutlet var shadowOuterContainer: Card!
    @IBOutlet var cardContainer: Card!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUp(user: self.thisUserProfile)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfile(updatedProfile: self.thisUserProfile)
        setUp(user: self.thisUserProfile)
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
        
        let settingsButton = UIButton(type: .custom)
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 45, height: 35)
        settingsButton.setImage(UIImage(named:"settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(self.settingsClicked), for: .touchUpInside)
        
        let settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        let currHeight = settingsButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        self.navigationItem.rightBarButtonItem = settingsButtonItem
    }
    
    @objc func settingsClicked() {
        self.performSegue(withIdentifier: "profileToSettings" , sender: self) //pass data over to
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
    }
    
    
    // MARK: Card Functions
    
    func setUp(user: Dictionary<String, Any>){ //set all the variables from user's profile to display on the card
        
        if(firstSetup){ //if it's the first time this xib is being created set up the subviews (front and back cards need to have the dimensions of the card container)
            front.frame = cardContainer.bounds
            back.frame = cardContainer.bounds
            cardContainer.addSubview(back)
            cardContainer.addSubview(front)
            
            
            firstSetup = false
        }
        
        if let ref = user["profile_picture"] as? String{ //profile picture
            baseStorageReference.child(ref).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                if let e = e {
                    print("Error obtaining image PAUL: ", e)
                }else{
                    self.front.img.image = UIImage(data: data!)
                }
            }
        }
        
        back.name.text = String(user["first_name"] as? String ?? "Name") + " " + String(user["last_name"] as? String ?? "Name")
        back.degree.text = user["degree"] as? String
        back.age.text = user["age"] as? String
        back.bio.text = user["bio"] as? String
        back.setUpInterests(interests: user["interests"] as? [String] ?? [String]())
        
        
        //TODO: find a better solution for this where we can make the items from Card.swift clickable
        //moving sync arrow to front to be clickable
        shadowOuterContainer.bringSubviewToFront(cardContainer)
        shadowOuterContainer.bringSubviewToFront(cardContainer.back)
        shadowOuterContainer.bringSubviewToFront(cardContainer.front)
        front.flipButton.addTarget(self, action: #selector(flip), for: .touchUpInside) //set on click listener for send message button
        back.flipButton.addTarget(self, action: #selector(flip), for: .touchUpInside) //set on click listener for send message button
        back.editButton.addTarget(self, action: #selector(onClickEdit), for: .touchUpInside) //set on click listener for send message button
        
        
        
        //add on click for ther gallery button which will take them to the gallery screen
        front.galleryButton.addTarget(self, action: #selector(clickGallery), for: .touchUpInside) //set on click listener for send message button
        
        
        
    }
    
    
    //when they click the edit 
    @objc func onClickEdit() {
        
    }
    
    
    @objc func flip(_ sender: subclassedUIButton) { //a method that flips the card
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight) { (done) in
        }
        showingBack = !showingBack
    }
    
    
    //when they click gallery then segue over to the gallery screen where tehy can edit their profile pic
    @objc func clickGallery(_ sender: subclassedUIButton) {
        self.performSegue(withIdentifier: "profileToGallery" , sender: self) //pass data over to
        
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "profileToSettings"){
            let vc = segue.destination as! Settings
            vc.thisUserProfile = self.thisUserProfile
        }else{
            let vc = segue.destination as! Gallery
            vc.thisUniDomain = self.thisUserProfile["uni_domain"] as! String //set the conversation id of chatRoom.swift to contain the one the user clicked on
            vc.thisUserId = self.thisUserProfile["id"] as! String   //pass the user profile object
        }
    }
}
