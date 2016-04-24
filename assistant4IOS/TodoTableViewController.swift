//
//  TodoTableViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/24.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import LocalAuthentication


class TodoTableViewController: UITableViewController {
    
    var todoModels = [ToDoModel]()
    
    
    @IBOutlet weak var oneImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        if(todoModels.count == 0){
            refreshPicData()
            refreshToDoData()
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
        return todoModels.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath) as! TodoTableViewCell
        
        let todoModel = todoModels[indexPath.row]
        if(todoModel.catagory == "Life"){
            cell.catagoryLabel.layer.backgroundColor = UIColor.greenColor().CGColor
        }else if(todoModel.catagory == "Work"){
            cell.catagoryLabel.layer.backgroundColor = UIColor.orangeColor().CGColor
        }else if(todoModel.catagory == "Study"){
            cell.catagoryLabel.layer.backgroundColor = UIColor.yellowColor().CGColor
        }
        
        if(todoModel.isDone){
            cell.layer.backgroundColor = UIColor(red: CGFloat(62/255.0), green: CGFloat(70/255.0), blue: CGFloat(80/255.0), alpha: CGFloat(1.0)).CGColor
            cell.statusImg.image = UIImage(named: "todo_done.png")
        }else{
            cell.layer.backgroundColor = UIColor(red: CGFloat(77/255.0), green: CGFloat(89/255.0), blue: CGFloat(102/255.0), alpha: CGFloat(1.0)).CGColor
            cell.statusImg.image = UIImage(named: "todo_undone.png")
        }
        cell.leftLabel.layer.backgroundColor = UIColor(red: CGFloat(62/255.0), green: CGFloat(70/255.0), blue: CGFloat(80/255.0), alpha: CGFloat(1.0)).CGColor
        cell.timeLabel.text = todoModel.dt
        cell.contentLabel.text = todoModel.content
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SwiftSpinner.show("Connecting to satellite...")
        
        
        let thisModel = todoModels[indexPath.row]
        //        todoModels[indexPath.row].isDone = thisModel.isDone ? false : true
        //        tableView.reloadData()
        
        updateTodo(thisModel)
        
    }
    
    private func updateTodo(thisModel:ToDoModel){
        let id = String(thisModel.id)
        let newStatus = thisModel.isDone ? "F" : "T"
        
        let parameters = ["id":id,"newStatus":newStatus]
        
        
        //104.224.154.89
        Alamofire.request(.GET, "http://104.224.154.89/todo/editTodo.html", parameters: parameters ).responseJSON { response in
            
            if let JSON = response.result.value {
                
                let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                if errorMessage == "LOGIN_REQUIRED" {
                    self.needLogin()
                    return
                }
                self.refreshToDoData()
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
    
    func refreshPicData(){
        Alamofire.request(.GET, "http://104.224.154.89/one/getLastOne.json", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                    let title = JSON["title"] as! String
                    self.downloadPic(title)
                }
        }
    }
    
    func downloadPic(title: String){
        
        if checkOnePicExisted(title) {
            SwiftSpinner.hide()
            showImage(title)
            return
        }
        
        var localPath: NSURL?
        Alamofire.download(.GET,
            "http://104.224.154.89/one/showImage.json?title="+title,
            destination: { (temporaryURL, response) in
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = title + ".jpg"
                print(pathComponent)
                
                localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
                return localPath!
        })
            .response { (request, response, _, error) in
                self.showImage(title)
        }
    }
    
    func checkOnePicExisted(title: String) -> Bool{
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let getImagePath = paths.stringByAppendingPathComponent(title + ".jpg")
        let checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(getImagePath)){
            //            print("FILE AVAILABLE");
            return true
        }else{
            //            print("FILE NOT AVAILABLE");
            return false
        }
    }
    
    func showImage(title:String){
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let getImagePath = paths.stringByAppendingPathComponent(title + ".jpg")
        self.oneImage.image = UIImage(named: getImagePath)
    }
    
    func refreshToDoData(){
        self.todoModels = [ToDoModel]()
        SwiftSpinner.show("Connecting to satellite...")
        //104.224.154.89
        Alamofire.request(.GET, "http://104.224.154.89/todo/getToDoList.json", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                    //                                        print("JSON: \(JSON)")
                    let errorMessage = (JSON["errorMessageEnum"] is NSNull) || (JSON["errorMessageEnum"] == nil) ? "" : JSON["errorMessageEnum"] as! String
                    if errorMessage == "LOGIN_REQUIRED" {
                        self.needLogin()
                        return
                    }
                    let models = JSON["toDoModelList"] as! NSArray
                    
                    
                    for count in 0 ..< models.count{
                        let model = models[count]
                        
                        let id = model["id"] as! Int
                        let content = model["content"] as! String
                        let dt = model["dt"] as! String
                        let isDone = (model["isDone"] as! String) == "T" ? true : false
                        let catagory = model["catagory"] as! String
                        let todoModel = ToDoModel(id: id, content: content, dt: dt, isDone: isDone, catagory: catagory)
                        
                        self.todoModels.append(todoModel)
                    }
                }
                self.tableView.reloadData()
                SwiftSpinner.hide()
        }
        
    }
    
    
    func login(){
        Alamofire.request(.GET, "http://104.224.154.89/login.html?loginAccount=abc", parameters: ["foo": "bar"])
            .responseJSON { response in
                self.refreshToDoData()
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