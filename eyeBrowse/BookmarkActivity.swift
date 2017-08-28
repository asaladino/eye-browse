//
//  BookmarkActivity.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/13/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

class BookmarkActivity: UIActivity {
    
    var delegate:IBookmarkActivityDelegate?
    let factory = NIKFontAwesomeIconFactory()
 
//    override var activityType : String? {
//        return "BookmarkActivity"
//    }
    
    override var activityTitle : String? {
        return "Bookmark"
    }
    
    override var activityImage : UIImage? {
        return factory.createImage(for: NIKFontAwesomeIconBookmark)
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activity in activityItems {
            if (activity as? String) == "BookmarkActivity" {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for activity in activityItems {
            delegate = activity as? IBookmarkActivityDelegate
            if delegate != nil {
                break
            }
        }
    }
    
    override func perform() {
        delegate?.bookmarkActivity()
    }
}
