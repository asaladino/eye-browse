//
//  CoreDataSettingsRepository.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataSettingsRepository: CoreDataRepository {
    
    override init(managedContext: NSManagedObjectContext) {
        super.init(managedContext: managedContext)
        entity = "Setting"
    }
    
    func find() -> Setting {
        return findFirstOrCreate() as! Setting
    }
    
}
