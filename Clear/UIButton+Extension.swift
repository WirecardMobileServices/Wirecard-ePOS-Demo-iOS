//
//  UIButton+Extension.swift
//  Clear
//
//  Created by Danko, Radoslav on 25/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    override open var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            if newValue{
                self.alpha = 1
            }
            else{
                self.alpha = 0.5
            }
        }
    }
}
