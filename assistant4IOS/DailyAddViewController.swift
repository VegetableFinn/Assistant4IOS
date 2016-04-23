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

//protocol DailyTableViewRefreshProtocol: NSObjectProtocol {
//    func refreshData()
//}

class DailyAddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, SSRadioButtonControllerDelegate {

//    weak var delegate: DailyTableViewRefreshProtocol?
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var contextTextView: UITextView!
    
    var pickerDataSource = ["Coding", "Outing", "Relaxing", "Execising", "Studying"];
    
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
        
        let radioButton = SSRadioButton(frame: CGRect(x: 0, y: 570, width: 200, height: 30 ))
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
    
    func saveButtonClicked(sender: UIBarButtonItem){
        
        SwiftSpinner.show("Connecting to satellite...")
        
        let parameters = ["type":type,"isDuration":isDuration,"content":contextTextView.text]
        
        //104.224.154.89
        Alamofire.request(.GET, "http://104.224.154.89/daily/addDaily.html", parameters: parameters as! [String : String])
            .responseJSON { response in
                SwiftSpinner.hide()
                self.navigationController?.popViewControllerAnimated(true)
//                if(self.delegate != nil){
//                    self.delegate?.refreshData()
//                }
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
