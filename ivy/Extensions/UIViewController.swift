//
//  UIViewController.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-27.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
// Put this piece of code anywhere you like
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
