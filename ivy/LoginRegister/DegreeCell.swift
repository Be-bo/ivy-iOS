//
//  DegreeCell.swift
//  ivy
//
//  Created by Robert on 2019-06-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class DegreeCell: UITableViewCell{
    
    @IBOutlet weak var degreeImageView: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = Colors.ivy_grey
//        self.tintColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1) //#696969
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
