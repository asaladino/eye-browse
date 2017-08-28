//
//  Bookmark.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import Foundation
import CoreData

class Bookmark: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var created: Date
    @NSManaged var page: Page

}
