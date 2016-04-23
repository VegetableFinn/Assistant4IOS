//
//  DailyModel.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/22.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit

class DailyModel: NSObject {
    var id: Int = 0
    var content: String = ""
    var startDt: String = ""
    var endDt: String = ""
    var isNotFinished: Bool = false;
    var catagory: String = ""
    var duration: String  = ""
    init(id: Int, content: String, startDt: String, endDt: String, catagory: String, duration: String) {
        self.id = id
        self.content = content
        self.startDt = startDt
        self.endDt = endDt
        self.catagory = catagory
        self.duration = duration
    }
}
