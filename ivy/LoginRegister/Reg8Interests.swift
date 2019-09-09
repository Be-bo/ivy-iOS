//
//  Reg8InterestsChosen.swift
//  ivy
//
//  Created by paul dan on 2019-06-30.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class Reg8Interests: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Variables and Constants
    var password = ""   //carried over
    var interestChosen: String = "" //specific interest that has been chosen, empty at first
    var interestsChosen = [String]()   //hold number of interests they choose
    var registerInfoStruct = UserProfile(age: 0, banned: nil, bio: "", birth_time: nil, degree: "", email: "", first_name: "") //will be overidden by the actual data
    let labels = [            "Reading",
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

    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        configureTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg9Photo
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first_name = self.registerInfoStruct.first_name ?? "no first name"
        vc.registerInfoStruct.last_name = self.registerInfoStruct.last_name ?? "no last name"
        vc.registerInfoStruct.gender = self.registerInfoStruct.gender ?? "no gender"
        vc.registerInfoStruct.degree = self.registerInfoStruct.degree ?? "no degree"
        vc.registerInfoStruct.birth_time = self.registerInfoStruct.birth_time ?? nil
        vc.registerInfoStruct.bio = self.registerInfoStruct.bio ?? "no bio"
        vc.registerInfoStruct.interests = self.interestsChosen
        vc.password = self.password //set the password

    }
    
    func attemptToContinue() {
        if (interestsChosen.isEmpty == false){ //if they press continue they must have chosen atleast one interest
            self.performSegue(withIdentifier: "reg8ToReg9Segue" , sender: self) //pass data over to
        }else {
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
        
        if(interestsChosen.contains(cell.label.text!) ){
            cell.imgView.image = UIImage(named: "check")
        }else {
            cell.imgView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //triggered when individual cells clicked -> covers cases where you can see the check mark (and select a different cell)
        let cl = tableView.cellForRow(at: indexPath) as! RegisterInterestsCell
        //if they click on the same interest again then remove ir from the array and get rid of checkmark
        if(interestsChosen.contains(cl.label.text!) ){
            let index = interestsChosen.firstIndex(of: cl.label.text!)
            interestsChosen.remove(at: index!)
            cl.imgView.image = nil
        }
        else {
            interestsChosen.append(cl.label.text!)
            cl.imgView.image = UIImage(named: "check")
        }
    }
    
    
}
