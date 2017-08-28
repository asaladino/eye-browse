//
//  CoreDataTabsRepository.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTabsRepository: CoreDataRepository {
    
    override init(managedContext: NSManagedObjectContext) {
        super.init(managedContext: managedContext)
        entity = "Tab"
    }
    
    func find() -> Tab {
        return findFirstOrCreate() as! Tab
    }
    
    func findAll() -> [Tab] {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        return self.findAllManagedObjects([sortDescriptor], withPredicate: nil) as! [Tab]
    }
}
