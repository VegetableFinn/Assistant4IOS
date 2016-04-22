//
//  DailyModel.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/22.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit

class DailyModel: NSObject {
    var content: String = ""
    var startDt: String = ""
    var endDt: String = ""
    init(content: String, startDt: String, endDt: String) {
        self.content = content
        self.startDt = startDt
        self.endDt = endDt
    }
}
