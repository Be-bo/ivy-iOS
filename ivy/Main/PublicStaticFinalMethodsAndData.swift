//
//  PublicStaticFinalMethodsAndData.swift
//  ivy
//
//  Created by Robert on 2019-09-03.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class PublicStaticMethodsAndData{
    
    static func createInfoDialog(titleText: String, infoText: String, context: UIViewController){
        let alert = UIAlertController(title: titleText, message: infoText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        context.present(alert, animated: true)
    }
}
