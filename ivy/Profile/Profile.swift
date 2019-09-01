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
    
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    
    
    @IBOutlet var shadowOuterContainer: Card!
    @IBOutlet var cardContainer: Card!
    @IBOutlet var plifButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUp(user: self.thisUserProfile)
    }
    
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
        
        //TODO: tidy this up
        let navigationBarWidth: CGFloat = self.navigationController!.navigationBar.frame.width
        var leftButton = UIButton(frame:CGRect(x: navigationBarWidth / 2.3, y: 0, width: 40, height: 40))
        var background = UIImageView(image: UIImage(named: "settings"))
        background.frame = CGRect(x: navigationBarWidth / 2.3, y: 0, width: 40, height: 40)
        leftButton.addSubview(background)
        self.navigationController!.navigationBar.addSubview(leftButton)
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
        
        
        if var degree = user["degree"] as? String { //degree icon
            degree = degree.replacingOccurrences(of: " ", with: "")
            degree = degree.lowercased()
            front.degreeIcon.image = UIImage(named: degree)
        }
        
        front.name.text = user["first_name"] as? String //text data
        back.name.text = String(user["first_name"] as? String ?? "Name") + " " + String(user["last_name"] as? String ?? "Name")
        back.degree.text = user["degree"] as? String
        back.age.text = user["age"] as? String
        back.bio.text = user["bio"] as? String
        back.setUpInterests(interests: user["interests"] as? [String] ?? [String]())
    }
    
    
    
    
    
    
    
}
