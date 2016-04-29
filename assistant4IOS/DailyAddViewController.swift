//
//  DailyAddViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/22.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import LocalAuthentication


//protocol DailyTableViewRefreshProtocol: NSObjectProtocol {
//    func refreshData()
//}

class DailyAddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, SSRadioButtonControllerDelegate {

//    weak var delegate: DailyTableViewRefreshProtocol?
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var contextTextView: UITextView!
    
    var tableViewController : DailyTableViewController?
    
    var pickerDataSource = ["Coding", "Outing", "Relaxing", "Exercising", "Studying", "Sleeping"];
    
    var radioButtonController = SSRadioButtonsController()
    
    var isDuration = "F"
    var type = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(DailyAddViewController.saveButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.title = "新增日程"
        
        self.typePicker.dataSource = self
        self.typePicker.delegate = self
        
        type = pickerDataSource[0]
        
        let radioButton = SSRadioButton(frame: CGRect(x: 0, y: 344, width: 200, height: 30 ))
        radioButton.circleRadius = 8
        radioButton.circleColor = UIColor.blackColor()
        radioButton.setTitle("是否是持续性事件？", forState: .Normal)
        radioButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        radioButtonController.delegate = self
        radioButtonController.shouldLetDeSelect = true
        
        radioButtonController.addButton(radioButton)
        
        self.view.addSubview(radioButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
//        Alamofire.request(.GET, "http://106.185.32.240/login.html?loginAccount="+pwd, parameters: ["foo": "bar"])
//            .responseJSON { response in
//                SwiftSpinner.hide()
//        }
//    }
    func login(){
        let pwd = ConfigUtil.loadPwdData()
        Alamofire.request(.GET, "http://106.185.32.240/login.html", parameters: ["loginAccount": pwd])
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
    
    func saveButtonClicked(sender: UIBarButtonItem){
        
        SwiftSpinner.show("Connecting to satellite...")
        
        let parameters = ["type":type,"isDuration":isDuration,"content":contextTextView.text]
        
        //106.185.32.240
        Alamofire.request(.GET, "http://106.185.32.240/daily/addDaily.html", parameters: parameters as! [String : String])
            .responseJSON { response in
                
//                SwiftSpinner.hide()
//                self.navigationController?.popViewControllerAnimated(true)
//                if(self.delegate != nil){
//                    self.delegate?.refreshData()
//                }
                
                
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
    
    func didSelectButton(aButton: UIButton?){
        if aButton == nil {
            isDuration = "F"
        }else {
            isDuration = "T"
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
