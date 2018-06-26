//
//  ReceiptVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 20/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

class ReceiptVC: UIViewController {
    
    public var saleResponse: WDSaleResponse?
    
    @IBOutlet weak var receiptView: UIImageView!
    
    
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
        self.receiptView.image = nil;
        
        if let sale = saleResponse {
            Messages().showActivity(onView: receiptView)
            sale.receipt(true, showReturns: false, format: WDPrintFormat.uiImage, dpi: WDPrintDpi.mpop) { (receipts: [Any]?, error:Error?) in
                Messages().hideActivity(onView: self.receiptView)
                if let receipts = receipts{
                    let receipt = (receipts.first as! UIImage)
                    self.receiptView.image = receipt
                }
            }
        }
    }
    // MARK: - Custom Methods
    func print(){
        if let printer = (UIApplication.shared.delegate as! AppDelegate).selectedPrinter {
            //End of printing process
            let completion:PrintCompletion  = {(printStatusOK:Bool , error:Error?) in
                //printStatusOK is true if printing ended with OK status
                
                if let  error = error{
                    Messages().showError(title: "Print", message: error.localizedDescription)
                }
            }
            
            let progress:PrinterStateUpdate  = {(printProgress:WDPrinterStateUpdate ) in
                //printProgress - print progress Initialisation | Printing | Finished
            }
            
            let printConfig:WDPrinterConfig = WDPrinterConfig()
            printConfig.printer = printer
            if let sale = saleResponse {
                Messages().showActivity(onView: self.receiptView)
                let isDatecs = printer.terminalVendor.vendorUUID == WDExtensionTypeUUID.WDDatecsExtensionUUID
                sale.receipt(true, showReturns: false,
                             format:isDatecs ? WDPrintFormat.datecs : WDPrintFormat.uiImage,
                             dpi: isDatecs ? WDPrintDpi.default : WDPrintDpi.mpop) { (receipts: [Any]?, error:Error?) in
                    if let receipts = receipts{
                        printConfig.printJobs = [receipts]
                        Messages().hideActivity(onView: self.receiptView)
                        WDePOS.sharedInstance().printerManager.print(printConfig, progress: progress, completion: completion)
                    }
                }
            }
        }
        else{
            Messages().showError(title: "Print", message: "Please select the printer in the Settings")
        }
    }
// MARK: - Custom Actions
    
    @IBAction func onTapDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onTapPrint(_ sender: Any) {
        print()
    }
    
}
