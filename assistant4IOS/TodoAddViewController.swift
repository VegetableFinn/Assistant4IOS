//
//  TodoAddViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/25.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import LocalAuthentication

class TodoAddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    var activeTextView: UITextView?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var catagoryPicker: UIPickerView!
    
    var pickerDataSource = ["Work", "Life", "Study"];
    var type = String()
    var dt = String()
    
    var tableViewController : TodoTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(TodoAddViewController.saveButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.title = "新增待办事项"
        
        self.catagoryPicker.dataSource = self
        self.catagoryPicker.delegate = self
        
        type = pickerDataSource[0]
        dtChange(self)
        
        self.textView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
//        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
//        deregisterFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func dtChange(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dt = dateFormatter.stringFromDate(datePicker.date)
    }
    
    func saveButtonClicked(sender: UIBarButtonItem){
        
        SwiftSpinner.show("Connecting to satellite...")
        let parameters = ["content":textView.text,"catagory":type,"dt":dt]
        
        //106.185.32.240
        Alamofire.request(.GET, "http://106.185.32.240/todo/addTodo.html", parameters: parameters )
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
                    self.tableViewController?.refreshToDoData()
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

    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TodoAddViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TodoAddViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height * 2, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let activeFieldPresent = activeTextView
        {
            if (!CGRectContainsPoint(aRect, activeFieldPresent.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
        
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        activeTextView = textView
    }
    
    func textViewDidEndEditing(textView: UITextView){
        activeTextView = nil
    }
    
  }
