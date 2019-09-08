//
//  SearchCell.swift
//  ivy
//
//  Created by Robert on 2019-09-04.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase

class SearchCell: UICollectionViewCell {
    
    // MARK: Baseline

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameText: StandardLabel!
    let baseStorageReference = Storage.storage().reference()
    var delegate: SearchCellDelegator!
    var thisResult = Dictionary<String, Any>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true //for tap gesture recognizers
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    
    
    // MARK: Setup
    
    func setUp(searchResult: Dictionary<String, Any>){
        self.thisResult = searchResult
        if let type = searchResult["search_type"] as? String{
            switch(type){ //distinguish between the different types of search results
                
            //EVENT
            case "event":
                if let name = searchResult["name"] as? String, let image = searchResult["image"] as? String{
                    self.nameText.text = name
                    let tgr = UITapGestureRecognizer(target: self, action: #selector(goToEvent))
                    self.nameText.addGestureRecognizer(tgr)
                    self.nameText.isUserInteractionEnabled = true
                    baseStorageReference.child(image).getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            if let imgDat = data{
                                self.imgView.image = UIImage(data: imgDat)
                            }
                        }
                    }
                }
                break
                
            //ORGANIZATION
            case "organization":
                if let name = searchResult["name"] as? String, let logo = searchResult["logo"] as? String{
                    let tgr = UITapGestureRecognizer(target: self, action: #selector(goToOrganization))
                    self.addGestureRecognizer(tgr)
                    self.nameText.text = name
                    baseStorageReference.child(logo).getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("error", error)
                        } else {
                            if let imgDat = data{
                                self.imgView.image = UIImage(data: imgDat)
                            }
                        }
                    }
                }
                break
                
            //USER
            case "user":
                if let firstName = searchResult["first_name"] as? String, let lastName = searchResult["last_name"] as? String, let id = searchResult["id"] as? String{
                    let tgr = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
                    self.addGestureRecognizer(tgr)
                    self.nameText.text = firstName + " " + lastName
                    baseStorageReference.child("userimages/"+id+"/preview.jpg").getData(maxSize: 1024*1024) { (data, error) in
                        if let error = error{
                            print("loading image error: ", error)
                        }else{
                            if let imgDat = data{
                                self.imgView.image = UIImage(data: imgDat)
                            }
                        }
                    }
                }
                break
                
            default:
                //TODO: ...
                break
            }
        }
    }
    
    
    
    
    // MARK: Transition Functions
    
    @objc func goToProfile(){ //go to view user's full profile
        if(self.delegate != nil){
            self.delegate.callSegueFromCell(searchResult: thisResult)
        }
    }
    
    @objc func goToEvent(){ //view the full event
        if(self.delegate != nil){
            self.delegate.callSegueFromCell(searchResult: thisResult)
        }
    }
    
    @objc func goToOrganization(){ //view organization's profile
        if(self.delegate != nil){
            self.delegate.callSegueFromCell(searchResult: thisResult)
        }
    }

}
