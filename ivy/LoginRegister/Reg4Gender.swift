//
//  Reg4Gender.swift
//  ivy
//
//  Created by paul dan on 2019-07-14.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Reg4Gender: UIViewController {
    
    // MARK: Variables and Constants
    
    var gender = ""
    var registerInfoStruct = UserProfile(email:"", first_name: "", last_name: "") //will be overidden by the actual data
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    var password = ""   //carried over


    
    
    // MARK: IBOutlet and IBActions
    
    @IBOutlet weak var maleCheckbox: Checkbox!
    @IBOutlet weak var femaleCheckbox: Checkbox!
    @IBOutlet weak var otherCheckbox: Checkbox!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        errorLabel.isHidden = true //error label should be hidden by defualt
        setupCheckbox()
        setupListeners()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg5Degree
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first_name = self.registerInfoStruct.first_name ?? "no first name"
        vc.registerInfoStruct.last_name = self.registerInfoStruct.last_name ?? "no last name"
        vc.registerInfoStruct.gender = self.gender
        vc.password = self.password //set the password

    }
    
    func attemptToContinue() {
        if(self.gender != ""){ //make sure there is a value that exists for gender or else prompt to choose a gender
            self.performSegue(withIdentifier: "reg4ToReg5Segue", sender: self) //pass data over to the next screen
        }else{
            errorLabel.text = "Please select a gender before continuing."
            errorLabel.isHidden = false //error label should be hidden by defualt
        }
    }
    
    
    
    
    
    
    
    // MARK: UI Related Methods
    
    func setupCheckbox() {
        maleCheckbox.checkmarkStyle = .tick
        maleCheckbox.uncheckedBorderColor = .black
        maleCheckbox.checkedBorderColor = .black
        maleCheckbox.checkmarkColor = .black
        
        femaleCheckbox.checkmarkStyle = .tick
        femaleCheckbox.uncheckedBorderColor = .black
        femaleCheckbox.checkedBorderColor = .black
        femaleCheckbox.checkmarkColor = .black
        
        otherCheckbox.checkmarkStyle = .tick
        otherCheckbox.uncheckedBorderColor = .black
        otherCheckbox.checkedBorderColor = .black
        otherCheckbox.checkmarkColor = .black
    }
    
    func setupListeners() { //setup the listeneers that are waiting for values being changed
        //only allow one checkbox to be clicked at a time
        maleCheckbox.valueChanged = { (value) in
            //if male is true, then uncheck the other checkboxes
            if (value == true){
                self.femaleCheckbox.isChecked = false
                self.otherCheckbox.isChecked = false
                self.gender = "male"
            }else { //unchecks it without clicking something else, set gender to none again
                self.gender = ""
            }
        }
        
        femaleCheckbox.valueChanged = { (value) in //only allow one checkbox to be clicked at a time
            if (value == true){ //if male is true, then uncheck the other checkboxes
                self.maleCheckbox.isChecked = false
                self.otherCheckbox.isChecked = false
                self.gender = "female"
            }else { //unchecks it without clicking something else, set gender to none again
                self.gender = ""
            }
        }
        
        otherCheckbox.valueChanged = { (value) in
            //if male is true, then uncheck the other checkboxes
            if (value == true){
                self.maleCheckbox.isChecked = false
                self.femaleCheckbox.isChecked = false
                self.gender = "other"
            }else{ //unchecks it without clicking something else, set gender to none again
                self.gender = ""
            }
        }
    }
    
    
}
