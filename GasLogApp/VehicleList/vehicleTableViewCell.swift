//
//  vehicleTableViewCell.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/7/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit

class vehicleTableViewCell: UITableViewCell {
	@IBOutlet weak var vehicleNameLabel: UILabel!
	@IBOutlet weak var editButton: UIButton!
	@IBOutlet weak var deleteButton: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
