//
//  QuadNavigationViewController.swift
//  ivy
//
//  Created by Robert on 2019-08-02.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class QuadNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "settings")
        imgView.clipsToBounds = true
        self.navigationController?.navigationBar.addSubview(imgView)
    }
}
