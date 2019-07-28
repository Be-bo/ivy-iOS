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
    static let ivyGreen = UIColor(displayP3Red: 43/255, green: 151/255, blue: 33/255, alpha: 1)
    static let ivyGrey = UIColor(displayP3Red: 105/255, green: 105/255, blue: 105/255, alpha: 1)
    static let ivyLightGrey = UIColor(displayP3Red: 144/255, green: 144/255, blue: 144/255, alpha: 1)
    static let ivyVeryLightGrey = UIColor(displayP3Red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
    static let ivyNotification = UIColor(displayP3Red: 254/255, green: 60/255, blue: 0, alpha: 1)
    static let ivyHint = UIColor(displayP3Red: 213/255, green: 213/255, blue: 213/255, alpha: 1)
}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))!
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
}
