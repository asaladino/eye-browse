//
//  BookmarkActivityItem.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/16/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

class BookmarkActivityItem: NSObject, UIActivityItemSource {
    
    var delegate:IBookmarkActivityDelegate?
    
    init(delegate: IBookmarkActivityDelegate) {
        self.delegate = delegate
    }

    /**
    Called to determine data type. only the class of the return type is consulted. it should match what -itemForActivityType: returns later
    */
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "BookmarkActivity"
    }
    
    /**
    Called to fetch data after an activity is selected. you can return nil.
    */
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
//        if activityType == "BookmarkActivity" {
//            return delegate
//        }
        return nil
    }
}
