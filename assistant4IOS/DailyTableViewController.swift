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
        
        
        let indexStartDt = daily.startDt.endIndex.advancedBy(-8)
        var startDtText = daily.startDt.substringFromIndex(indexStartDt)
        let indexStartDtEnd = startDtText.endIndex.advancedBy(-3)
        startDtText = startDtText.substringToIndex(indexStartDtEnd)
        cell.startLabel?.text = startDtText
        
        if(daily.endDt != ""){
            let indexEndDt = daily.endDt.endIndex.advancedBy(-8)
            var endDtText = daily.endDt.substringFromIndex(indexEndDt)
            let indexEndDtEnd = endDtText.endIndex.advancedBy(-3)
            endDtText = endDtText.substringToIndex(indexEndDtEnd)
            cell.endLabel?.text = endDtText

        }
        
        cell.dailyModel = daily
        cell.durationLabel?.text = daily.duration
        
        
        let catagoryLabel = UILabel(frame: CGRect(x: 25, y: 15, width: 50, height: 50))
        catagoryLabel.layer.backgroundColor = UIColor.blackColor().CGColor
        catagoryLabel.textColor = UIColor.whiteColor()
        catagoryLabel.layer.cornerRadius = 5
        let cataIndex = daily.catagory.startIndex.advancedBy(1)
        catagoryLabel.text = daily.catagory.substringToIndex(cataIndex)
        if(daily.catagory == "Coding"){
            catagoryLabel.layer.backgroundColor = UIColor(red: CGFloat(0/255.0), green: CGFloat(110/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(1.0)).CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }else if(daily.catagory == "Relaxing"){
            catagoryLabel.layer.backgroundColor = UIColor(red: CGFloat(174/255.0), green: CGFloat(238/255.0), blue: CGFloat(238/255.0), alpha: CGFloat(1.0)).CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }else if(daily.catagory == "Sleeping"){
            catagoryLabel.layer.backgroundColor = UIColor.purpleColor().CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }else if(daily.catagory == "Exercising"){
            catagoryLabel.layer.backgroundColor = UIColor.grayColor().CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }else if(daily.catagory == "Studying"){
            catagoryLabel.layer.backgroundColor = UIColor.orangeColor().CGColor
            catagoryLabel.textColor = UIColor.whiteColor()
        }
        
        catagoryLabel.font = catagoryLabel.font.fontWithSize(30)
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
