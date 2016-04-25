//
//  ConfigUtil.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/25.
//  Copyright © 2016年 hefan. All rights reserved.
//

import Foundation

class ConfigUtil{
    
    class func loadPwdData() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("config.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
//                print("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                do{
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                }catch{
                    print(error)
                }
//                print("copy")
            } else {
//                print("config.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
//            print("config.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
//        print("Loaded config.plist file is --> \(resultDictionary?.description)")
        let myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            let pwd = dict.objectForKey("pwd") as! String
//            print("pwd==="+pwd)
            return pwd
            //...
        } else {
//            print("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        return ""
    }
    
    class func savePwdData(newPwd:String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("config.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
//                print("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                do{
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                }catch{
                    print(error)
                }
//                print("copy")
            } else {
//                print("config.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
//            print("config.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let data : NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
        data.setObject(newPwd, forKey: "pwd")
        //writing to GameData.plist
        data.writeToFile(path, atomically: true)
//        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
//        print("Saved config.plist file is --> \(resultDictionary?.description)")
    }
}