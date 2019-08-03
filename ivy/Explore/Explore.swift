//
//  Explore.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class Explore: UIViewController {
    
    private var thisUserProfile = Dictionary<String, Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    private func setUpNavigationBar(){
        
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
        
        // this retarded bs is not working
        let settingsBtn = SettingsButton()
        let settingsButton = UIBarButtonItem(customView: settingsBtn)
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
        print("updated profile")
    }
}
