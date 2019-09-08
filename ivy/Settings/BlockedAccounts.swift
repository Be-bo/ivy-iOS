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
    private var userToUnblock = Dictionary<String,Any>()

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
        tableView.allowsSelection = false   //doesn't highlight when clicked
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "blockedAccTableViewCell", bundle: nil), forCellReuseIdentifier: "blockedAccTableViewCell")
        tableView.rowHeight = 120
        tableView.estimatedRowHeight = 120
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
        
        cell.setUp(user: self.allBLockedAccounts[indexPath.item], thisUserProfile: self.thisUserProfile, previousVC: self)
        
//        cell.unblockUserButton.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        cell.unblockUserButton.tag = indexPath.row
        cell.unblockUserButton.addTarget(self, action: #selector(didXButtonClick), for: .touchUpInside)
        
        
        
        return cell
    }
    
    
    
    
    @objc func didXButtonClick(sender: AnyObject) {
        
        //extract the user they actually clicked on based on the tag from the sender button
        self.userToUnblock = self.allBLockedAccounts[sender.tag]

        
        //remove user from all blocked accounts, and remove that cell from the table view, then reload to have right index paths
        self.allBLockedAccounts.remove(at: sender.tag)
                self.tableView.deleteRows(at: [
            NSIndexPath(row: sender.tag, section: 0) as IndexPath], with: .fade)
        self.tableView.reloadData()
        
        unblockUser()

    }
    
    
    //remove this user's id from the "blocked_by" list of the blocked user and also remove blocker user's id from this user's "block_list", and update the adapter
    func unblockUser() {
        
        
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("block_list").updateData([self.userToUnblock["id"] as! String: FieldValue.delete()])
        
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.userToUnblock["id"] as! String).collection("userlists").document("blocked_by").updateData([self.thisUserProfile["id"] as! String: FieldValue.delete()], completion: { (error) in
            if error != nil {
            } else {
                //TODO: remove the cell from the table view
                //TODO: reload the tableview
            }
        })
        
        
    }
    
    
    
    
    
    
    
}
