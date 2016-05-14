//
//  PlanTableViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/5/13.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import LocalAuthentication


class PlanTableViewController: UITableViewController {

    var planModels = [PlanModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refreshData()
    }
    
    func refreshData(){
        self.planModels = [PlanModel]()
        SwiftSpinner.show("Connecting to satellite...")
        Alamofire.request(.GET, "http://45.32.10.131/plan/getActivePlans.json", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                  //print("JSON: \(JSON)")
                    let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                    if errorMessage == "LOGIN_REQUIRED" {
                        self.needLogin()
                        return
                    }
                    let models = JSON["planList"] as! NSArray
                    
                    for count in 0 ..< models.count{
                        let model = models[count]
                        
                        let id = model["id"] as! Int
                        let content = model["content"] as! String
                        let progress = model["progress"] as! String
                        let percent = model["percent"] as! String
                        let isRuning = model["runing"] as! Bool
                        let planModel = PlanModel(id: id, content: content, progress: progress, percent: percent, isRuning: isRuning)
                    
                        self.planModels.append(planModel)
                    }
                }
                self.tableView.reloadData()
                SwiftSpinner.hide()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return planModels.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("planCell", forIndexPath: indexPath) as! PlanTableViewCell
        let model = planModels[indexPath.row];
        cell.titileLabel.text = model.content;
        cell.processLabel.text = model.progress;
        cell.percentLabel.text = model.percent;
        if(model.isRuning){
            cell.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        }else{
            cell.layer.backgroundColor = UIColor.whiteColor().CGColor
        }
        if(model.percentDouble == 0){
            cell.percentLabel.textColor = UIColor.redColor()
        }else if (model.percentDouble < 50){
            cell.percentLabel.textColor = UIColor.orangeColor()
        }else if (model.percentDouble < 80){
            cell.percentLabel.textColor = UIColor.blueColor()
        }else{
            cell.percentLabel.textColor = UIColor.greenColor()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SwiftSpinner.show("Connecting to satellite...")
        
        let id = planModels[indexPath.row].id
        
        let parameters = ["id":String(id)]
        
        //45.32.10.131
        Alamofire.request(.GET, "http://45.32.10.131/plan/startPlan.json", parameters: parameters )
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    //                                        print("JSON: \(JSON)")
                    let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                    if errorMessage == "LOGIN_REQUIRED" {
                        self.needLogin()
                        return
                    }
                    SwiftSpinner.hide()
                    self.refreshData()
                }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func login(){
        let pwd = ConfigUtil.loadPwdData()
        Alamofire.request(.GET, "http://45.32.10.131/login.html", parameters: ["loginAccount": pwd])
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
                        self.refreshData()
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


    
}
