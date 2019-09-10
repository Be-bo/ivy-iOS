//
//  LegalStuffCell.swift
//  ivy
//
//  Created by Robert on 2019-09-09.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class LegalStuffCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: MediumGreenLabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUp(par: ParagraphModel){
        titleLabel.text = par.title
        bodyLabel.text = par.body
    }
}
