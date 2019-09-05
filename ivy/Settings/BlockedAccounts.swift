//
//  BlockedAccounts.swift
//  ivy
//
//  Created by paul dan on 2019-09-03.
//  Copyright © 2019 ivy social network. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class BlockedAccounts: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage
    
    //passed through settings segue
    public var thisUserProfile = Dictionary<String, Any>()
    
    private var allBLockedAccounts:[Dictionary<String,Any>] = []    //holds all blocked accounts

    public var previousVC = Settings()
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
    }
    
    
    //load all this users blocked accounts
    func loadBlockedAccounts() {
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("block_list").getDocument { (document, error) in
            if let document = document, document.exists {
                for (blockedId,millis) in document.data()!{
                    print("blockedid", blockedId)
                    self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(blockedId).getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.allBLockedAccounts.append(document.data()!)
                            self.tableView.reloadData()
                        } else {
                            print("Document does not exist here!!!!")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }

    }
    
    
    
    
    // MARK: TableView Methods
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "blockedAccTableViewCell", bundle: nil), forCellReuseIdentifier: "blockedAccTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        self.loadBlockedAccounts()

        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBLockedAccounts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedAccTableViewCell", for: indexPath) as! blockedAccTableViewCell
        tableView.bringSubviewToFront(cell)
        tableView.bringSubviewToFront(cell.unblockUserButton)
        cell.selectionStyle  = .default
        
        cell.setUp(user: self.allBLockedAccounts[indexPath.item], thisUserProfile: self.thisUserProfile, previousVC: self.previousVC)
        
        
        return cell
    }
    
    
    
    
    
    
    
}
