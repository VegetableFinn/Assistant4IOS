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
    var percent: String = "";
    
    init(id:Int, content:String, progress:String , percent: String){
        self.id = id
        self.content = content
        self.progress = progress
        self.percent = percent
    }
}