//
//  HistoryTableViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/18/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var history: [Page] = []
    var browserService: BrowserService!
    
    var isSearching = false
    var historyFiltered:[Page] = []
    
    let coreDataHelpers = CoreDataHelpers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    func initData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        browserService = BrowserService(managedObjectContext: appDelegate.managedObjectContext!)
        history = browserService.findHistory()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(HistoryTableViewController.coreDataDidUpdate(_:)),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: appDelegate.managedObjectContext)
    }
    
    func coreDataDidUpdate(_ note:Notification) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearHistory(_ sender: AnyObject) {
        do {
            try browserService.deleteHistory()
        } catch {
           
        }
        history = browserService.findHistory()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return historyFiltered.count
        }
        return history.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "History", for: indexPath) as UITableViewCell
        var page:Page
        if isSearching {
            page = historyFiltered[indexPath.row]
        } else {
            page = history[indexPath.row]
        }
        cell.textLabel?.text = page.getDisplayTitle()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var page:Page
        if isSearching {
            page = historyFiltered[indexPath.row]
        } else {
            page = history[indexPath.row]
        }
        do {
            try browserService.setPageLastViewed(page)
        } catch {
            
        }
        
    }
    
    func filterContentForSearchText(_ searchString: String) {
        let predicate = NSPredicate(format:"title CONTAINS[cd] %@ OR url CONTAINS[cd] %@", searchString, searchString)
        historyFiltered = history.filter { predicate.evaluate(with: $0) }
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController!, shouldReloadTableForSearch searchString: String!) -> Bool {
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
