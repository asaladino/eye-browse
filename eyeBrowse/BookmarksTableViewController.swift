//
//  BookmarksTableViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/10/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class BookmarksTableViewController: UITableViewController {

    var bookmarks: [Bookmark] = []
    var browserService: BrowserService!
    
    var onBookmarks = false
    
    var isSearching = false
    var bookmarksFiltered:[Bookmark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        onBookmarks = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onBookmarks = false
    }
    
    func initData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        browserService = BrowserService(managedObjectContext: appDelegate.managedObjectContext!)
        bookmarks = browserService.findAllBookmarks()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(BookmarksTableViewController.coreDataDidUpdate(_:)),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: appDelegate.managedObjectContext)
    }
    
    @IBAction func cancelBookmarks(_ sender: AnyObject) {
         dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return bookmarksFiltered.count
        }
        return bookmarks.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.row == 0 && !isSearching {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "History", for: indexPath) as UITableViewCell
        } else {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "Bookmark", for: indexPath) as UITableViewCell
            var bookmark:Bookmark
            if isSearching {
                bookmark = bookmarksFiltered[indexPath.row]
            } else {
                bookmark = bookmarks[(indexPath.row - 1)]
            }
            cell.textLabel?.text = bookmark.name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 || isSearching {
            var bookmark:Bookmark
            if isSearching {
                bookmark = bookmarksFiltered[indexPath.row]
            } else {
                bookmark = bookmarks[(indexPath.row - 1)]
            }
            do {
                try browserService.setBookmarkAsCurrentPage(bookmark)
            } catch  {}
        }
    }
    
    func coreDataDidUpdate(_ note:Notification) {
        if onBookmarks {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isSearching {
            return false
        }
        return indexPath.row != 0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = bookmarks[indexPath.row - 1]
            bookmarks.remove(at: indexPath.row - 1)
            browserService.deleteObject(bookmark)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func filterContentForSearchText(_ searchString: String) {
        let predicate = NSPredicate(format:"name CONTAINS[cd] %@ OR page.url CONTAINS[cd] %@", searchString, searchString)
        bookmarksFiltered = bookmarks.filter { predicate.evaluate(with: $0) }
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(searchDisplayController!.searchBar.text!)
        return true
    }
    
    func searchDisplayControllerDidBeginSearch(_ controller: UISearchDisplayController) {
        isSearching = true
    }
    
    func searchDisplayControllerDidEndSearch(_ controller: UISearchDisplayController) {
        isSearching = false
    }
}
