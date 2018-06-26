//
//  DetailVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 16/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

class DetailVC: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        if (UIApplication.shared.delegate as! AppDelegate).currentUser == nil {
            
            
            //End of SDK setup process
            let setupCompletion:CurrentUserCompletion = {( currentUser:WDMerchantUser?, cashier:WDMerchantCashier? , error:Error?) in
                Messages().hideActivity(onView: self.view)
                //Current User is returned upon successful login
                //if the Cash Management is enabled and Cashier record exist for the current user then the Cashier is returned also
                NSLog("Current user : %@", currentUser ?? "Login failed")
                (UIApplication.shared.delegate as! AppDelegate).currentUser = currentUser
                if let err = error {
                    NSLog("Error :%@", err.localizedDescription)
                }
                
                if let currentUser = currentUser {
                    self.userLabel.text = "User: " + currentUser.name!
                }
                else{
                    self.userLabel.text = "Login failed"
                }
                
                
            }
            Messages().showActivity(onView: self.view)
            // Set the SDK target environment - in this case Public Test
            // and the username and password to authenticate to it
            WDePOS.sharedInstance().setup(with: WDEnvironment.publicTest, username: "EposDemoUser", password: "Demo12345678!!", completion: setupCompletion)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let master = splitViewController?.viewControllers.first!.childViewControllers.first as! MasterTVC
        master.tableView.reloadData()
        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
