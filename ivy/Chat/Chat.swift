//
//  Chat.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Chat: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //initializers
    var activeChats = [String]()   //hold number of chats that are currentley active for the authenticated user
    var conversations = ["Test","Test1", "Test2"]
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database

    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        //load the conversations that are active for the current user
        if Auth.auth().currentUser != nil {
            print("user is signed in")
            let user = Auth.auth().currentUser  //get the object representing the user
            if let user = user {
                let uid = user.uid
                // ...
            }
            print("elons id:", user?.uid)
            print("the user object",  user)
            
//            baseDatabaseReference.collection("universities").document(user.uni_domain)
        } else {
            print("no user signed in")
        }
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RegisterInterestsCell", bundle: nil), forCellReuseIdentifier: "RegisterInterestsCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterInterestsCell", for: indexPath) as! RegisterInterestsCell
        cell.label.text = conversations[indexPath.row]
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //triggered when individual cells clicked -> covers cases where you can see the check mark (and select a different cell)

    }
    
    
    
}
