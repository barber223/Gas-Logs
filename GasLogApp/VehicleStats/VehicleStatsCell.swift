//
//  VehicleStatsCell.swift
//  GasLogApp
//
//  Created by Eric Barber on 11/9/17.
//  Copyright © 2017 Eric Barber. All rights reserved.
//

import UIKit

class VehicleStatsCell: UITableViewCell {
	
	@IBOutlet weak var dateTimeLabel: UILabel!
	@IBOutlet weak var milesWentLabel: UILabel!
	@IBOutlet weak var odoLabel: UILabel!
	@IBOutlet weak var mpgLabel: UILabel!
	@IBOutlet weak var costOfFillLabel: UILabel!
	@IBOutlet weak var gallonsEnteredLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
}
