//
//  registerPageSeven.swift
//  ivy
//
//  Created by paul dan on 2019-06-23.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class registerPageSeven: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting border color of the bio text field
        let borderColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0);
        bioTextView.layer.masksToBounds = true;
        bioTextView.layer.borderColor = borderColor.cgColor;
        bioTextView.layer.borderWidth = 1.0;    //thickness
        bioTextView.layer.cornerRadius = 10.0;  //rounded corner
        
        bioTextView.delegate = self;
    }
    
    //on input change of the bio text view we wanna indicate to the user what the count of chars left
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = bioTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        characterCountLabel.text = String(changedText.count) + "/160"
        
        return changedText.count <= 160
    }
    
    
}
