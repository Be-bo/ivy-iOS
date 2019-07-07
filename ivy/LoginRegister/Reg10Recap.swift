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
    
    private var showingBack = false
    @IBOutlet weak var cardContainer: UIView!
    private let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    private let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frontImage = UIImage(named: "front")
        let backImage = UIImage(named: "back")
        
        front.frame = cardContainer.bounds
        back.frame = cardContainer.bounds
        
        if (Float((frontImage?.size.width)!) > Float((frontImage?.size.height)!)) {
            front.contentMode = .scaleAspectFit
        } else {
            front.contentMode = .scaleAspectFill
        }
        
        if (Float((backImage?.size.width)!) > Float((backImage?.size.height)!)) {
            back.contentMode = .scaleAspectFit
        } else {
            back.contentMode = .scaleAspectFill
        }
        back.clipsToBounds = true
        front.clipsToBounds = true
        
//        back.imgView.image = backImage
//        front.imgView.image = frontImage
        cardContainer.addSubview(front)
        
        
//        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
//        singleTap.numberOfTapsRequired = 1
//        cardContainer.addGestureRecognizer(singleTap)
    }
    
    @objc func flip() {
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight, completion: nil)
        showingBack = !showingBack
        
    }
    
}
