//
//  Extensions.swift
//  ivy
//
//  Created by Robert on 2019-06-05.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    class func attributedButton(frame: CGRect) -> UIButton {
        let button = UIButton(frame: frame)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.borderWidth = 2.0
        button.backgroundColor = UIColor.ivyGreen
        return button
    }
}

extension UIColor {
    static let ivyGreen = UIColor(displayP3Red: 43, green: 151, blue: 33, alpha: 1)
    static let ivyGrey = UIColor(displayP3Red: 105, green: 105, blue: 105, alpha: 1)
    static let ivyLightGrey = UIColor(displayP3Red: 144, green: 144, blue: 144, alpha: 1)
    static let ivyVeryLightGrey = UIColor(displayP3Red: 237, green: 237, blue: 237, alpha: 1)
    static let ivyNotification = UIColor(displayP3Red: 254, green: 60, blue: 0, alpha: 1)
    static let ivyHint = UIColor(displayP3Red: 213, green: 213, blue: 213, alpha: 1)
}
