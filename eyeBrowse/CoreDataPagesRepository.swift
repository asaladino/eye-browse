//
//  CoreDataPagesRepository.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/4/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataPagesRepository: CoreDataRepository {
    
    override init(managedContext: NSManagedObjectContext) {
        super.init(managedContext: managedContext)
        entity = "Page"
    }
    
    
    func create() -> Page {
        return createNewEntity() as! Page
    }
    
    /**
    Create a duplicate copy of a page

    :param: page to duplicate
    :returns: the duplicated page.
    */
    func duplicate(_ page: Page) -> Page {
        let duplicatePgae = createNewEntity() as! Page
        duplicatePgae.created = Date()
        duplicatePgae.url = page.url
        duplicatePgae.urlDomain = page.urlDomain
        duplicatePgae.urlFinal = page.urlFinal
        duplicatePgae.urlProtocol = page.urlProtocol
        duplicatePgae.urlUri = page.urlUri
        duplicatePgae.screenshot = page.screenshot
        return duplicatePgae
    }
    
    func findAll() -> [Page] {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        return self.findAllManagedObjects([sortDescriptor], withPredicate: nil) as! [Page]
    }
    
    func findAll(_ ascending: Bool, forTab tab: Tab) -> [Page] {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: ascending)
        let predicate = NSPredicate(format:"tab == %@", tab)
        return self.findAllManagedObjects([sortDescriptor], withPredicate: predicate) as! [Page]
    }
    
    func findLastPage(_ tab: Tab) -> Page? {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let predicate = NSPredicate(format:"tab == %@", tab)
        let pages = self.findAllManagedObjects([sortDescriptor], withPredicate: predicate) as! [Page]
        return pages.first
    }
    
    func findAllWithTerm(_ term: String) -> [Page] {
        if term != "" {
            let predicate = NSPredicate(format:"url CONTAINS[cd] %@", term)
            return findAllManagedObjectsForTerm(predicate) as! [Page]
        }
        return []
    }
    
    func findPreviousPage(_ currentPage: Page, forTab tab: Tab) -> Page {
        let pages = findAll(false, forTab: tab)
        return findNeighbor(currentPage, pagesList: pages)
    }
    
    func hasPreviousPage(_ currentPage: Page, forTab tab:Tab) -> Bool {
        let pages = findAll(false, forTab: tab)
        return hasNeighbor(currentPage, pagesList: pages)
    }
    
    func findNextPage(_ currentPage: Page, forTab tab: Tab) -> Page {
        let pages = findAll(true, forTab: tab)
        return findNeighbor(currentPage, pagesList: pages)
    }
    
    /**
    Check to see if current page has next page.
    
    :param: the current page you want to check
    :returns: bool true if it does have a next page.
    */
    func hasNextPage(_ currentPage: Page, forTab tab: Tab) -> Bool {
        let pages = findAll(true, forTab: tab)
        return hasNeighbor(currentPage, pagesList: pages)
    }
    
    func findNeighbor(_ currentPage: Page, pagesList pages:[Page]) -> Page {
        var found = false
        for (_, page) in pages.enumerated() {
            if found {
                return page
            }
            if page.url == currentPage.url {
                found = true
            }
        }
        return currentPage
    }
    
    func hasNeighbor(_ currentPage: Page?, pagesList pages:[Page]) -> Bool {
        var found = false
        for (_, page) in pages.enumerated() {
            if found {
                return true
            }
            if page.url == currentPage?.url {
                found = true
            }
        }
        return false
    }
   
}
