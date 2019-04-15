//
//  PaymentVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 19/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS

extension UIImage{
    class func signatureFromText(text:String, size:CGSize) -> UIImage?{
        let signatureLabel = UILabel.init(frame: CGRect.init(origin: CGPoint.zero, size: size))
        signatureLabel.backgroundColor = UIColor.white
        signatureLabel.textColor = UIColor.black
        signatureLabel.text = text
        signatureLabel.minimumScaleFactor = 0.5
        signatureLabel.font = UIFont(name: "Zapfino", size: 15)
        UIGraphicsBeginImageContextWithOptions(signatureLabel.bounds.size, signatureLabel.isOpaque, 0.0)
        signatureLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

class PaymentVC: UIViewController, WDPaymentDelegate {

    var saleResponse:WDSaleResponse?
    var amountString:String = ""
    let currency = "EUR"
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
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
        updateAmount()
    }
    // MARK: - Payment Delegate -
    // It is necessary to implement WDPaymentDelegate methods to receive events from the payment flow
    // Updates from the payment flow
    func progress(_ paymentProgress: WDStateUpdate) {
        // statusUpdate - coded statuses are reported throughout the payment flow
        
        switch paymentProgress {
        case WDStateUpdate.followTerminalInstructions:
            self.progressLabel.text = "Follow instructions on the terminal"
            break
        case WDStateUpdate.insertOrSwipeCard:
            self.progressLabel.text = "Insert or Swipe the card"
            break
        case WDStateUpdate.tapOrInsertOrSwipeCard:
            self.progressLabel.text = "Present, Insert or Swipe the card"
            break
        case WDStateUpdate.configurationProgressTerminalNotReady:
            self.progressLabel.text = "Terminal communication error"
            break
        case WDStateUpdate.waitingForPlugIn:
            self.progressLabel.text = "Waiting for terminal plug-in"
            break
        case WDStateUpdate.waitingForSwipe:
            self.progressLabel.text = "Waiting for card swipe"
            break
        case WDStateUpdate.damagedChipAndWaitingForSwipe:
            self.progressLabel.text = "Chip damaged, waiting for card swipe"
            break
        case WDStateUpdate.processingData:
            self.progressLabel.text = "Please wait, data processing"
            break
        case WDStateUpdate.onlineProcessingData:
            self.progressLabel.text = "Please wait, online data processing"
            break
        case WDStateUpdate.initialize:
            self.progressLabel.text = "Please wait, initializing"
            break
        case WDStateUpdate.terminalConfigOngoing:
            self.progressLabel.text = "Terminal configuration in progress"
            break
        case WDStateUpdate.waitingForInsertCard:
            self.progressLabel.text = "Waiting for card insertion"
            break
        case WDStateUpdate.checkingCard:
            self.progressLabel.text = "Checking the card"
            break
        case WDStateUpdate.removeCard:
            self.progressLabel.text = "Please remove the card"
            break
        case WDStateUpdate.cardRemoved:
            self.progressLabel.text = "Card removed"
            break
        case WDStateUpdate.confirmAmount:
            self.progressLabel.text = "Confirm the amount on the terminal"
            break
        case WDStateUpdate.amountConfirmed:
            self.progressLabel.text = "Amount confirmed"
            break
        case WDStateUpdate.pinEntered:
            self.progressLabel.text = "PIN entered"
            break
        case WDStateUpdate.correctPIN:
            self.progressLabel.text = "PIN correct"
            break
        case WDStateUpdate.pinEntryLastTry:
            self.progressLabel.text = "PIN entry - last try"
            break
        case WDStateUpdate.askingForPIN:
            self.progressLabel.text = "Enter the PIN"
            break
        case WDStateUpdate.pinEntryWrong:
            self.progressLabel.text = "Wrong PIN"
            break
        case WDStateUpdate.cardholderSignatureCheck:
            self.progressLabel.text = "Check the signature"
            break
        case WDStateUpdate.terminalRestarting:
            self.progressLabel.text = "Termninal is restarting"
            break
        case WDStateUpdate.gratuityEntryStarted:
            self.progressLabel.text = "Enter Gratuity"
            break
        case WDStateUpdate.applicationSelectionStarted:
            self.progressLabel.text = "Selecting application"
            break
        case WDStateUpdate.applicationSelectionFinished:
            self.progressLabel.text = "Application selected"
            break
        case WDStateUpdate.followInstructionsOnConsumerDevice:
            self.progressLabel.text = "Follow the instructions on the terminal"
            break
        case WDStateUpdate.configurationProgressUpdateWillStart:
            self.progressLabel.text = "Updating terminal"
            break
        case WDStateUpdate.configurationProgressDownloading:
            self.progressLabel.text = "Downloading termninal files"
            break
        case WDStateUpdate.configurationProgressUnzipping:
            self.progressLabel.text = "Processing terminal files archive"
            break
        case WDStateUpdate.configurationProgressUploading:
            self.progressLabel.text = "Uploading terminal files"
            break
        case WDStateUpdate.configurationProgressDeferredInstall:
            self.progressLabel.text = "Terminal files will be installed"
            break
        default:
            self.progressLabel.text = "Unknown Payment Progress Status :\(String(describing: progress))"
            break
        }
        
    }
    
