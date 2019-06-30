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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
