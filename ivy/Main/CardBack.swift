//
//  CardBack.swift
//  ivy
//
//  Created by Robert on 2019-07-07.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class CardBack: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var name: MediumGreenLabel!
    @IBOutlet weak var age: MediumGreenLabel!
    @IBOutlet weak var degree: MediumLabel!
    @IBOutlet weak var bio: StandardLabel!
    @IBOutlet weak var interestestCollectionView: UICollectionView!
    @IBOutlet weak var sayHiMessageTextField: UITextField!
    @IBOutlet weak var sayHiButton: subclassedUIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var sayHiHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sayHiBtnConstraint: NSLayoutConstraint!
    
    var interests = [String]()
    let cellId = "InterestCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
