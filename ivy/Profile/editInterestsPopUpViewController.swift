//
//  editInterestsPopUpViewController.swift
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

class editInterestsPopUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var interestsChosen = [String]()   //hold number of interests they choose
    public var thisUserProfile = Dictionary<String,Any>()
    public var previousVC = Profile()
    
    
    private let baseStorageReference = Storage.storage().reference()
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database

    
    private let labels = [     "Reading",
                              "Cooking",
                              "Sports",
                              "Politics",
                              "Music",
                              "Painting",
                              "Volunteer",
                              "Traveling",
                              "Animals",
                              "Dancing",
                              "Writing",
                              "Socializing",
                              "Hanging with Friends",
                              "Partying",
                              "Video Games",
                              "Hitting the beach",
                              "Graphic Design",
                              "Computer Programming",
                              "Meditating",
                              "Puzzles",
                              "Photography",
                              "Drawing",
                              "Exercise",
                              "Working Out",
                              "Fantasy Sports",
                              "Legos",
                              "Singing",
                              "Movies",
                              "Yoga",
                              "Yo-yo",
                              "Television",
                              "Netflix",
                              "Chilling",
                              "Netfilx and Chilling",
                              "Knitting",
                              "Puddle Jumping",
                              "Cliff Jumping",
                              "Rock Climbing",
                              "Mountain Climbing",
                              "Hiking",
                              "Birdwatching",
                              "Camping",
                              "Glamping",
                              "Driving",
                              "Fishing",
                              "Long Boarding",
                              "Water Polo",
                              "Extreme Sports",
                              "Surfing",
                              "Sailing",
                              "Extreme Taco Eating",
                              "Biking",
                              "Rugby",
                              "Football",
                              "Soccer",
                              "Basketball",
                              "Walking",
                              "Badminton",
                              "Volleyball",
                              "Laser Tag",
                              "Tag",
                              "Freeze Tag",
                              "Upholstery",
                              "Woodwork",
                              "Welding",
                              "The environment",
                              "Working",
                              "Twerking",
                              "Clubbing",
                              "Pool",
                              "Foosball",
                              "Watching the office",
                              "Watching friends",
                              "Pokémon",
                              "Skateboarding",
                              "Acting",
                              "Theater",
                              "Home movies",
                              "Interior Design",
                              "Design",
                              "Fashion",
                              "Fashion Design" ]
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.hideKeyboardOnTapOutside()
        
        configureTableView()

    }
    
    
    
    @IBAction func onClickClose(_ sender: Any) {
        self.view.removeFromSuperview()
        dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
    }
    
    
    
    @IBAction func onClickDone(_ sender: Any) {
        changeInterests()
    }
    
    
    func changeInterests() {
        
        if(!self.interestsChosen.isEmpty && self.interestsChosen.count > 1){
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["interests":self.interestsChosen])
            self.previousVC.thisUserProfile["interests"] = self.interestsChosen
            self.previousVC.back.setUpInterests(interests: self.interestsChosen)
            self.view.removeFromSuperview()
            dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
        }
    }
    
    
    
    // MARK: TableView Methods
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RegisterInterestsCell", bundle: nil), forCellReuseIdentifier: "RegisterInterestsCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInterestsCell", for: indexPath) as! RegisterInterestsCell
        cell.label.text = labels[indexPath.row]
        
        if(self.interestsChosen.contains(cell.label.text!) ){
            cell.imgView.image = UIImage(named: "check")
        }else {
            cell.imgView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //triggered when individual cells clicked -> covers cases where you can see the check mark (and select a different cell)
        let cl = tableView.cellForRow(at: indexPath) as! RegisterInterestsCell
        //if they click on the same interest again then remove ir from the array and get rid of checkmark
        if(self.interestsChosen.contains(cl.label.text!) ){
            let index = self.interestsChosen.firstIndex(of: cl.label.text!)
            self.interestsChosen.remove(at: index!)
            cl.imgView.image = nil
        }
        else {
            self.interestsChosen.append(cl.label.text!)
            cl.imgView.image = UIImage(named: "check")
        }
    }

    

}
