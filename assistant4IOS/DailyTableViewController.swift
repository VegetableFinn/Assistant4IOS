//
//  DailyTableViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/22.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import LocalAuthentication

class DailyTableViewController: UITableViewController {
    
    @IBOutlet var dailyTableView: UITableView!
    
    var dailyList = [DailyModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DailyTableViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "我就是这么跳")
        self.refreshControl = refreshControl
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func login(){
        Alamofire.request(.GET, "http://104.224.154.89/login.html?loginAccount=abc", parameters: ["foo": "bar"])
            .responseJSON { response in
                self.refreshData()
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
    
    
    func refreshData(){
        dailyList = [DailyModel]()
        SwiftSpinner.show("Connecting to satellite...")
        //104.224.154.89
        Alamofire.request(.GET, "http://104.224.154.89/daily/getRecent2Days.json", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
//                                        print("JSON: \(JSON)")
                    let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                    if errorMessage == "LOGIN_REQUIRED" {
                        self.needLogin()
                        return
                    }
                    let models = JSON["dailyModels"] as! NSArray
                    
                    
                    for count in 0 ..< models.count{
                        let model = models[count]
                        
                        let id = model["id"] as! Int
                        let content = model["content"] as! String
                        let startDt = model["startDt"] as! String
                        let endDt =  (model["endDt"] is NSNull) ? "" : model["endDt"] as! String
                        let catagory = model["catagory"] as! String
                        let duration = (model["durationDt"] is NSNull) ? "" : model["durationDt"] as! String
                        let dailyModel = DailyModel(id: id, content: content, startDt: startDt, endDt: endDt, catagory: catagory, duration:duration)
                        if(model["duration"] as! Int == 1 && endDt == ""){
                            dailyModel.isNotFinished = true;
                        }
                        self.dailyList.append(dailyModel)
                    }
                }
                self.dailyTableView.reloadData()
                self.refreshControl?.endRefreshing()
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
        return dailyList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dailyCell", forIndexPath: indexPath) as! DailyTableViewCell
        let daily = dailyList[indexPath.row]
        cell.contentLabel?.text = daily.content
        cell.startLabel?.text = daily.startDt
        cell.endLabel?.text = daily.endDt
        cell.dailyModel = daily
        cell.durationLabel?.text = daily.duration
        let catagoryLabel = UILabel(frame: CGRect(x: 280, y: 41, width: 70, height: 20))
        catagoryLabel.layer.backgroundColor = UIColor.blackColor().CGColor
        catagoryLabel.textColor = UIColor.whiteColor()
        catagoryLabel.layer.cornerRadius = 5
        catagoryLabel.text = daily.catagory
        if(daily.catagory == "Coding"){
            catagoryLabel.layer.backgroundColor = UIColor.greenColor().CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }else  if(daily.catagory == "Relaxing"){
            catagoryLabel.layer.backgroundColor = UIColor.redColor().CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }
        
        catagoryLabel.font = catagoryLabel.font.fontWithSize(12)
        catagoryLabel.textAlignment = NSTextAlignment.Center
        
        cell.addSubview(catagoryLabel)
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
       
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        
        var returnActions = [UITableViewRowAction]()
        
        let thisModel = dailyList[indexPath.row]
        if(thisModel.isNotFinished){
            let complete = UITableViewRowAction(style: .Normal, title: "完成") { action, index in
                self.finishDaily(thisModel)
            }
            complete.backgroundColor = UIColor.blueColor()

            returnActions.append(complete)
        }
        
        let delete = UITableViewRowAction(style: .Normal, title: "删除") { action, index in
            self.deleteDaily(thisModel)
        }
        delete.backgroundColor = UIColor.redColor()
        returnActions.append(delete)
//
//        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
//            print("share button tapped")
//        }
//        share.backgroundColor = UIColor.blueColor()
        
        return returnActions
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showEditPage", sender: self)
    }
    
    
    
    func finishDaily(model: DailyModel) {
        SwiftSpinner.show("Connecting to satellite...")
        Alamofire.request(.GET, "http://104.224.154.89/daily/endDaily.html?id="+String(model.id), parameters: ["foo": "bar"])
            .responseJSON { response in
                self.refreshData()
                SwiftSpinner.hide()
        }
    }
    
    func deleteDaily(model: DailyModel){
        SwiftSpinner.show("Connecting to satellite...")
        Alamofire.request(.GET, "http://104.224.154.89/daily/deleteDaily.html?id="+String(model.id), parameters: ["foo": "bar"])
            .responseJSON { response in
                self.refreshData()
                SwiftSpinner.hide()
        }
    }


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

      // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //showEditPage
        if (segue.identifier == "showEditPage") {
            // pass data to next view
            let viewController:DailyEditViewController = segue.destinationViewController as! DailyEditViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
//            viewController.pinCode = self.exams[indexPath.row]
            viewController.type = dailyList[indexPath.row].catagory
            viewController.content = dailyList[indexPath.row].content
            viewController.id = dailyList[indexPath.row].id
        }
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
