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

    public var thisUserProfile = Dictionary<String, Any>()


    // MARK: Variables and Constants

    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
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

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        updateProfile(updatedProfile: self.thisUserProfile)
//        setUp(user: self.thisUserProfile)
//    }

    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo_small"))
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
                    print("Error obtaining image: ", e)
                }else{
                    self.front.img.image = UIImage(data: data!)
                }
            }
        }

        back.name.text = String(user["first_name"] as? String ?? "Name") + " " + String(user["last_name"] as? String ?? "Name") + ","
        back.degree.text = user["degree"] as? String
        back.age.text = String(user["age"] as! Int)
        back.bioLabel.text = user["bio"] as? String
        back.setUpInterests(interests: user["interests"] as? [String] ?? [String]())
        back.bioTextField.text = back.bioLabel.text

        //TODO: find a better solution for this where we can make the items from Card.swift clickable
        //moving sync arrow to front to be clickable
        shadowOuterContainer.bringSubviewToFront(cardContainer)
        shadowOuterContainer.bringSubviewToFront(cardContainer.back)
        shadowOuterContainer.bringSubviewToFront(cardContainer.front)
        front.flipButton.addTarget(self, action: #selector(flip), for: .touchUpInside) //set on click listener for send message button
        back.flipButton.addTarget(self, action: #selector(flip), for: .touchUpInside) //set on click listener for send message button


        back.editButton.addTarget(self, action: #selector(onClickEdit), for: .touchUpInside) //set on click listener for editing
        back.doneEditingButton.addTarget(self, action: #selector(onClickDoneEdit), for: .touchUpInside) //set on click listener for done editing



        //add on click for ther gallery button which will take them to the gallery screen
        front.galleryButton.addTarget(self, action: #selector(clickGallery), for: .touchUpInside) //set on click listener for send message button



    }


    //when they click the edit
    @objc func onClickEdit() {
        
        //hide the bottom navigation bar when they begin editing
        self.tabBarController?.tabBar.isHidden = true

        //hide the bio label and hide the edit button
        back.bioLabel.isHidden = true
        back.editButton.isHidden = true 
        //show the edit interests,degree,textfield,& check mark
        back.editDegreeButton.isHidden = false
        back.editInterestsButton.isHidden = false
        back.bioTextField.isHidden = false
        back.doneEditingButton.isHidden = false

        //add onclick for editing degree that displays the table view with all the degrees they can choose from
        back.editDegreeButton.addTarget(self, action: #selector(onClickEditDegree), for: .touchUpInside)

        back.editInterestsButton.addTarget(self, action: #selector(onClickEditInterests), for: .touchUpInside)

        back.doneEditingButton.addTarget(self, action: #selector(onClickDoneEdit), for: .touchUpInside)

    }


    //when they click edit degree, prompt them with all the degrees they can choose from
    @objc func onClickEditDegree() {
        self.performSegue(withIdentifier: "profileToEditDegree" , sender: self) //pass data over to
    }

    @objc func onClickEditInterests() {
        self.performSegue(withIdentifier: "profileToEditInterests" , sender: self) //pass data over to
    }


    //when they click finish editing, try to update the bio
    @objc func onClickDoneEdit() {
        
        //reshow the navigation bar when they're done editing
        self.tabBarController?.tabBar.isHidden = false
        
        //hide the bio label and hide the edit button
        back.bioLabel.isHidden = false
        back.editButton.isHidden = false
        //show the edit interests,degree,textfield,& check mark
        back.editDegreeButton.isHidden = true
        back.editInterestsButton.isHidden = true
        back.bioTextField.isHidden = true
        back.doneEditingButton.isHidden = true

        if(back.bioTextField.text != "") {
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["bio": back.bioTextField.text])
            back.bioTextField.text = back.bioTextField.text
            back.bioLabel.text = back.bioTextField.text
            self.thisUserProfile["bio"] = back.bioTextField.text
            self.hideKeyboard()

        }


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
        if segue.identifier == "profileToGallery" {
            let vc = segue.destination as! Gallery
            vc.thisUniDomain = self.thisUserProfile["uni_domain"] as! String //set the conversation id of chatRoom.swift to contain the one the user clicked on
            vc.thisUserId = self.thisUserProfile["id"] as! String   //pass the user profile object
            vc.previousVC = self
        }

        if segue.identifier == "profileToEditDegree" {
            let vc = segue.destination as! editDegreePopUpViewController
            vc.currentDegree = self.thisUserProfile["degree"] as! String
            vc.thisUserProfile = self.thisUserProfile
            vc.previousVC = self
        }
        if segue.identifier == "profileToEditInterests" {
            let vc = segue.destination as! editInterestsPopUpViewController
            vc.interestsChosen = self.thisUserProfile["interests"] as! [String]
            vc.thisUserProfile = self.thisUserProfile
            vc.previousVC = self
        }
        if segue.identifier == "profileToSettings" {
            let vc = segue.destination as! Settings
            vc.thisUserProfile = self.thisUserProfile
        }
        


    }
    






}
