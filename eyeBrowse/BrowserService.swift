//
//  BrowserService.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/9/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class BrowserService: NSObject {
    
    var coreDataSettingsRepository:CoreDataSettingsRepository!
    var coreDataTabsRepository:CoreDataTabsRepository!
    var coreDataPagesRepository:CoreDataPagesRepository!
    var coreDataScreenshotsRepository:CoreDataScreenshotsRepository!
    var coreDataBookmarksRepository: CoreDataBookmarksRepository!
    
    var setting: Setting!
    
    init(managedObjectContext: NSManagedObjectContext) {
        coreDataSettingsRepository = CoreDataSettingsRepository(managedContext: managedObjectContext)
        coreDataTabsRepository = CoreDataTabsRepository(managedContext: managedObjectContext)
        coreDataPagesRepository = CoreDataPagesRepository(managedContext: managedObjectContext)
        coreDataScreenshotsRepository = CoreDataScreenshotsRepository(managedContext: managedObjectContext)
        coreDataBookmarksRepository = CoreDataBookmarksRepository(managedContext: managedObjectContext)
        
        setting = coreDataSettingsRepository.find()
        let currentTab = setting.currentTab as Tab?
        if currentTab == nil {
            setting.currentTab = coreDataTabsRepository.find()
        }
    }
    
    /**
    Get the last page viewed
    
    :returns: the last page viewed on the current tab
    */
    func getPageLastViewed() -> Page {
        return setting.currentTab.pageLastViewed
    }
    
    /**
    Set the last page viewed

    :param: page to set as the last viewed.
    */
    func setPageLastViewed(_ page: Page) throws {
        page.created = Date()
        setting.currentTab.pageLastViewed = page
        try coreDataPagesRepository.save()
    }
    
    /**
    Set current page from url
    
    :param: url to find or create a page from
    */
    func createPageFromUrl(_ url: String) throws -> Page {
        let predicate = NSPredicate(format:"url = %@ AND tab = %@", url, setting.currentTab)
        let pages = coreDataPagesRepository.findAllManagedObjectsForTerm(predicate) as! [Page]
        var page: Page
        if pages.first != nil {
            page = pages.first!
            page.created = Date()
        } else {
            page = coreDataPagesRepository.create()
            page.screenshot = coreDataScreenshotsRepository.create()
            page.tab = setting.currentTab
            page.url = url
            page.breakUpUrl()
            setting.currentTab.addPage(page)
        }
        setting.currentTab.pageLastViewed = page
        try coreDataSettingsRepository.save()
        return page
    }
    
    func hasNoPreviousPage() -> Bool {
        let currentPage = setting.currentTab.pageLastViewed as Page?
        if currentPage == nil {
            return true
        }
        if !coreDataPagesRepository.hasPreviousPage(currentPage!, forTab: setting.currentTab) {
            return true
        }
        return false
    }
    
    func hasNoNextpage() -> Bool {
        let currentPage = setting.currentTab.pageLastViewed as Page?
        if currentPage == nil {
            return true
        }
        if !coreDataPagesRepository.hasNextPage(currentPage!, forTab: setting.currentTab) {
            return true
        }
        return false
    }
    
    func hasPreviousPage() -> Bool {
        let tab = setting.currentTab
        return coreDataPagesRepository.hasPreviousPage(tab.pageLastViewed, forTab: tab)
    }
    
    func hasNextPage() -> Bool {
        let tab = setting.currentTab
        return coreDataPagesRepository.hasNextPage(tab.pageLastViewed, forTab: tab)
    }
    
    func findPreviousPage() -> Page {
        let tab = setting.currentTab
        return coreDataPagesRepository.findPreviousPage(tab.pageLastViewed, forTab: tab)
    }
    
    func findNextpage() -> Page {
        let tab = setting.currentTab
        return coreDataPagesRepository.findNextPage(tab.pageLastViewed, forTab: tab)
    }
    
    /**
    Service wrapper for finding all the pages for a term
    
    :param: term is a string to search for.
    :returns: a list of pages
    */
    func findAllWithTerm(_ term: String) -> [Page] {
        return coreDataPagesRepository.findAllWithTerm(term)
    }
    
    /**
    Find all the available pages.
    
    :returns: All the pages.
    */
    func findHistory() -> [Page] {
        let predicate = NSPredicate(format:"bookmark == nil")
        return coreDataPagesRepository.findAllManagedObjectsForTerm(predicate) as! [Page]
    }
    
    func deleteHistory() throws {
        let predicate = NSPredicate(format:"tabLastViewed == nil AND bookmark == nil")
        let pages = coreDataPagesRepository.findAllManagedObjectsForTerm(predicate) as! [Page]
        for page in pages {
            deleteObject(page)
        }
        try coreDataPagesRepository.save()
    }
    
    /**
    Find the previous page and set it to current.
    */
    func findPreviousPageSetToCurrentPage() {
        let tab = setting.currentTab
        tab.pageLastViewed = coreDataPagesRepository.findPreviousPage(tab.pageLastViewed, forTab: tab)
    }
    
    /**
    Find the next page and set it to current.
    */
    func findNextpageSetToCurrentPage() {
        let tab = setting.currentTab
        tab.pageLastViewed = coreDataPagesRepository.findNextPage(tab.pageLastViewed, forTab: tab)
    }
    
    /**
    Check to see if the current page has been set.
    
    :returns: Bool true if current page is not nil
    */
    func isCurrentPageSet() -> Bool {
        let currentPage = setting.currentTab.pageLastViewed as Page?
        return currentPage != nil
    }
    
    ///////////////////////////////////////////////////////////////
    // MARK: BOOKMARK MANAGEMENT
    ///////////////////////////////////////////////////////////////
    
    /**
    Find all bookmarks
    */
    func findAllBookmarks() -> [Bookmark] {
        return coreDataBookmarksRepository.findAll()
    }
    
    /**
    Set a bookmark as the current page.
    
    :param: bookmark to set as current page.
    */
    func setBookmarkAsCurrentPage(_ bookmark: Bookmark) throws {
        try setPageLastViewed(bookmark.page)
        try coreDataSettingsRepository.save()
    }
    
    ///////////////////////////////////////////////////////////////
    // MARK: TAB MANAGEMENT
    ///////////////////////////////////////////////////////////////
    
    /**
    Create a new tab and get all the tabs.

    :returns: a list of all the tabs.
    */
    func newTab() throws -> [Tab] {
        setting.currentTab = coreDataTabsRepository.createNewEntity() as! Tab
        setting.currentTab.created = Date()
        try coreDataSettingsRepository.save()
        return coreDataTabsRepository.findAll()
    }
    
    /**
    Wraper for getting all available tabs.

    :returns: list of tabs
    */
    func findAllTabs() -> [Tab] {
        return coreDataTabsRepository.findAll()
    }
    
    /**
    Set the current tab with a new tab.
    
    :returns: true if a new tab was set.
    */
    func setCurrentTabWithTab(_ tab: Tab) throws -> Bool {
        if setting.currentTab != tab {
            setting.currentTab = tab
            try coreDataSettingsRepository.save()
            return true
        }
        return false
    }
    
    /**
    Delete a tab then find all the tabs.
    
    :param: tab to delete
    :returns: all the tabs.
    */
    func deleteTabAndFindAll(_ tab: Tab) throws -> [Tab] {
        deleteObject(tab)
        try coreDataSettingsRepository.save()
        return findAllTabs()
    }
    
    /**
    Delete any Core Data object.
    
    :param: entity to delete.
    */
    func deleteObject(_ entity: NSManagedObject) {
        coreDataTabsRepository.deleteObject(entity)
    }
}
