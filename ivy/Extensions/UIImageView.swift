//
//  UIImageView.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-27.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    //https://stackoverflow.com/questions/25587713/how-to-set-imageview-in-circle-like-imagecontacts-in-swift-correctly
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true

        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        self.image = anyImage
      }
}
