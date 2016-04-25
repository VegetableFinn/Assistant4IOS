//
//  MainUITabBarController.swift
//  assistant4IOS
//
//  Created by hefan on 16/4/24.
//  Copyright © 2016年 hefan. All rights reserved.
//

import UIKit

class MainUITabBarController: UITabBarController, UITabBarControllerDelegate {

    var beforeIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        // Do any additional setup after loading the view.
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
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        if(self.selectedIndex == 1 && beforeIndex == 1){
            let navController = viewController as! UINavigationController
            let dailyTableViewController = navController.viewControllers[0] as! DailyTableViewController
            dailyTableViewController.refreshData()
        }
        if(self.selectedIndex == 0 && beforeIndex == 0){
            let navController = viewController as! UINavigationController
            let tableController = navController.viewControllers[0] as! TodoTableViewController
            tableController.refreshToDoData()
        }
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool{
        
        beforeIndex = self.selectedIndex
        
        return true
    }
    
}
