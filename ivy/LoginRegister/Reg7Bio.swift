//
//  registerPageSeven.swift
//  ivy
//
//  Created by paul dan on 2019-06-23.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class Reg7Bio: UIViewController, UITextViewDelegate {
    
    //initializers
    var registerInfoStruct = UserProfile(email: "", first: "", last: "", gender: "", degree: "", birthday: "") //will be overidden by the actual data
    var bio = ""

    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureBioTextView()
    
    }
    
    
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }


    
    //on input change of the bio text view we wanna indicate to the user what the count of chars left
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = bioTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        //get rid of tghe 161/160 bug by cheching if the count ever gets to 161 then just subtracting 1 on display
        if (String(changedText.count) == "161"){
            characterCountLabel.text = String(changedText.count - 1) + "/160"
        }else {
            characterCountLabel.text = String(changedText.count) + "/160"
        }
        return changedText.count <= 160
    }
    
    //setup the bio text view with rounded corners and what not
    func cofigureBioTextView() {
        //Setting border color of the bio text field
        let borderColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0);
        self.bioTextView.layer.masksToBounds = true;
        self.bioTextView.layer.borderColor = borderColor.cgColor;
        self.bioTextView.layer.borderWidth = 1.0;    //thickness
        self.bioTextView.layer.cornerRadius = 10.0;  //rounded corner
        
        self.bioTextView.delegate = self;
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Reg8Interests
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first = self.registerInfoStruct.first ?? "no first name"
        vc.registerInfoStruct.last = self.registerInfoStruct.last ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birthday = self.registerInfoStruct.birthday ?? "no birthday"
        vc.registerInfoStruct.bio = self.bio
    }
    
    func attemptToContinue() {
        self.bio = bioTextView.text ?? ""   //extract the bio even if its empty
        self.performSegue(withIdentifier: "reg7ToReg8Segue" , sender: self) //pass data over to

    }
    
    
}
