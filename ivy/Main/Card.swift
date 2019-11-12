//
//  Card.swift
//  ivy
//
//  Created by Robert on 2019-08-04.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class Card: UICollectionViewCell {
    
    // MARK: Variables and Constants
    
    private let baseStorageReference = Storage.storage().reference()
    private var showingBack = false
    private var firstSetup = true
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    public var id = ""  //the id that will be associated with each card for reporting/blocking
    
    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var cardContainer: Card!
    @IBOutlet weak var shadowOuterContainer: Card!
    @IBOutlet weak var loadingWheel: LoadingWheel!
    

    
    // MARK: Base and Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight] //need to make sure the card resizes based on the cell of the collectionview
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNib()
    }
    
    
    
    
    
    // MARK: Card Functions
    
    func setUp(user: Dictionary<String, Any>){ //set all the variables from user's profile to display on the card
        startLoading()
        if let userID = user["id"] as? String{
            self.id = userID
        }
    
        if(firstSetup){ //if it's the first time this xib is being created set up the subviews (front and back cards need to have the dimensions of the card container)
            front.frame = cardContainer.bounds
            back.frame = cardContainer.bounds
            cardContainer.addSubview(back)
            cardContainer.addSubview(front)
            
//            self.shadowOuterContainer.bringSubviewToFront(self.cardContainer)
//            self.shadowOuterContainer.bringSubviewToFront(self.cardContainer.back)
//            self.cardContainer.back.flipButton.addTarget(self, action: #selector(flip), for: .touchUpInside)
            
            firstSetup = false
        }
        
        if let ref = user["profile_picture"] as? String{ //profile picture
            baseStorageReference.child(ref).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                if let e = e {
                    print("Error obtaining image: ", e)
                }else{
                    self.front.img.image = UIImage(data: data!)
                    if var degree = user["degree"] as? String { //degree icon
                        degree = degree.replacingOccurrences(of: " ", with: "")
                        degree = degree.lowercased()
                        self.front.degreeIcon.image = UIImage(named: degree)
                        self.front.degreeIcon.tintColor = Colors.ivy_grey
                        
                    }
                    
                    self.front.name.text = user["first_name"] as? String //text data
                    self.back.name.text = String(user["first_name"] as? String ?? "Name") + " " + String(user["last_name"] as? String ?? "Name")
                    self.back.degree.text = user["degree"] as? String
                    self.back.age.text = user["age"] as? String
                    self.back.bio.text = user["bio"] as? String
                    self.back.setUpInterests(interests: user["interests"] as? [String] ?? [String]())
                    
                    self.endLoading()
                }
            }
        }
    }
    
    
    @objc func flip() { //a method that flips the card
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight) { (done) in
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.translatesAutoresizingMaskIntoConstraints = true
        }
        showingBack = !showingBack
    }
    
    
    
    
    
    // MARK: Loading Logic
    
    func startLoading(){
        loadingWheel.startAnimating()
        loadingWheel.isHidden = false
        front.isHidden = true
        back.isHidden = true
    }
    
    func endLoading(){
        loadingWheel.stopAnimating()
        loadingWheel.isHidden = true
        front.isHidden = false
        back.isHidden = false
    }

}

