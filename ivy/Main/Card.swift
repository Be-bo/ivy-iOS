//
//  Card.swift
//  ivy
//
//  Created by Robert on 2019-08-04.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase

class Card: UICollectionViewCell {
    
    // MARK: Variables and Constants
    
    private let baseStorageReference = Storage.storage().reference()
    private var showingBack = false
    private var firstSetup = true
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    
    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var cardContainer: Card!
    @IBOutlet weak var shadowOuterContainer: Card!
    
    
    
    
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
    
        if(firstSetup){ //if it's the first time this xib is being created set up the subviews (front and back cards need to have the dimensions of the card container)
            front.frame = cardContainer.bounds
            back.frame = cardContainer.bounds
            cardContainer.addSubview(back)
            cardContainer.addSubview(front)
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip)) //and set the on click listener to the card
            singleTap.numberOfTapsRequired = 1
            shadowOuterContainer.addGestureRecognizer(singleTap)
            
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
    
    @objc func flip() { //a method that flips the card
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight) { (done) in
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.translatesAutoresizingMaskIntoConstraints = true
        }
        showingBack = !showingBack
    }

}
