//
//  MasterTVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 16/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit

class MasterTVC: UITableViewController, UISplitViewControllerDelegate{

    let menuItems = ["Payment","Sales","Shifts","Products","Settings"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .automatic
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView.init(image: UIImage(named: "AppIcon")))
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = "\t    \(menuItems[indexPath.row])"
        let icon = UIImageView.init(image: UIImage(named: menuItems[indexPath.row]))
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect.init(origin: CGPoint.init(x: 18, y: 12), size: CGSize.init(width: 25, height: 25))
        cell.addSubview(icon)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let rightNavController = splitViewController?.viewControllers.last as? UINavigationController {
            if rightNavController.viewControllers.last?.title != menuItems[indexPath.row] {
                if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: menuItems[indexPath.row] ) {
                    rightNavController.setViewControllers([rightNavController.viewControllers.first!,detailVC], animated: true)
                }
            }

        }
  
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
//        return true
//    }

}
