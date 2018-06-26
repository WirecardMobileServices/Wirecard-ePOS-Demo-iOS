//
//  SalesVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 19/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

private let reuseIdentifier = "Cell"


class SalesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var receiptButton: UIButton!
    @IBOutlet weak var refundButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var sales:[WDSaleResponse]?
    private var _selectedSale:WDSaleResponse?
    
    var selectedSale: WDSaleResponse? {
        get {
            return _selectedSale
        }
        set {
            _selectedSale = newValue
            receiptButton.isEnabled = ( _selectedSale != nil)
            refundButton.isEnabled = ( _selectedSale != nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        receiptButton.isEnabled = false
        refundButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSales()
    }
    
    // MARK: - Custom Methods
    
    func getSales(){
        // End of Sale Query process
        let completion:SaleQueryResponse! = {(sales:[WDSaleResponse]?, error: Error?) in
            // sales list of WDSaleResponse objects
            // SaleResponse has all the details of the performed Sale including
            // - Transaction details (CARD | COUPON | CASH)
            // - Basket details
            Messages().hideActivity(onView: self.view)
            self.sales = sales
            self.tableView.reloadData()
            
            if let  error = error{
                Messages().showError(title: "Sales", message: error.localizedDescription)
            }
            else{
                if let selectedSale = self.selectedSale {
                    if let idx = self.sales?.index(where: {$0.internalId == selectedSale.internalId}){
                        self.tableView.selectRow(at: IndexPath.init(row: idx, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
                    }
                }
            }

        }
        
        // Query parameters such as paging, order by, sort
        // and specific filters such as full text search, sale creation date, sale type, sale status
        let query:WDSalesQuery!  = WDSalesQuery.init(page: 0,
                                                     pageSize: 20,
                                                     orderBy: WDSaleQueryOrderBy.createdAt, // Order by Creation date
            order: WDQuerySort.descending, // Sort Descending - latest Sale first
            statuses: [],//all statuses or [NSNumber(value:UInt(WDSaleState.completed.rawValue))] for completed only
            saleTypes: [    NSNumber(value:UInt(WDSaleType.purchase.rawValue))])// Purchases
        
        Messages().showActivity(onView: self.view)
        // Obtain the Sale
        WDePOS.sharedInstance().saleManager.querySales(query,  // Sale query parameters
            completion: completion) // End of Sale Query process
    }
    
    func returnSale(){
        // End of Return process
        let completion:SaleUpdateCompletion = {(sale:WDSaleResponse?, error:Error?) in
            // sale - refunded sale detail
            // error - if encountered during the Refund process
            Messages().hideActivity(onView: self.view)
            self.getSales()
        }
        
        if let selectedSale = selectedSale{
            let saleReturn:WDSaleRequest! = selectedSale.saleReturn()// Here we created the full Sale Return
            if let cashRegister = (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister {
                saleReturn.cashRegisterId = cashRegister.internalId!
            }
            // Alternatively you would create the Sale Return consisting only of Items you wish to Return - aka Partial Return
            // Perform the Refund
            Messages().showActivity(onView: self.view)
            WDePOS.sharedInstance().saleManager.refundSale(saleReturn,// The full Sale Return Request
                message: "Merchant Refunded", // Set the note for this Return
                completion: completion) // End of Return process
        }
    }
        
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let selectedSale = selectedSale{
            let receiptVC = segue.destination as! ReceiptVC
            receiptVC.saleResponse = selectedSale
        }
    }
    
    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selected
        selectedSale = self.sales![indexPath.row]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sales = self.sales{
            return sales.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier){
//            tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            if let sales = sales {
                let sale = sales[indexPath.row]
                
                var cardHolder = "Cash"
                if sale.processedAlipayPayment() != nil {
                    cardHolder = "Alipay"
                }
                else if sale.processedWeChatPayment() != nil {
                    cardHolder = "WeChat"
                }
                else if sale.processedCardPayment() != nil {
                    cardHolder = sale.processedCardPayment().cardHolderName ?? ""
                }

                var color = UIColor.init(red: 0, green: 153/255, blue: 51/255, alpha: 1)
                
                switch sale.status {
                case WDSaleState.canceled:
                        color = UIColor.yellow
                case WDSaleState.returned:
                    color = UIColor.blue
                case WDSaleState.completed:
                    color = UIColor.init(red: 0, green: 153/255, blue: 51/255, alpha: 1)
                default:
                    color = UIColor.red
                }
                
                let statusString = "\t \(SaleStatusFromWDSaleStatus(sale.status))"
                let myString = NSMutableAttributedString(string: cardHolder)
                
                let myRange = NSRange(location: cardHolder.count, length: statusString.count)
                myString.append(NSAttributedString(string:statusString))
                myString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: myRange)
                
                let initialized = "\n\(WDUtils.formatDate(sale.initialized, format: "dd/MM/yyyy HH:mm:ss")!)"
                
                myString.append(NSAttributedString(string:initialized))
                let myRange1 = NSRange(location: cardHolder.count + statusString.count, length: initialized.count)
                myString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: myRange1)
                myString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Helvetica", size: 12.0)!, range: myRange1)

                cell.textLabel?.numberOfLines = 2
                cell.textLabel?.attributedText = myString
                cell.detailTextLabel?.text = WDUtils.formatNumber(sale.totalToPay(), withCurrencyCode: "EUR", showSymbol: true)
            }
            return cell
        }
        return UITableViewCell()
    }
    // MARK: - Custom Actions
    @IBAction func onTapReturn(_ sender: Any) {
        returnSale()
    }
}
