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
        
//        addPassAction()
        
        //添加刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DailyTableViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "我就是这么跳")
        self.refreshControl = refreshControl
        
    
        refreshData()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func refreshData(){
        dailyList = [DailyModel]()
        SwiftSpinner.show("Connecting to satellite...")
        //104.224.154.89
        Alamofire.request(.GET, "http://104.224.154.89/daily/getRecent2Days.json", parameters: nil)
            .responseJSON { response in
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
//                                        print("JSON: \(JSON)")
                    for count in 0 ..< JSON.count{
                        
                        let id = JSON[count]["id"] as! Int
                        let content = JSON[count]["content"] as! String
                        let startDt = JSON[count]["startDt"] as! String
                        let endDt =  (JSON[count]["endDt"] is NSNull) ? "" : JSON[count]["endDt"] as! String
                        let catagory = JSON[count]["catagory"] as! String
                        let duration = (JSON[count]["durationDt"] is NSNull) ? "" : JSON[count]["durationDt"] as! String
                        let dailyModel = DailyModel(id: id, content: content, startDt: startDt, endDt: endDt, catagory: catagory, duration:duration)
                        if(JSON[count]["duration"] as! Int == 1 && endDt == ""){
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
//        cell.delegate = self
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let thisModel = dailyList[indexPath.row]
        if(thisModel.isNotFinished){
            return true
        }

        return false
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
        
//        let favorite = UITableViewRowAction(style: .Normal, title: "Favorite") { action, index in
//            print("favorite button tapped")
//        }
//        favorite.backgroundColor = UIColor.orangeColor()
//        
//        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
//            print("share button tapped")
//        }
//        share.backgroundColor = UIColor.blueColor()
        
        return returnActions
    }
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("daily", sender: AnyObject?)
//    }
//    
    
    
    func finishDaily(model: DailyModel) {
        SwiftSpinner.show("Connecting to satellite...")
        Alamofire.request(.GET, "http://104.224.154.89/daily/endDaily.html?id="+String(model.id), parameters: ["foo": "bar"])
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

    func addPassAction(){
        print("add pass action")
        let laContext = LAContext()
        var authError : NSError?
        let errorReason = "keep things secret"
        if laContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError){
            laContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: errorReason, reply: {
                (success, error) in
                if success {
                    print("succeed")
                }
                else{
                    print("failed")
                }
            })
        }
       
    }
}
