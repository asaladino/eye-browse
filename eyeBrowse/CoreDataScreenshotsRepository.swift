//
//  CoreDataScreenshotsRepository.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/9/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataScreenshotsRepository:  CoreDataRepository {
    
    override init(managedContext: NSManagedObjectContext) {
        super.init(managedContext: managedContext)
        entity = "Screenshot"
    }
    
    func create() -> Screenshot {
        return createNewEntity() as! Screenshot
    }
   
}
