//
//  Screenshot.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import Foundation
import CoreData

class Screenshot: NSManagedObject {

    @NSManaged var image: Data
    @NSManaged var page: Page

}
