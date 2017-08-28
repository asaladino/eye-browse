//
//  CoreDataRepository.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 11/20/14.
//  Copyright (c) 2014 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataRepository: NSObject {
    
    var managedContext:NSManagedObjectContext!
    var error:NSError?
    var entity = ""
    let coreDataHelpers = CoreDataHelpers()
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func findAllManagedObjects(_ sortDescriptors: [NSSortDescriptor], withPredicate predicate: NSPredicate?) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:entity)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        do {
            return try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            return []
        }
    }
    
    func findAllManagedObjectsForTerm(_ searchPredicate:NSPredicate) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:entity)
        fetchRequest.predicate = searchPredicate
        fetchRequest.fetchBatchSize = 20
        do {
            return try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch  {
            return []
        }
    }
    
    func findFirstOrCreate() -> NSManagedObject {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:entity)
        fetchRequest.fetchBatchSize = 2
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                return fetchedResults.first!
            }
        } catch { }
        let newEntity =  NSEntityDescription.entity(forEntityName: entity, in: managedContext)
        return NSManagedObject(entity: newEntity!, insertInto:managedContext)
    }
    
    func createNewEntity() -> NSManagedObject {
        let newEntity =  NSEntityDescription.entity(forEntityName: entity, in: managedContext)
        return NSManagedObject(entity: newEntity!, insertInto:managedContext)
    }
    
    func deleteObject(_ entity: NSManagedObject) {
        managedContext.delete(entity)
    }
    
    func deleteAll() {
        let mos = findAllManagedObjects([], withPredicate: nil)
        for mo in mos {
            deleteObject(mo)
        }
    }
    
    func save() throws {
        try managedContext.save()
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        var cleanedDate = dateString.replacingOccurrences(of: "T", with: " ", options: String.CompareOptions.literal, range: nil)
        cleanedDate = cleanedDate.replacingOccurrences(of: "+00:00", with: "", options: String.CompareOptions.literal, range: nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        return dateFormatter.date(from: cleanedDate)
    }
    
}
