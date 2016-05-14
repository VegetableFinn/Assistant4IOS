//
//  PlanModel.swift
//  assistant4IOS
//
//  Created by hefan on 16/5/13.
//  Copyright © 2016年 hefan. All rights reserved.
//

import Foundation

class PlanModel{
    var id: Int = 0
    var content: String = ""
    var progress: String = ""
    var percent: String = ""
    var isRuning: Bool = false
    var percentDouble: Double = 0
    
    init(id:Int, content:String, progress:String , percent: String, isRuning: Bool){
        self.id = id
        self.content = content
        self.progress = progress
        self.percent = percent + " %"
        self.isRuning = isRuning
        self.percentDouble = Double.init(percent)!
    }
}