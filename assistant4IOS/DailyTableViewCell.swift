//
//  DailyTableViewCell.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/22.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import Alamofire

protocol DailyTableViewRefreshProtocol: NSObjectProtocol {
    func refreshData()
}

class DailyTableViewCell: UITableViewCell {
    
    weak var delegate: DailyTableViewRefreshProtocol?
    

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    var dailyModel : DailyModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
