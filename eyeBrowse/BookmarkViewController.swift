//
//  BookmarkViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/14/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

class BookmarkViewController: UIViewController {

    @IBOutlet weak var bookmarkName: UITextField!
    @IBOutlet weak var bookmarkUrl: UITextField!
    
    var page: Page!
    var bookmark: Bookmark!
    
    var coreDataBookmarksRepository: CoreDataBookmarksRepository!
    var coreDataPagesRepository: CoreDataPagesRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        coreDataBookmarksRepository = CoreDataBookmarksRepository(managedContext: appDelegate.managedObjectContext!)
        coreDataPagesRepository = CoreDataPagesRepository(managedContext: appDelegate.managedObjectContext!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if bookmark != nil {
            bookmarkName.text = bookmark.name
            bookmarkUrl.text = bookmark.page.url
        } else {
            bookmarkName.text = page.title
            bookmarkUrl.text = page.url
        }
    }
    
    @IBAction func dismissBookmark(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBookmark(_ sender: AnyObject) {
        if bookmark == nil {
            bookmark = coreDataBookmarksRepository.create()
        }
        bookmark.name = bookmarkName.text!
        bookmark.page = coreDataPagesRepository.duplicate(page)
        bookmark.page.url = bookmarkUrl.text!
        dismiss(animated: true, completion: nil)
    }
}
