//
//  Reg5UserDegree.swift
//  ivy
//
//  Created by Robert on 2019-06-23.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Reg5Degree: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: Variables and Constants
    var password = ""   //carried over
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    var registerInfoStruct = UserProfile(age:"", banned: nil, bio: "", birth_time:nil) //will be overidden by the actual data
    var currentDegree = "Accounting"
    let iconNames = [
        "accounting",
        "biology", "businessadministration",
        "chemistry", "computerscience",
        "dentistry",
        "economics", "education", "engineering", "english",
        "finance", "finearts",
        "geography",
        "history",
        "marketing", "math",
        "politicalscience", "psychology",
        "sociology",
        "lawandsociety", "law",
        "medicine",
        "nursing",
        "physics", "philosophy"
    ]
    let degreeNames = ["Accounting",
                       "Biology", "Business Administration",
                       "Chemistry", "Computer Science",
                       "Dentistry",
                       "Economics", "Education", "Engineering", "English",
                       "Finance", "Fine Arts",
                       "Geography",
                       "History",
                       "Marketing", "Math",
                       "Political Science", "Psychology",
                       "Sociology",
                       "Law & Society", "Law",
                       "Medicine",
                       "Nursing",
                       "Physics", "Philosophy"]
    
    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var degreeTableView: UITableView!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        errorLabel.isHidden = true //error label should be hidden by defualt
        degreeTableView.delegate = self
        degreeTableView.dataSource = self
        degreeTableView.register(UINib(nibName: "DegreeCell", bundle: nil), forCellReuseIdentifier: "DegreeCell")
        configureTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg6Birthday
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first_name = self.registerInfoStruct.first_name ?? "no first name"
        vc.registerInfoStruct.last_name = self.registerInfoStruct.last_name ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.currentDegree
        vc.password = self.password //set the password

    }
    
    func attemptToContinue() {
        if (currentDegree != "") {
            self.performSegue(withIdentifier: "reg5ToReg6Segue", sender: self) //pass data over to
            
        }else { //prompt to choose a degree
            errorLabel.text = "Please choose a degree"
            errorLabel.isHidden = false //error label should be hidden by defualt
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: TableView Methods
    
    func configureTableView(){
        degreeTableView.separatorStyle = .none
        degreeTableView.rowHeight = UITableView.automaticDimension
        degreeTableView.estimatedRowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return degreeNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //on scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "DegreeCell", for: indexPath) as! DegreeCell
        cell.degreeLabel.text = degreeNames[indexPath.row]
        cell.degreeImageView.image = UIImage(named: iconNames[indexPath.row])
        if(cell.degreeLabel.text == currentDegree){
            cell.checkImageView.image = UIImage(named: "check")
        }else{
            cell.checkImageView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //on tap
        let indexPaths = degreeTableView.indexPathsForVisibleRows!
        for indexP in indexPaths{
            let cl = tableView.cellForRow(at: indexP) as! DegreeCell
            if(cl.degreeLabel.text == currentDegree){
                cl.checkImageView.image = nil
            }
        }
        let newCell = degreeTableView.cellForRow(at: indexPath)! as! DegreeCell
        currentDegree = newCell.degreeLabel.text!
        newCell.checkImageView.image = UIImage(named: "check")
    }
}
