//
//  DailyTableViewCell.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/22.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
