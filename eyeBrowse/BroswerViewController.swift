//
//  BrowserViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/5/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData
import WebKit

/**
TODO's for Browser:

- Add cookie and session caching.
- Stabilize swiping and history.
- Deep linking for http:// requests || Can't do only for safari.
- Add tab browsing.
- Add bookmarking.
- Air Printing.
- Parse url into protocol, domain, and uri
- Fix rotation to landscape.
- Add history for tab.
- Button to clear history for tab.
- Filter in history.
- Filter in bookmarks.
* Add navigation drawer.

THOUGHTS
* https://github.com/beamly/BMYScrollableNavigationBar
* https://github.com/DrummerB/BFNavigationBarDrawer
* https://github.com/willowtreeapps/WTAZoomNavigationController
* https://github.com/heroims/LeftRightSlider

* http://api.duckduckgo.com/?q=DuckDuckGo&format=json&pretty=1

TODO's for filtering

1. Interface with dropbox
2. Dropbox will hold filter by opendns tags, whitelisting and blacklisting
3. On dropbox login the device will need to be giving a name
*/

class PageBackForwardListItem {
    
    /*! @abstract The URL of the webpage represented by this item.
    */
    var URL: Foundation.URL!
    
    /*! @abstract The title of the webpage represented by this item.
    */
    var title: String!
    
    /*! @abstract The URL of the initial request that created this item.
    */
    var initialURL: Foundation.URL!
}


