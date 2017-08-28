//
//  PrintActivity.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/16/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

class PrintActivity: UIActivity {
    
    var delegate: IPrintActivityDelegate?
    let factory = NIKFontAwesomeIconFactory()
    
//    override var activityType : String? {
//        return "PrintActivity"
//    }
    
    override var activityTitle : String? {
        return "Print"
    }
    
    override var activityImage : UIImage? {
        return factory.createImage(for: NIKFontAwesomeIconPrint)
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activity in activityItems {
            if (activity as? String) == "PrintActivity" {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for activity in activityItems {
            delegate = activity as? IPrintActivityDelegate
            if delegate != nil {
                break
            }
        }
    }
    
    override func perform() {
        delegate?.printActivity()
    }
}
