//
//  TabsCollectionViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/10/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "CellTab"

class TabsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var browserService: BrowserService!
    var tabs: [Tab] = []
    var deleting = false
    var dismissing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    func initData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        browserService = BrowserService(managedObjectContext: appDelegate.managedObjectContext!)
        tabs = browserService.findAllTabs()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(TabsCollectionViewController.coreDataDidUpdate(_:)),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: appDelegate.managedObjectContext)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissing = false
        self.collectionView?.reloadData()
    }
    
    /**
    Set a collection cell to selected.
    
    :param: cell to set as selected.
    */
    func setCellToSelected(_ cell: UICollectionViewCell?) {
        let urlLabel = cell?.viewWithTag(2) as? UILabel
        cell?.backgroundColor = UIColor.darkGray
        urlLabel?.textColor = UIColor.white
    }
    
    /**
    Set a collection cell to un-selected.
    
    :param: cell to set as un-selected.
    */
    func setCellToUnSelected(_ cell: UICollectionViewCell?) {
        let urlLabel = cell?.viewWithTag(2) as? UILabel
        cell?.backgroundColor = UIColor.white
        urlLabel?.textColor = UIColor.black
    }
    
    func coreDataDidUpdate(_ note:Notification) {
        if dismissing {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    // MARK: Actions
    /////////////////////////////////////////////////////////////////////
    
    @IBAction func cancelTabs(_ sender: AnyObject) {
        deleting = !deleting
        self.collectionView?.reloadData()
    }

    @IBAction func addTab(_ sender: AnyObject) {
        dismissing = true
        do {
            tabs = try browserService.newTab()
            self.collectionView?.reloadData()
        } catch {}
        
    }
    
    /////////////////////////////////////////////////////////////////////
    // MARK: UICollectionViewDataSource
    /////////////////////////////////////////////////////////////////////
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width:CGFloat = (self.view.frame.width - (3 * 24))/2
        let height: CGFloat = 240
        return CGSize(width: width, height: height)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let tab = tabs[indexPath.row]
        let pageLastViewed = tab.pageLastViewed as Page?
        let imageView = cell?.viewWithTag(1) as? UIImageView
        let urlLabel = cell?.viewWithTag(2) as? UILabel
        let deleteButton = cell?.viewWithTag(3) as? UIButton
        
        deleteButton?.isHidden = !deleting
        
        if pageLastViewed != nil {
            let imageData = pageLastViewed?.screenshot.image
            if imageData != nil {
                imageView?.image = UIImage(data: imageData! as Data)
            }
            urlLabel?.text = pageLastViewed?.getDisplayTitle()
        } else {
            imageView?.image = UIImage(named: "empty.png")
            urlLabel?.text = "Empty Tab"
        }
        
        if browserService.setting.currentTab == tab {
            setCellToSelected(cell)
        } else {
            setCellToUnSelected(cell)
        }
        return cell!
    }
    
    /////////////////////////////////////////////////////////////////////
    // MARK: UICollectionViewDelegate
    /////////////////////////////////////////////////////////////////////
    /**
    Handle when a cell is selected.
    */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            
            let cell = collectionView.cellForItem(at: indexPath)
            let tab = tabs[indexPath.row]
            if deleting {
                tabs = try browserService.deleteTabAndFindAll(tab)
                self.collectionView?.reloadData()
            } else {
                dismissing = true
                if try browserService.setCurrentTabWithTab(tab) {
                    setCellToSelected(cell)
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }
        } catch {}
    }
    
    /**
    Specify if the specified item should be highlighted during tracking
    */
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
    Specify if the specified item should be selected
    */
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    /**
    Specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    */
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
