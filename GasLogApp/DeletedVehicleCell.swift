//
//  DeletedVehicleCell.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/16/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit

class DeletedVehicleCell: UITableViewCell {


	@IBOutlet weak var vehicleNameLabel: UILabel!
	@IBOutlet weak var totalMilesWentLabel: UILabel!
	@IBOutlet weak var AverageMPG: UILabel!
	@IBOutlet weak var totalCostLabel: UILabel!
	@IBOutlet weak var lastODOLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
