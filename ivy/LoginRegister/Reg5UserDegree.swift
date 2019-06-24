//
//  Reg5UserDegree.swift
//  ivy
//
//  Created by Robert on 2019-06-23.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Foundation

class Reg5UserDegree: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: Variables, Constants and IBOutlets
    
    @IBOutlet weak var degreeTableView: UITableView!
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
    
    
    
    
    // MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        degreeTableView.delegate = self
        degreeTableView.dataSource = self
        degreeTableView.register(UINib(nibName: "DegreeCell", bundle: nil), forCellReuseIdentifier: "DegreeCell")
        configureTableView()
    }
    
    
    
    
    
    
    
    
    // MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return degreeNames.count
    }
    
    // on scroll
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DegreeCell", for: indexPath) as! DegreeCell
        cell.degreeLabel.text = degreeNames[indexPath.row]
        cell.degreeImageView.image = UIImage(named: iconNames[indexPath.row])
        if(cell.degreeLabel.text == currentDegree){
            cell.checkImageView.image = UIImage(named: "CheckMark")
        }else{
            cell.checkImageView.image = nil
        }
        return cell
    }
    
    // on tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPaths = degreeTableView.indexPathsForVisibleRows!
        for indexP in indexPaths{
            let cl = tableView.cellForRow(at: indexP) as! DegreeCell
            if(cl.degreeLabel.text == currentDegree){
                cl.checkImageView.image = nil
            }
        }
        let newCell = degreeTableView.cellForRow(at: indexPath)! as! DegreeCell
        currentDegree = newCell.degreeLabel.text!
        newCell.checkImageView.image = UIImage(named: "CheckMark")
    }
    
    func configureTableView(){
        degreeTableView.separatorStyle = .none
        degreeTableView.rowHeight = UITableView.automaticDimension
        degreeTableView.estimatedRowHeight = 70
    }
    
    
}
