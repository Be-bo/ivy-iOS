//
//  Reg8InterestsChosen.swift
//  ivy
//
//  Created by paul dan on 2019-06-30.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class Reg8InterestsChocen: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let iconNames = ["Reading"];
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
    
    
    var interestChosen: String = "" //specific interest that has been chosen, empty at first
    var interestsChosen = [String]()   //hold number of interests they choose
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    // called for every single cell thats displayed on screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInterestsCell", for: indexPath) as! RegisterInterestsCell
        cell.label.text = labels[indexPath.row]
        
        if(interestsChosen.contains(cell.label.text!) ){
            cell.imgView.image = UIImage(named: "CheckMark")
        }else {
            cell.imgView.image = nil
        }
        
        
        return cell
    }
    
    func configureTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    // triggered when individual cells clicked -> covers cases where you can see the check mark (and select a different cell)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cl = tableView.cellForRow(at: indexPath) as! RegisterInterestsCell
        //if they click on the same interest again then remove ir from the array and get rid of checkmark
        if(interestsChosen.contains(cl.label.text!) ){
            let index = interestsChosen.firstIndex(of: cl.label.text!)
            interestsChosen.remove(at: index!)
            cl.imgView.image = nil
        }
        else {
            interestsChosen.append(cl.label.text!)
            cl.imgView.image = UIImage(named: "CheckMark")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "RegisterInterestsCell", bundle: nil), forCellReuseIdentifier: "RegisterInterestsCell")
        configureTableView()
    }
    

}
