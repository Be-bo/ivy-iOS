//
//  ProfileCardBack.swift
//  ivy
//
//  Created by paul dan on 2019-09-01.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class ProfileCardBack: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var age: MediumGreenLabel!
    @IBOutlet weak var degree: MediumLabel!
    @IBOutlet weak var bioLabel: StandardLabel!
    @IBOutlet weak var flipButton: OpacityButton!
    @IBOutlet weak var editButton: OpacityButton!
    
    //all hidden by default since they're used for editing
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var editDegreeButton: OpacityButton!
    @IBOutlet weak var editInterestsButton: OpacityButton!
    @IBOutlet weak var doneEditingButton: OpacityButton!
    
    
    @IBOutlet weak var interestestCollectionView: UICollectionView!
    
    var interests = [String]()
    let cellId = "InterestCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //default they are hidden for profile, shown only when they click the edit button
        self.editInterestsButton.isHidden = true
        self.editDegreeButton.isHidden = true
        self.bioTextField.isHidden = true
        
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.interestestCollectionView.delegate = self
        self.interestestCollectionView.dataSource = self
        self.interestestCollectionView.register(UINib(nibName: "CardInterestCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    func setUpInterests(interests: [String]){
        self.interests = interests
        self.interestestCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let interestCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CardInterestCell
        interestCell.interestLabel.text = interests[indexPath.item]
        return interestCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: self.interestestCollectionView.frame.size.width/2 - 8, height: 40)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    
    
}
