//
//  Tab.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import Foundation
import CoreData

class Tab: NSManagedObject {

    @NSManaged var created: Date
    @NSManaged var pages: NSSet
    @NSManaged var pageLastViewed: Page
    @NSManaged var setting: NSManagedObject

}
