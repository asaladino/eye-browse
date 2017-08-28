//
//  Page.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import Foundation
import CoreData

class Page: NSManagedObject {

    @NSManaged var created: Date
    @NSManaged var title: String
    @NSManaged var tab: Tab
    @NSManaged var bookmark: Bookmark
    @NSManaged var screenshot: Screenshot
    @NSManaged var tabLastViewed: Tab
    
    @NSManaged var url: String
    @NSManaged var urlFinal: String
    @NSManaged var urlProtocol: String
    @NSManaged var urlDomain: String
    @NSManaged var urlUri: String
    

}
