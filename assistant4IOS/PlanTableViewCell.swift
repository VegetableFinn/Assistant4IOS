//
//  PlanTableViewCell.swift
//  assistant4IOS
//
//  Created by hefan on 16/5/13.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit

class PlanTableViewCell: UITableViewCell {

    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
