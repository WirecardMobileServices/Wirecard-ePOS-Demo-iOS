//
//  SettingsVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 19/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

class SettingsVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var pickerTerminals: UIPickerView!
    @IBOutlet weak var pickerPrinters: UIPickerView!
    @IBOutlet weak var pickerCashRegisters: UIPickerView!
    
    var terminals:[WDTerminal]?
    var printers:[WDTerminal]?
    var cashRegisters:[WDCashRegister]?
    
    var selectedPrinter: WDTerminal? {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).selectedPrinter
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).selectedPrinter = newValue
        }
    }
    
    var selectedTerminal: WDTerminal? {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).selectedTerminal
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).selectedTerminal = newValue
        }
    }
    
    var selectedCashRegister: WDCashRegister? {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister
        }
        set {
            (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister = newValue
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPrinters()
        getTerminals()
        getCashRegisters()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func getTerminals(){
        // Completion from the Terminal Discovery API
        let completionTerminals = {(arr: [WDTerminal]?, error:Error?) in
            Messages().hideActivity(onView: self.pickerTerminals)
            
            self.terminals = (arr ?? []).count > 0 ? arr : nil
            self.pickerTerminals.reloadAllComponents()
            
            if let terminals = self.terminals{
                if let terminal = self.selectedTerminal {
                    if let idx = terminals.index(where: {$0.displayName == terminal.displayName}){
                        self.pickerTerminals.selectRow((idx-1), inComponent: 0, animated: true)
                    }
                   
                }
                else{
                    if terminals.count == 1 {
                        self.selectedTerminal = terminals[0]
                        self.pickerTerminals.selectRow(0, inComponent: 0, animated: true)
                    }
                }
            }
            if let  error = error{
                Messages().showError(title: "Terminals", message: error.localizedDescription)
            }
            
        }
        Messages().showActivity(onView: self.pickerTerminals)
        // Discover all paired and connected Posmate terminals - Spire is producing Posmate | SPm2 | Spm20 which are all served by WDPosMateExtension
        WDePOS.sharedInstance().terminalManager.discoverDevices(WDExtensionTypeUUID.WDPosMateExtensionUUID, // Vendor UUID - Spire terminals have the UUID of WDPosMateExtensionUUID
            completion:completionTerminals) // completion to be executed at the end of discovery method
    }
    
    func getPrinters(){
        // Completion from the Printer Discovery API
        let completionPrinters = {(arr: [WDTerminal]?, error:Error?) in
            Messages().hideActivity(onView: self.pickerPrinters)
            self.printers = arr
            self.pickerPrinters.reloadAllComponents()
            
            if let printers = self.printers{
                if let printer = self.selectedPrinter {
                    if let idx = printers.index(where: {$0.displayName == printer.displayName}){
                        self.pickerTerminals.selectRow((idx-1), inComponent: 0, animated: true)
                    }
                    
                }
                else{
                    if printers.count == 1 {
                        self.selectedPrinter = printers[0]
                        self.pickerPrinters.selectRow(0, inComponent: 0, animated: true)
                    }
                }
            }
            
            if let  error = error{
                Messages().showError(title: "Printers", message: error.localizedDescription)
            }

        }
        Messages().showActivity(onView: self.pickerPrinters)
        // Discover all paired and connected Stario printers - Spire is producing mPOP which is  served by WDMPOPExtension
        WDePOS.sharedInstance().printerManager.discoverDevices(WDExtensionTypeUUID.WDMPOPExtensionUUID, // Vendor UUID - mPOP printers have the UUID of WDMPOPExtensionUUID
            completion:completionPrinters) // completion to be executed at the end of discovery method
    }

    func getCashRegisters(){
        // End of get Cash Registers process
        let completion:CashRegisterCompletion = {(cashRegisters:[WDCashRegister]?, error:Error?) in
            Messages().hideActivity(onView: self.pickerCashRegisters)
            if let cashRegisters = cashRegisters {
                //Select the Cash Register you wish to use later for any Sale Request
                //This is an example how to select the Cash Register who's currency code is set to EUR
                let pred:NSPredicate = NSPredicate(format:"self.currency.code = 'EUR'")
                let cashRegistersArr:NSArray = cashRegisters as NSArray
                self.cashRegisters = cashRegistersArr.filtered(using:pred) as? [WDCashRegister]
                self.pickerCashRegisters.reloadAllComponents()
                
                if let cashRegister = self.selectedCashRegister {
                    if let idx = cashRegisters.index(where: { $0.registerName == cashRegister.registerName}){
                        self.pickerCashRegisters.selectRow((idx-1), inComponent: 0, animated: true)
                    }
                    
                }
            }
            else{
                self.pickerCashRegisters.reloadAllComponents()
            }
            
            if let  error = error{
                Messages().showError(title: "Cash Registers", message: error.localizedDescription)
            }

        }
        
        Messages().showActivity(onView: self.pickerCashRegisters)
        //Obtain the list of Cash Registers for the Merchant who has Cash Management enabled
        WDePOS.sharedInstance().cashManager.cashRegisters(((UIApplication.shared.delegate as! AppDelegate).currentUser?.merchant?.merchantId)!, //Merchant ID for who to obtain the Cash Registers list
            shopId: "",
            cashDrawerVendor:"",
            completion:completion) // End of get Cash Registers process
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            guard let terminals = self.terminals, (self.terminals?.count)! > 0 else {
                return 1
            }
            return terminals.count
        }
        else if pickerView.tag == 2{
            guard let printers = self.printers, (self.printers?.count)! > 0 else {
                return 1
            }
            return printers.count
        }
        else if pickerView.tag == 3{
            guard let cashRegisters = self.cashRegisters else {
                return 1
            }
            return cashRegisters.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            guard let terminals = self.terminals, (self.terminals?.count)! > 0 else {
                return "No terminals available"
            }
            return "\((terminals[row] as WDTerminal).terminalVendor.displayName) - \((terminals[row] as WDTerminal).displayName)"
        }
        else if pickerView.tag == 2{
            guard let printers = self.printers, (self.printers?.count)! > 0 else {
                return "No printers available"
            }
            return "\((printers[row] as WDTerminal).terminalVendor.displayName) - \((printers[row] as WDTerminal).displayName)"
        }
        else if pickerView.tag == 3{
            guard let cashRegisters = self.cashRegisters else {
                return "No cash registers available"
            }
            return (cashRegisters[row] as WDCashRegister).registerName
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            if let terminals = self.terminals {
                selectedTerminal = terminals[row]
            }
        }
        else if pickerView.tag == 2{
            if let printers = self.printers {
                selectedPrinter = printers[row]
            }
        }
        else if pickerView.tag == 3{
            if let cashRegisters = self.cashRegisters {
                selectedCashRegister = cashRegisters[row]
            }
        }
    }

}
