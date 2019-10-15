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
    
    // MARK: Variables and Constants
    
    var registerInfoStruct = UserProfile( age: 0, banned: nil, bio: "", birth_time: nil, degree: "", email:"") //will be overidden by the actual data
    var bio = ""
    var password = ""   //carried over

    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        configureTextView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segway is called
        let vc = segue.destination as! Reg8Interests
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first_name = self.registerInfoStruct.first_name ?? "no first name"
        vc.registerInfoStruct.last_name = self.registerInfoStruct.last_name ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birth_time = self.registerInfoStruct.birth_time ?? nil
        vc.registerInfoStruct.bio = self.bio
        vc.password = self.password //set the password

    }
    
    func attemptToContinue() {
        self.bio = bioTextView.text ?? ""   //extract the bio even if its empty
        self.performSegue(withIdentifier: "reg7ToReg8Segue" , sender: self) //pass data over to
        
    }
    
    
    

    

    // MARK: UI Related Methods
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { //on input change of the bio text view we wanna indicate to the user what the count of chars left
        let currentText = bioTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        //get rid of the 161/160 bug by checking if the count ever gets to 161 then just subtracting 1 on display
        if (String(changedText.count) == "161"){
            characterCountLabel.text = String(changedText.count - 1) + "/160"
        }else {
            characterCountLabel.text = String(changedText.count) + "/160"
        }
        return changedText.count <= 160
    }
    
    func configureTextView() { //setup the bio text view with rounded corners and what not
        //Setting border color of the bio text field
        self.bioTextView.layer.masksToBounds = true;
        self.bioTextView.layer.borderColor = UIColor.ivyGrey.cgColor
        self.bioTextView.layer.borderWidth = 1.0;    //thickness
        self.bioTextView.layer.cornerRadius = 10.0;  //rounded corner
        
        self.bioTextView.delegate = self;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //a function that handles return key press on user's keyboard
        textField.resignFirstResponder() //simply close the keyboards with the press of the return key
        return false
    }
}