    // In the case the Cardholder Signature is required by the Payment flow this block will be executed
    // Your task is to respond to it by collecting the signature image from the customer and
    // posting it back in the sendCollectedSignature method
    func collectSignature(_ signatureRequest: WDSignatureRequest) {
        //signatureRequest - comes from the payment flow and once you collect the signature from the customer
        // send it back in the signatureRequest.sendCollectedSignature
        let signature = UIImage.signatureFromText(text: "Cardholder Signature", size: CGSize.init(width: 240, height: 100))
        signatureRequest.sendCollectedSignature(signature,nil)
        //The signature image is transferred to the backend and stored with the Sale
    }
    
    // Note: Applicable to terminals without BUTTONS
    // In the case the Cardholder Signature was collected then the merchant is required to confirm it's validity
    // A. If the terminal has buttons that are used for Approving/Rejecting then this block is either never called from Payment flow
    // or it's signatureVerificationCallback comes nil
    // B. If the terminal does not have buttons then the Application must present a user interface to Approve/Reject the Cardholder Signature
    func confirm(_ confirmationType: WDPaymentConfirmationType, paymentConfirmationResult: PaymentConfirmationResult? = nil) {
        if let paymentConfirmationResult = paymentConfirmationResult {
            // Here the simplified use of Approving the Cardholder Signature is demonstrated
            paymentConfirmationResult(WDPaymentConfirmationResult.approved)
        }
    }
    
    // Note: Applicable to terminals without BUTTONS
    // In the case the payment Card has more than one card application available then the client application
    // has to present user interface for the Cardholder to select preferred card application
    // The list of card applications is present in appSelectionRequest.appsArray as a list of Strings
    func cardApplication(_ appSelectionRequest: WDAppSelectionRequest) {
        // There is more than 1 card application available
        // Present the UI for the Cardholder to select preferred card application (Debit | Credit)
        if ((appSelectionRequest.appsArray?.count) != nil) {
            // Here we demonstrate the simplified use of selecting the first card application from the list of available card applications
            // and sending it to the Payment flow
            appSelectionRequest.selectCardApplication(UInt(0))
        }
    }
    
