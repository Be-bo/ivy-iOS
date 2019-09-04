//
//  editDegreePopUpViewController.swift
//  ivy
//
//  Created by paul dan on 2019-09-04.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class editDegreePopUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    public var currentDegree = ""                                  //holds the current degree the user has. passed from segue
    public var thisUserProfile = Dictionary<String,Any>()
    public var previousVC = Profile()
    
    
    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    
    @IBOutlet weak var closeButton: StandardButton!
    @IBOutlet weak var doneButton: StandardButton!
    
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
    
    



    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.hideKeyboardOnTapOutside()
        
        
        configureTableView()
        
    }
    
    
    @IBAction func onClickCloseButton(_ sender: Any) {
        self.view.removeFromSuperview()
        dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
    }
    
    
    @IBAction func onClickDoneButton(_ sender: Any) {
        changeDegree()

    }
    
    
    
    //actually change this users degree
    func changeDegree() {
        
        if(self.currentDegree != "") {
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile["id"] as! String).updateData(["degree":self.currentDegree])
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["degree":self.currentDegree])
            
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile["id"] as! String).updateData(["memo":self.makeMemo(currentDegree: self.currentDegree)])
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile["id"] as! String).updateData(["memo_millis":Date().timeIntervalSince1970])
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userpreviews").document(self.thisUserProfile["id"] as! String).updateData(["update_has_image":false])
            
            self.previousVC.back.degree.text = self.currentDegree
            self.previousVC.thisUserProfile["degree"] = self.currentDegree
            self.view.removeFromSuperview()
            dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
        }
    }
    
    func makeMemo(currentDegree:String) -> String{
        var calling = "their"
        if(self.thisUserProfile["gender"] as! String == "Male"){
            calling = "his"
        }else if (self.thisUserProfile["gender"] as! String == "Female"){
            calling = "her"
        }
        
        return "Changed " + calling + " degree to " + currentDegree + "."
    }
    
    
    
    // MARK: TableView Methods
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DegreeCell", bundle: nil), forCellReuseIdentifier: "DegreeCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
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
        let indexPaths = tableView.indexPathsForVisibleRows!
        for indexP in indexPaths{
            let cl = tableView.cellForRow(at: indexP) as! DegreeCell
            if(cl.degreeLabel.text == currentDegree){
                cl.checkImageView.image = nil
            }
        }
        let newCell = tableView.cellForRow(at: indexPath)! as! DegreeCell
        self.currentDegree = newCell.degreeLabel.text!
        newCell.checkImageView.image = UIImage(named: "check")
    }
    
    
    
    
}
