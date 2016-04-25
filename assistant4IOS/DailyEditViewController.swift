//
//  DailyEditViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/23.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import LocalAuthentication

class DailyEditViewController: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var contextTextView: UITextView!
    
    var tableViewController : DailyTableViewController?

    
    var pickerDataSource = ["Coding", "Outing", "Relaxing", "Exercising", "Studying", "Sleeping"];
    
    var isDuration = "F"
    var type = String()
    var content = String()
    var id = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(DailyEditViewController.saveButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.title = "完善日程"
        
        self.typePicker.dataSource = self
        self.typePicker.delegate = self
        
        self.contextTextView.text = content
        
        let rowIndex = find(type,pickerDataSource: pickerDataSource)
        self.typePicker.selectRow(rowIndex, inComponent: 0, animated: true)
        
    }
    
    func saveButtonClicked(sender: UIBarButtonItem){
        
        SwiftSpinner.show("Connecting to satellite...")
        
        let parameters = ["type":type,"content":contextTextView.text,"id":String(id)]
        
        //104.224.154.89
        Alamofire.request(.GET, "http://104.224.154.89/daily/editDaily.html", parameters: parameters as! [String : String])
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    //                                        print("JSON: \(JSON)")
                    let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                    if errorMessage == "LOGIN_REQUIRED" {
                        self.needLogin()
                        return
                    }
                    SwiftSpinner.hide()
                    self.navigationController?.popViewControllerAnimated(true)
                    self.tableViewController?.refreshData()
                }
        }
    }
    
    
    func find(type:String, pickerDataSource:NSArray) -> Int{
        var i = 0;
        for str in pickerDataSource {
            if(str as! String == type){
                return i
            }
            i = i+1
        }
        return 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        let navVC = segue.destinationViewController as UINavigationController
//        
//        let tableVC = navVC.viewControllers.first as YourTableViewControllerClass
//        
//        tableVC.yourTableViewArray = localArrayValue
//     }
 
    
    
    func touchIdCheck() -> Bool{
        let laContext = LAContext()
        var authError : NSError?
        let errorReason = "Mr.Finn 身份鉴别"
        var result: Bool = false
        if laContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError){
            laContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: errorReason, reply: {
                (success, error) in
                if success {
                    self.asyncLogin()
                    result = true
                }
                else{
                    //                    print("failed")
                    result = false
                }
            })
        }else{
            result = true
        }
        return result
        
    }
    
//    func login(){
//        let pwd = ConfigUtil.loadPwdData()
//        Alamofire.request(.GET, "http://104.224.154.89/login.html?loginAccount="+pwd, parameters: ["foo": "bar"])
//            .responseJSON { response in
//                SwiftSpinner.hide()
//        }
//    }
    func login(){
        let pwd = ConfigUtil.loadPwdData()
        Alamofire.request(.GET, "http://104.224.154.89/login.html", parameters: ["loginAccount": pwd])
            .responseJSON { response in
                if let JSON = response.result.value {
                    let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                    if errorMessage == "LOGIN_FAIL" {
                        SwiftSpinner.hide()
                        let alertController = UIAlertController(title: "警告", message: "身份校验失败，所以你是谁？", preferredStyle: UIAlertControllerStyle.Alert)
                        let cancelAction = UIAlertAction(title: "明白了", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    } else{
                        //                        self.refreshToDoData()
                    }
                }
        }
    }
    
    func needLogin(){
        if(touchIdCheck()){
            login();
            
        }else{
            
        }
    }
    
    func asyncLogin(){
        login();
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = pickerDataSource[row]
    }
    
    
}