    // The end of the payment process
    func completion(_ saleResponse: WDSaleResponse?, saleResponseError: Error?) {
        //sale - Is the completed Sale - contains the sale status, details, results
        //error - If any error is encountered during the sale it would be reported
        //in the form of error and hierarchy of underlying errors to give you as much details as possible
        self.progressLabel.text = ""
        Messages().hideActivity(onView: self.view)
        
        self.textView.text.append("Sale response : " + (saleResponse?.description ?? "Sale failed"))
        
        if let sale = saleResponse {
            sale.receipt(true, showReturns: false, format: .HTML, dpi: .default, completion: { (receipts, error) in
              
                if let receipt = receipts?.first as? WDHtmlReceiptData
                {
                    self.textView.text.append("Sale receipt : \n" + ( receipt.receiptDescription()))
                }
            })
            
            self.saleResponse = sale
            self.performSegue(withIdentifier: "segueReceipt", sender: self)
        
        }
        
        if let err = saleResponseError {
            self.textView.text.append("Sale error : " + err.localizedDescription)
            Messages().showError(title: "Payment", message: err.localizedDescription)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination.isKind(of: ReceiptVC.self){
            let receiptVC = segue.destination as! ReceiptVC
            receiptVC.saleResponse = self.saleResponse
        }
        
    }
    
    // MARK: - Actions
    @IBAction func onTapNumber(_ sender: Any) {
        if let btn  = sender as? UIButton {
            let keyString =  (btn.titleLabel?.text)!
            if keyString == "C"{
                if amountString.count > 0 {
                    amountString = String(amountString.dropLast())
                }
            }
            else{
                amountString.append(keyString)
            }
        }
        
        updateAmount()
    }
    @IBAction func onTapCardPayment(_ sender: Any) {
        pay(isCard: true)
    }
    @IBAction func onTapCashPayment(_ sender: Any) {
        pay(isCard: false)
    }
    
    // MARK: - Custom Methods
    
    func updateAmount(){
        var amountFixed = amountString
        if amountFixed.count == 0 {
            amountFixed = "0"
        }
        
        let amount = NSDecimalNumber.init(string: amountFixed).dividing(by: WDUtils.decimalDivider(currency))
        let amountFormatted = WDUtils.formatNumber(amount, withCurrencyCode: currency, showSymbol: true)
        amountLabel.text = amountFormatted
    }
    
    func cleanMessages(){
        textView.text = ""
    }
    
    func pay(isCard: Bool){


        guard amountString.count > 0 && !(NSDecimalNumber.init(string: amountString).isEqual(NSDecimalNumber.zero)) else {
            Messages().showAlert(title: "Payment", message: "Please specify the amount to pay")
            return
        }

        Messages().showActivity(onView: self.view)
        
        cleanMessages()
        
        // Create the instance of the Sale Request
        // Here the minimum data is depicted[WDSSharedSessionManager shared]
        
        let saleRequest:WDSaleRequest! = WDSaleRequest.init(uniqueId: WDUtils.uniqueID(), // provide your unique ID to identify the Sale
            location: nil, // provide the GPS location for this payment e.g. the mobile device location
            inclusiveTaxes: true, // Tax inclusive/exclusive flag
            currency: "EUR", // Currency to use for this Sale
            note: "Test Sale", // Top level note for this sale
            gratuityTaxRate: nil // Gratuity tax rate - nil if no gratuity to be set later in the payment flow
            )!
        
        let amount = NSDecimalNumber.init(string: amountString).dividing(by: WDUtils.decimalDivider(currency))
        
        // Create one item named "Item 1" costing 10.00 EUR at 20% Tax
        saleRequest.addSaleItem(amount, // Item Unit price
            quantity: 1, // Item Quantity
            taxRate: NSDecimalNumber.init(value: 20), // Item Tax rate
            itemDescription: "Item 1", // Item description
            productId: nil, // External product ID - in the case you are using ERP - such as SAP and wish to refer to the product
            externalProductId: nil
        )
        
        // Define the Sale type as Purchase [other available are Return | Authorize | Pre-Authorize]
        //saleRequest.type = WDSaleType.purchase
        
        if let cashRegister = (UIApplication.shared.delegate as! AppDelegate).selectedCashRegister {
            saleRequest.cashRegisterId = cashRegister.internalId!
        }
        
        // Create Payment Configuration to be used in the Sale API later
        //let paymentConfiguration:WDPaymentConfig! = WDPaymentConfig.init()
        let paymentConfiguration:WDSaleRequestConfiguration! = WDSaleRequestConfiguration.init(saleRequest: saleRequest)
        
        if isCard == true {
            
            if let terminal = (UIApplication.shared.delegate as! AppDelegate).selectedTerminal {
                // Set this Sale to be settled by Card transaction
                saleRequest.addCardPayment(amount, terminal: terminal)
                // Start the Payment flow
                WDePOS.sharedInstance().saleManager.pay(paymentConfiguration, with: self) // Block to be executed at the end of the Payment process
            }
            else{
                Messages().showError(title: "Payment", message: "Please select the terminal in the Settings")
            }
        }
        else{
            saleRequest.addCashPayment(amount)
            // Start the Payment flow
            WDePOS.sharedInstance().saleManager.pay(paymentConfiguration, with: self) // Block to be executed at the end of the Payment process
        }
    }
}
