//
//  peopleViewingTopicView.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-31.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import UIKit

class peopleViewingTopicView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    @IBOutlet weak var peopleLookingLabel: UITextField!
    @IBOutlet weak var groupImage: UIImageView!
    

    class func createMyClassView() -> peopleViewingTopicView {
        let myClassNib = UINib(nibName: "peopleViewingTopic", bundle: nil)
        return myClassNib.instantiate(withOwner: nil, options: nil)[0] as! peopleViewingTopicView
    }



    


}
