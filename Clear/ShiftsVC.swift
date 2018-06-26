//
//  ShiftsVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 19/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

private let reuseIdentifier = "Cell"
class ShiftsVC: UIViewController, UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate{

    @IBOutlet weak var openCloseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var payOutButton: UIButton!
    @IBOutlet weak var payInButton: UIButton!
    var _cashShifts:[WDCashShift]?
    
    var cashShifts: [WDCashShift]? {
        get {
            return _cashShifts
        }
        set {
            _cashShifts = newValue
            if (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister != nil  {
                openCloseButton.isEnabled = true
                if   newValue == nil || newValue?.count == 0 {
                    payOutButton.isEnabled = false
                    payInButton.isEnabled = false
                }
                else{
                    payOutButton.isEnabled = true
                    payInButton.isEnabled = true
                }
            }
            else{
                openCloseButton.isEnabled = false
                payOutButton.isEnabled = false
                payInButton.isEnabled = false
            }
        }
    }
    
    var isOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getShifts()
    }
// MARK: - Custom Methods
    func getShifts(){
        // It is possible to get the Shift details either from Shift Query or Shift Detail
        // A. Search for all Shifts for the specified Cash Register
        // End of Shifts query process
        let completion = {(cashShifts:[WDCashShift]?, error:Error?) in
            Messages().hideActivity(onView: self.view)
            // cashShift of WDCashShift type contains all data necessary to create the Z-Report:
            // Opening and Closing amounts, times, Cashier names, Categories of Sales (Cash, Card, Coupon), Netto, Gross per Sale type (Purchase, Return) and Tax Level
            self.cashShifts = cashShifts
            self.toggleOpenClose()
            self.tableView.reloadData()
        }
        
        // Define the query details such as Paging, Order By and Sort Order
        let query:WDShiftQuery = WDShiftQuery.init(page: 0,
                                                   pageSize: 15,
                                                   orderBy: WDShiftQueryOrderBy.openTime,
                                                   order: WDQuerySort.descending)
        if let cashRegister = (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister {
            Messages().showActivity(onView: self.view)
            WDePOS.sharedInstance().cashManager.shifts(cashRegister.internalId!, // Selected Cash register ID
                query: query, // Query details
                completion: completion) // End of query process
        }
        else{
            Messages().showError(title: "Shift", message: "Please select the cash register in the Settings")
        }
    }
    
    func toggleOpenClose(){
        openCloseButton.isEnabled = true
        if let shifts = self.cashShifts{
            let cashShift = shifts[0]
            if cashShift.closeTime == nil {
                self.openCloseButton.setTitle("Close", for: UIControlState.normal)
                isOpen = true
            }
            else{
                self.openCloseButton.setTitle("Open", for: UIControlState.normal)
                isOpen = false
            }
        }
        else{
            isOpen = false
        }
    }
    
    func openClose(){
        //if last shift is opened then
        let openCloseString = isOpen ? "Close" : "Open"
        let alert = UIAlertController(title: "Shift", message: "Specify the amount to " + openCloseString + " shift" , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: openCloseString, style: UIAlertActionStyle.default, handler: {action in
            //End of Open Shift process
            let completion = {(success:Bool, error:Error?) in
                //success - flag if the Shift was opened successfuly
                self.getShifts()
                if let  error = error{
                    Messages().showError(title: "Shift", message: error.localizedDescription)
                }
                
            }
            if let cashRegister = (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister {
                if !self.isOpen {
                    // Open the Shift for the selected Cash Register
                    WDePOS.sharedInstance().cashManager.openShift(cashRegister.internalId!,//Selected Cash Register ID
                        note: "Open My Shift",   // Optional Note when opening the shift,
                        amount:NSDecimalNumber.init(string: alert.textFields?[0].text),   // Amount of Cash which is present in the Cash Register at the time of opening
                        completion: completion) // End of Open Shift process
                    
                }
                else{
                    // Close the Shift for the selected Cash Register
                    WDePOS.sharedInstance().cashManager.closeShift(cashRegister.internalId!,//Selected Cash Register ID
                        note: "Close My Shift",   // Optional Note when closing the shift,
                        amount: NSDecimalNumber.init(string: alert.textFields?[0].text),   // Amount of Cash which is present in the Cash Register at the time of closing
                        completion: completion) // End of Close Shift process
                }
                
            }
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter amount:"
            textField.isSecureTextEntry = false // for password input
            textField.delegate = self
        })
        self.present(alert, animated: true, completion: nil)
    }
    func payInOut(isIn:Bool){
        let inOut = isIn ? "Pay In" : " Pay Out"
        let alert = UIAlertController(title: "Shift Activity", message: "Specify the amount to " + inOut , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: inOut, style: UIAlertActionStyle.default, handler: { action in
            // End of Pay In/Out process
            let completion = {(success:Bool, error:Error?) in
                //success - flag if the Pay In/Out was processed successfuly
                
                if let  error = error{
                    Messages().showError(title: "Shift Activity", message: error.localizedDescription)
                }
                else{
                    Messages().showAlert(title: "Shift", message: (isIn ? "Paid In success" : "Paid Out success"))
                }
                
            }
            
            if let cashRegister = (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister {
                // Record the Cash register paying In/out cash
                
                WDePOS.sharedInstance().cashManager.cashOperation(cashRegister.internalId! , // The selected Cash Register internal ID,
                    note: "Cash Pay In/Out note" , // Optional Note for Paying In/Out,
                    amount: (isIn ? NSDecimalNumber.one : NSDecimalNumber.one.multiplying(by: NSDecimalNumber.init(value: -1)) ).multiplying(by:NSDecimalNumber.init(string: alert.textFields?[0].text)), // The amount of Cash Paying In/out
                    currency: "EUR",// The Cash Currency *MUST* match the currency of the selected Cash Register
                    completion: completion) // End of Pay In/out process
            }
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter amount:"
            textField.isSecureTextEntry = false // for password input
            textField.delegate = self
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Text Field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if NSDecimalNumber(string: string).isEqual(NSDecimalNumber.notANumber) {
            return false
        }
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selected
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let shifts = self.cashShifts{
            return shifts.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier){
            if let cashShifts = self.cashShifts{
                let cashShift = cashShifts[indexPath.row]
                    
                let statusString = "    \(cashShift.shiftStatus ?? "CLOSED")"
                let color = (cashShift.closeTime != nil) ? UIColor.darkGray : UIColor.init(red: 0, green: 153/255, blue: 51/255, alpha: 1)
                let openedTime = "\(WDUtils.formatDate(cashShift.openTime, format: "dd/MM/yyyy HH:mm:ss")!)"
                let closedTime = (cashShift.closeTime != nil) ? "\n\(WDUtils.formatDate(cashShift.closeTime, format: "dd/MM/yyyy HH:mm:ss")!)" : ""
                let myString = NSMutableAttributedString(string: openedTime)
                
                let myRange = NSRange(location: openedTime.count, length: statusString.count)
                
                myString.append(NSAttributedString(string:statusString))
                myString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: myRange)
                myString.append(NSAttributedString(string:closedTime))
                let myRange1 = NSRange(location: openedTime.count + statusString.count, length: closedTime.count)
                myString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: myRange1)
                myString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Helvetica", size: 12.0)!, range: myRange1)
                
                cell.textLabel?.numberOfLines = 2
                cell.textLabel?.attributedText = myString
                let amount = NSDecimalNumber.init(decimal:((cashShift.closingAmount ?? cashShift.openingAmount)?.decimalValue)!)
                cell.detailTextLabel?.text = WDUtils.formatNumber(amount, withCurrencyCode: "EUR", showSymbol: true)
                    
                    

                
            }
            return cell
        }
        return UITableViewCell()
    }
    // MARK: - Custom Actions
    @IBAction func onTapOpenClose(_ sender: Any) {
        openClose()
    }
    @IBAction func onTapPayIn(_ sender: Any) {
        payInOut(isIn: true)
    }
    @IBAction func onTapPayOut(_ sender: Any) {
        payInOut(isIn: false)
    }
    
    
}
