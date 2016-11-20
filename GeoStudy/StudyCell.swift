//
//  StudyCell.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/20/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit

class StudyCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.font = UIFont(name: "BebasNeue", size: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
