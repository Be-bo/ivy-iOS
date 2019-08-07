//
//  Board.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class Board: UIViewController{
    
    private var thisUserProfile = Dictionary<String, Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
//        tabBarController?.tabBarItem.c
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
    }
}
