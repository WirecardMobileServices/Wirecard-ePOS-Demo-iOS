//
//  Messages.swift
//  Clear
//
//  Created by Danko, Radoslav on 23/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit

class Messages: NSObject {

    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
    

    func showAlert(title:String, message:String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.rootViewController?.present(alert, animated: true, completion: nil);
        
    }
    
    func showError(title:String, message:String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
        // show the alert
        if let presented = self.rootViewController?.presentedViewController {
            presented.present(alert, animated: true, completion: nil)
        }
        else{
            self.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showActivity(onView:UIView){
        guard onView.viewWithTag(999) != nil else {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            activityView.color = UIColor.darkGray
            activityView.layer.shadowColor = UIColor.black.cgColor
            activityView.layer.shadowRadius = 12
            activityView.layer.shadowOpacity = 1
            activityView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
            activityView.layer.masksToBounds = false
            activityView.clipsToBounds = false
            activityView.tag = 999
            activityView.center = CGPoint.init(x: onView.frame.size.width/2, y: onView.frame.size.height/2)
            onView.addSubview(activityView)
            activityView.startAnimating()
            onView.bringSubview(toFront: activityView)
            return
        }
    }
    
    func hideActivity(onView:UIView){
        if let activityView = onView.viewWithTag(999){
            activityView.removeFromSuperview()
        }
    }

}
