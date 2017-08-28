//
//  CoreDataBookmarksRepository.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/12/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataBookmarksRepository: CoreDataRepository {
    
    override init(managedContext: NSManagedObjectContext) {
        super.init(managedContext: managedContext)
        entity = "Bookmark"
    }
    
    func create() -> Bookmark {
        return createNewEntity() as! Bookmark
    }
    
    func findAll() -> [Bookmark] {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        return self.findAllManagedObjects([sortDescriptor], withPredicate: nil) as! [Bookmark]
    }
}