class BrowserViewController: BaseViewController, IPrintActivityDelegate, IBookmarkActivityDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var pageViewController: UIPageViewController!
    var urlSearch = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet var searchController: UISearchDisplayController!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var pageContainer: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tabsButton: UIButton!
    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    var pageContentViewController: PageContentViewController!
    
    var browserService:BrowserService!
    var history:[Page] = []
    
    let coreDataHelpers = CoreDataHelpers()
    
    var statusBarHeight:CGFloat = 0.0
    var viewHeight:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        
        let factory = NIKFontAwesomeIconFactory.tabBarItem()
        
        menuButton.setImage(factory?.createImage(for: NIKFontAwesomeIconBars), for: UIControlState())
        menuButton.setTitle("", for: UIControlState())
        
        tabsButton.setImage(factory?.createImage(for: NIKFontAwesomeIconThLarge), for: UIControlState())
        tabsButton.setTitle("", for: UIControlState())
        
        bookmarksButton.setImage(factory?.createImage(for: NIKFontAwesomeIconBookmark), for: UIControlState())
        bookmarksButton.setTitle("", for: UIControlState())
        
        previousButton.setImage(factory?.createImage(for: NIKFontAwesomeIconChevronLeft), for: UIControlState())
        previousButton.setTitle("", for: UIControlState())
        
        nextButton.setImage(factory?.createImage(for: NIKFontAwesomeIconChevronRight), for: UIControlState())
        nextButton.setTitle("", for: UIControlState())
        
        activityButton.setImage(factory?.createImage(for: NIKFontAwesomeIconPuzzlePiece), for: UIControlState())
        activityButton.setTitle("", for: UIControlState())
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(BrowserViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @IBAction func showNavigationMenu(_ sender: AnyObject) {
        self.dynamicsDrawerViewController.setPaneState(MSDynamicsDrawerPaneState.open, in:MSDynamicsDrawerDirection.left, animated:true, allowUserInterruption:true, completion:nil)

    }
    
    func orientationChanged() {
        print("orientation change")
        let deviceOrientation = UIDevice.current.orientation
        if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
            toolbar.isHidden = true
            searchBar.isHidden = true
            menuButton.isHidden = true
            landscapePageView()
        } else if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
            toolbar.isHidden = false
            searchBar.isHidden = false
            menuButton.isHidden = false
            portratePageView()
        }
    }
    
    func landscapePageView() {
        let start:CGFloat = 0.0
        let end:CGFloat = 0.0
        print("start: \(start) | end: \(end)")
        positionPageView(start, end: end)
    }
    
    func portratePageView() {
        let start = statusBarHeight + searchContainer.frame.height
        let end = toolbar.frame.height
        print("start: \(start) | end: \(end)")
        positionPageView(start, end: end)
    }
    
    func positionPageView(_ start: CGFloat, end: CGFloat) {
        pageContainer.frame = CGRect(x: 0, y: start, width: view.frame.width, height: (viewHeight - end - start))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let page = browserService.getPageLastViewed() as Page?
        searchController.searchBar.text = page?.url
        updateNavigation()
        pageContentViewController?.loadPage(browserService.getPageLastViewed())
        if statusBarHeight == 0 {
            statusBarHeight = 20
            viewHeight = view.frame.size.height
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBookmark" {
            let navigationViewController = segue.destination as! UINavigationController
            let bookmarkViewController = navigationViewController.topViewController as! BookmarkViewController
            bookmarkViewController.page = browserService.getPageLastViewed()
        }
        
        if segue.identifier == "embedPageView" {
            pageContentViewController = segue.destination as! PageContentViewController
            pageContentViewController.browserViewController = self
        }
    }
    
    func initData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        browserService = BrowserService(managedObjectContext: appDelegate.managedObjectContext!)
    }
    
    func pageFromUrl(_ term:String) -> Page? {
        do {
            return try browserService.createPageFromUrl(term)
        } catch {
            return nil
        }
    }
    
    func updateNavigationToPage(_ page: Page?) {
        if page == browserService.getPageLastViewed() {
            searchController.searchBar.text = page?.getDisplayUrl()
            updateNavigation()
        }
    }
    
    func disableNavigation() {
        previousButton.isEnabled = true
        nextButton.isEnabled = false
    }
    
    func updateNavigation() {
        previousButton.isEnabled = false
        if browserService.hasPreviousPage() {
            previousButton.isEnabled = true
        }
        nextButton.isEnabled = false
        if browserService.hasNextPage() {
            nextButton.isEnabled = true
        }
    }
    
    /**
    Actions
    */
    @IBAction func share(_ sender: AnyObject) {
        let page = browserService.getPageLastViewed()
        if !page.url.isEmpty {
            let objectsToShare:[AnyObject] = [URL(string: page.url)! as AnyObject, PrintActivityItem(delegate: self), BookmarkActivityItem(delegate: self)]
            let applicationActivities = [BookmarkActivity(), PrintActivity()]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: applicationActivities)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func back(_ sender: AnyObject) {
        if browserService.hasPreviousPage() {
            browserService.findPreviousPageSetToCurrentPage()
            pageContentViewController.loadPageWithoutUpdate(browserService.getPageLastViewed())
        }
    }
    
    @IBAction func forward(_ sender: AnyObject) {
        if browserService.hasNextPage() {
            browserService.findNextpageSetToCurrentPage()
            pageContentViewController.loadPageWithoutUpdate(browserService.getPageLastViewed())
        }
    }
    
    /**
    TableView Delegate implementation.
    */
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = searchTable.dequeueReusableCell(withIdentifier: "cell")!
        let page = history[indexPath.row]
        cell.textLabel!.text = page.url
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        do {
            try browserService.setPageLastViewed(history[indexPath.row])
            searchDisplayController?.setActive(false, animated: true)
            pageContentViewController?.loadPage(browserService.getPageLastViewed())
        } catch { }
    }
    
    /**
    Search Display Controllers Delegate implementation.
    */
    func filterContentForSearchText(_ searchString: String?) {
        if searchString != nil {
            urlSearch = searchString!
            history = browserService.findAllWithTerm(searchString!)
        }
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController!, shouldReloadTableForSearch searchString: String!) -> Bool {
        filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        filterContentForSearchText(searchDisplayController!.searchBar.text)
        return true
    }
    
    func searchDisplayControllerDidEndSearch(_ controller: UISearchDisplayController) {
        searchController.searchBar.text = browserService.getPageLastViewed().url
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDisplayController?.setActive(false, animated: true)
        do {
            try browserService.createPageFromUrl(urlSearch)
            let page = browserService.getPageLastViewed()
            page.created = Date()
            pageContentViewController?.loadPage(page)
        } catch {
        }
    }
    
    /**
    Bookmark Activity Delegate
    */
    func bookmarkActivity() {
        self.performSegue(withIdentifier: "addBookmark", sender: self)
    }
    
    /**
    Print Activity Delegate
    */
    func printActivity() {
        let page = browserService.getPageLastViewed()
        let pi = UIPrintInfo(dictionary: nil)
        pi.outputType = .general;
        pi.jobName = page.url;
        pi.orientation = .portrait;
        pi.duplex = .longEdge;
        
        let pic = UIPrintInteractionController.shared
        pic.printInfo = pi
        pic.showsPageRange = true
        pic.printFormatter = pageContentViewController.webview.viewPrintFormatter()
        pic.present(animated: true, completionHandler: nil)
    }
}
