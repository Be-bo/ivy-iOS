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
    
    //initializers
    var gender = ""
    var registerInfoStruct = UserProfile(email:"", first: "", last: "") //will be overidden by the actual data
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database


    @IBOutlet weak var maleCheckbox: Checkbox!
    @IBOutlet weak var femaleCheckbox: Checkbox!
    @IBOutlet weak var otherCheckbox: Checkbox!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true //error label should be hidden by defualt
        setupCheckbox()
        setupListeners()
    }
    
    //on click of continue button
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Reg5Degree
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first = self.registerInfoStruct.first ?? "no first name"
        vc.registerInfoStruct.last = self.registerInfoStruct.last ?? "no last name"
        vc.registerInfoStruct.gender = self.gender
    }
    
    
    func attemptToContinue() {
        //make sure there is a value that exists for gender or else prompt to choose a gender
        if(self.gender != ""){
            self.performSegue(withIdentifier: "reg4ToReg5Segue", sender: self) //pass data over to
        }else{
            errorLabel.text = "Please select a gender before continuing."
            errorLabel.isHidden = false //error label should be hidden by defualt
        }
    }
    
    //styling for the checkboxes
    func setupCheckbox() {
        //make everything black on all three checkboxes
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
    
    //setup the listeneers that are waiting for values being changed
    func setupListeners() {
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
        
        //only allow one checkbox to be clicked at a time
        femaleCheckbox.valueChanged = { (value) in
            //if male is true, then uncheck the other checkboxes
            if (value == true){
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
