//
//  OneViewController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/23.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire

class OneViewController: UIViewController {

    @IBOutlet weak var oneImage: UIImageView!
    @IBOutlet weak var oneText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.oneText.layer.cornerRadius = 5;
        self.oneText.layer.backgroundColor = UIColor.greenColor().CGColor
        self.oneText.textColor = UIColor.whiteColor()
        self.oneText.font = self.oneText.font?.fontWithSize(15)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData(){
        SwiftSpinner.show("Connecting to satellite...")
    
        Alamofire.request(.GET, "http://104.224.154.89/one/getLastOne.json", parameters: nil)
            .responseJSON { response in
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    
                    let content = JSON["content"] as! String
//                    let imgUrl = JSON["imgUrl"] as! String
                    let title = JSON["title"] as! String
                    self.downloadPic(title)
                    self.oneText.text = content
                }
               
        }
        
    }
    
    func showImage(title:String){
        
//        print(NSBundle.mainBundle().pathForResource(title, ofType: "jpg"))
//        if let filePath = NSBundle.mainBundle().pathForResource(title, ofType: "jpg"), image = UIImage(contentsOfFile: filePath){
//            print(filePath)
//            //                imageView.contentMode = .ScaleAspectFit
//            //                imageView.image = image
//            self.oneImage.contentMode = .ScaleAspectFit
//            self.oneImage.image = image
//        }
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let getImagePath = paths.stringByAppendingPathComponent(title + ".jpg")
        self.oneImage.image = UIImage(named: getImagePath)
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
//                print(response)
//                print("Downloaded file to \(localPath!)")
                self.showImage(title)
                SwiftSpinner.hide()
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
