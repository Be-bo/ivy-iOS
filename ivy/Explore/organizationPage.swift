//
//  organizationPage.swift
//  ivy
//
//  Created by paul dan on 2019-08-26.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore


class organizationPage: UIViewController {
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()             //reference to storage
    private var thisOrganization = Dictionary<String,Any>()
    
    //from segue
    public var userProfile = Dictionary<String,Any>()
    public var organizationId = ""
    
    
    
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var hyperlinkLabel: UILabel!
    @IBOutlet weak var organizationDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadOrganizationInfo()
    }
    
    
    
    //populate the pagew with the corresponding information that we want
    func bindData() {
        
        //set clickable url link
        let attributedString = NSMutableAttributedString(string: self.thisOrganization["website"] as! String)
        let url = URL(string: self.thisOrganization["website"] as! String)
        attributedString.setAttributes([.link: url], range: NSMakeRange(0, String(self.thisOrganization["website"] as! String).count))
        hyperlinkLabel.attributedText = attributedString  
        hyperlinkLabel.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickLink))
        hyperlinkLabel.addGestureRecognizer(singleTap)

        
        
        //TODO: set title on navbar to be the name of the organization
        organizationDescription.text = self.thisOrganization["mission_statement"] as! String
        
        

        self.baseStorageReference.child(self.thisOrganization["logo"] as! String).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error", error)
            } else {
                self.titleImageView.image  = UIImage(data: data!)
            }
        }
    }
    
    //Action
    @objc func clickLink() {
        let url = URL(string: self.thisOrganization["website"] as! String)
        UIApplication.shared.open(url!, options: [:])

    }
    
    
    //from the organization id, actually load the organization object
    func loadOrganizationInfo() {
        if (organizationId != ""){
            self.baseDatabaseReference.collection("organizations").document(organizationId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.thisOrganization = document.data()!
                    self.bindData()
                } else {
                    print("Document does not exist")
                }
            }

        }
    }
    
    
    
    
    
}
