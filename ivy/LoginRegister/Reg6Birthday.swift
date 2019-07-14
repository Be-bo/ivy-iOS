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

    //initializers
    var registerInfoStruct = UserProfile(email: "", first: "", last: "", gender: "", degree: "") //will be overidden by the actual data
    var dateFormatter = DateFormatter()
    var selectedDate = ""
    
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd MMMM yyyy"   //format the date will be added to userProfile object
        print("birthday screen ", registerInfoStruct)
    }
    
    
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Reg7Bio
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first = self.registerInfoStruct.first ?? "no first name"
        vc.registerInfoStruct.last = self.registerInfoStruct.last ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birthday = self.selectedDate
    }
    
    
    func attemptToContinue() {
        self.selectedDate = self.dateFormatter.string(from: dataPicker.date) //extract date in right format
        if (selectedDate != ""){
            self.performSegue(withIdentifier: "reg6ToReg7Segue", sender: self) //pass data over to

        }else{
            //please enter a valid brithdate
        }
        
    }
    
}
