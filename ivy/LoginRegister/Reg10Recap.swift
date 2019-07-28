//
//  Reg10Recap.swift
//  ivy
//
//  Created by Robert on 2019-07-07.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class Reg10Recap: UIViewController {
    
    var registerInfoStruct = UserProfile(email: "", first: "", last: "", gender: "", degree: "", birthday: "", bio:"", interests: [""], imageByteArray: nil ) //will be overidden by the actual data

    
    private var showingBack = false
    @IBOutlet weak var cardContainer: UIView!
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpContainer()
        let frontImage = UIImage(data: self.registerInfoStruct.imageByteArray! as Data,scale: 1.0)
        front.frame = cardContainer.bounds
        back.frame = cardContainer.bounds
        
        front.img.image = frontImage
        cardContainer.addSubview(front)
        
        var firstAndLast = self.registerInfoStruct.first! + " " + self.registerInfoStruct.last!
        var age = "10"
        back.age.text = age
        back.name.text = firstAndLast
        back.degree.text = self.registerInfoStruct.degree!
        back.bio.text = self.registerInfoStruct.bio!
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
        singleTap.numberOfTapsRequired = 1
        cardContainer.addGestureRecognizer(singleTap)
    }
    
    @objc func flip() {
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight, completion: nil)
        showingBack = !showingBack
        setUpContainer()
        
    }
    
    func setUpContainer(){
        cardContainer.layer.shadowPath = UIBezierPath(roundedRect: cardContainer.bounds, cornerRadius: cardContainer.layer.cornerRadius).cgPath
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.25
        cardContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardContainer.layer.shadowRadius = 5
        cardContainer.layer.cornerRadius = 5
        cardContainer.layer.masksToBounds = false
    }
    
}
