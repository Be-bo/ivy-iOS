//
//  ShareAppController.swift
//  ivy-iOS
//
//  Created by Robert on 2020-02-14.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import MessageUI

class ShareAppController: MFMailComposeViewController, MFMailComposeViewControllerDelegate{
    
    var owner: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true){
            PublicStaticMethodsAndData.createInfoDialog(titleText: "Thanks!", infoText: "Thanks for sharing ivy (or at least considering it)!", context: self.owner!)
        }
    }
}
