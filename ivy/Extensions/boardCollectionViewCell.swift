//
//  boardCollectionViewCell.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-27.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import UIKit


extension UICollectionViewCell {
    
    //adding border to each cell here
    func styleCell(cell:UICollectionViewCell){
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0

        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
    }
    
}
