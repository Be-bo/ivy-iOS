//
//  Reg6Birthday.swift
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

class Reg6Birthday: UIViewController {

    // MARK: Variables and Constants
    
    var registerInfoStruct = UserProfile(age: 0, banned: nil, bio: "", birth_time: nil, degree: "") //will be overidden by the actual data
    var dateFormatter = DateFormatter()
    var selectedDate = ""
    var password = ""   //user passwordhe wishes to use
    var millis:Int64? = nil
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        dateFormatter.dateFormat = "dd MMMM yyyy"   //format the date will be added to userProfile object
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg7Bio
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first_name = self.registerInfoStruct.first_name ?? "no first name"
        vc.registerInfoStruct.last_name = self.registerInfoStruct.last_name ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birth_time = self.millis
        vc.password = self.password
    }
    
    func attemptToContinue() {
        self.selectedDate = self.dateFormatter.string(from: dataPicker.date) //extract date in right format
        print("selected date: ", self.selectedDate)
        self.millis = Int64(dataPicker.date.timeIntervalSince1970)
        print("self.millis: ", self.millis)
        if (selectedDate != ""){
            self.performSegue(withIdentifier: "reg6ToReg7Segue", sender: self) //pass data over to
        }else{
            //please enter a valid brithdate
        }
        
    }
    
}
