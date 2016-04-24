//
//  ToDoModel.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/24.
//  Copyright © 2016年 hefan. All rights reserved.
//

import Foundation

class ToDoModel{
    var id: Int = 0
    var content: String = ""
    var dt: String = ""
    var isDone: Bool = false;
    var catagory: String = ""
    
    init(id:Int, content:String, dt:String , isDone: Bool, catagory: String){
        self.id = id
        self.content = content
        self.dt = dt
        self.isDone = isDone
        self.catagory = catagory
    }
}