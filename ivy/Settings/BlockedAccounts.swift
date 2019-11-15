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
    
    private let baseDatabaseReference = Firestore.firestore()
    private let baseStorageReference = Storage.storage().reference()
    public var thisUserProfile = Dictionary<String, Any>()
    private var allBLockedAccounts:[Dictionary<String,Any>] = []
    private var userToUnblock = Dictionary<String,Any>()
    public var previousVC = Settings()
    @IBOutlet weak var tableView: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Blocked Accounts"
        configureTableView()
        loadBlockedAccounts()
    }

    func loadBlockedAccounts() { //load all this users blocked accounts
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("block_list").getDocument { (document, error) in
            if let document = document, document.exists {
                if let docData = document.data(){
                    for (blockedId, millis) in docData{
                        
                        if let uniDomain = self.thisUserProfile["uni_domain"] as? String{
                            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(blockedId).getDocument { (document, error) in
                                if let document = document, document.exists, let blockedAccountData = document.data() {
                                    self.allBLockedAccounts.append(blockedAccountData)
                                    self.tableView.reloadData()
                                    
                                    let iPath = IndexPath(row: 0, section: 0) //first item selection block, gotta be called each time the "reloadData" is called because that call deselects all items
                                    self.tableView.selectRow(at: iPath, animated: false, scrollPosition: .none)
                                    self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: iPath)
                                } else {
                                    print("Document does not exist here!!!!")
                                }
                            }
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
        tableView.allowsSelectionDuringEditing = false
        tableView.allowsSelection = false
//        tableView.rowHeight = 100
//        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBLockedAccounts.count
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let selectedCell = self.tableView.cellForRow(at: indexPath) as? blockedAccTableViewCell{
//            userToUnblock = selectedCell.userToUnblock
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // called for every single cell thats displayed on screen
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedAccTableViewCell", for: indexPath) as! blockedAccTableViewCell
        tableView.bringSubviewToFront(cell)
        tableView.bringSubviewToFront(cell.unblockUserButton)
        cell.setUp(user: self.allBLockedAccounts[indexPath.item], thisUserProfile: self.thisUserProfile, previousVC: self)
        cell.unblockUserButton.addTarget(self, action: #selector(didXButtonClick), for: .touchUpInside)
        cell.unblockUserButton.tag = indexPath.item
        return cell
    }
    
    @objc func didXButtonClick(sender: AnyObject) {
        self.userToUnblock = self.allBLockedAccounts[sender.tag]
        unblockUser()
    }
    
    //remove this user's id from the "blocked_by" list of the blocked user and also remove blocker user's id from this user's "block_list", and update the adapter
    func unblockUser() {
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisUserId = self.thisUserProfile["id"] as? String, let toUnblockId = self.userToUnblock["id"] as? String{
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUserId).collection("userlists").document("block_list").updateData([toUnblockId: FieldValue.delete()])
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(toUnblockId).collection("userlists").document("blocked_by").updateData([thisUserId: FieldValue.delete()], completion: { (error) in
                if error != nil {
                } else {
                    for i in 0..<self.allBLockedAccounts.count{
                        if let id = self.allBLockedAccounts[i]["id"] as? String, id == toUnblockId{
                            self.allBLockedAccounts.remove(at: i)
                            self.tableView.reloadData()
                            if(self.allBLockedAccounts.count > 0){
                                let iPath = IndexPath(row: 0, section: 0)
                                self.tableView.selectRow(at: iPath, animated: false, scrollPosition: .none)
                                self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: iPath)
                            }
                            break
                        }
                    }
                }
            })
        }
    }
}
