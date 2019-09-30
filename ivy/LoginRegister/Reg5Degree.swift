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
    var registerInfoStruct = UserProfile(age:0, banned: nil, bio: "", birth_time:nil) //will be overidden by the actual data
    var currentDegree = "Accounting"
    let iconNames = [
        "accounting", "actuarialScience", "ancientAndMedievalHistory", "anthropology", "appliedscience", "archaeology", "architecture", "artHistory", "astrophysics",
        "biology", "businessadministration", "biochemistry", "bioinformatics", "biomechanics", "biomedicalSciences", "businessAnalytics", "businessTechnologyManagement", "businessAdmin", "businessStrategy",
        "chemistry", "computerscience", "canadianStudies", "cmandb", "chemicalEngineering", "civilEngineering", "communicationandMediaStudies", "communityRehabilitation", "commerce",
        "dentistry", "dance", "developmentStudies", "drama",
        "economics", "education", "engineering", "english", "earthSciences", "eastAsianLanguageStudies", "ecology", "electricalEngineering", "energy", "entrepreneurshipandinnovation", "environment",
        "finance", "finearts", "french", "film",
        "geography", "geology", "geophysics", "german", "greekandroman",
        "history", "health",
        "indigenous", "internationalrelations", "italian",
        "kinesiology",
        "lawandsociety", "law", "latinamerican", "leadership", "linguistics",
        "marketing", "math", "medicine", "mastersStudent",
        "nursing",
        "politicalscience", "psychology", "physiology", "physics", "philosophy", "plantBiology",
        "realEstate", "religiousStudies", "riskManagementAndInsurance", "russian",
        "socialWork", "sociology", "softwareEngineering", "spanish",
        "urbanStudies",
        "vet",
        "womensStudies",
        "zoology"
    ]
    
    let degreeNames = ["Accounting", "Actuarial Science", "Ancient and Medieval History", "Anthropology", "Applied Science", "Archaeology", "Architecture", "Art History", "Astrophysics",
                       "Biology", "Business Administration", "Biochemistry", "Bioinformatics", "Biomechanics", "Biomedical Sciences", "Business Analytics", "Business Technology Management", "Business Administration", "Business Strategy",
                       "Chemistry", "Computer Science", "Canadian Studies", "Cellular, Molecular, and Microbial Biology", "Chemical Engineering", "Civil Engineering", "Communication and Media Studies", "Community Rehabilitation", "Commerce",
                       "Dentistry", "Dance", "Development Studies", "Drama",
                       "Economics", "Education", "Engineering", "English", "Earth Sciences", "East Asian Studies", "Ecology", "Electrical Engineering", "Energy", "Entrepreneurship and Innovation", "Environment",
                       "Finance", "Fine Arts", "French", "Film",
                       "Geography", "Geology", "Geophysics", "German", "Greek and Roman",
                       "History", "Health",
                       "Indigenous Studies", "International Relations", "Italian",
                       "Kinesiology",
                       "Law and Society", "Law", "Latin American Studies", "Leadership", "Linguistics",
                       "Marketing", "Math", "Medicine", "Masters Degree",
                       "Nursing",
                       "Political Science", "Psychology", "Physiology", "Physics", "Philosophy", "Plant Biology",
                       "Real Estate", "Religious Studies", "Risk Management and Insurance", "Russian",
                       "Social Work", "Sociology", "Software Engineering", "Spanish",
                       "Urban Studies",
                       "Veterinary Medicine",
                       "Women's Studies",
                       "Zoology"
    ]
    
    
    
    
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
