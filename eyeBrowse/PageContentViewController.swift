//
//  Test2ViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/5/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import WebKit

/**
WebKit Help
https://github.com/ShingoFukuyama/WKWebViewTips
http://nshipster.com/wkwebkit/

For desktop version:
http://breach.cc/
*/

class PageContentViewController: UIViewController, WKNavigationDelegate, UIWebViewHelperDelegate {
    
    @IBOutlet var loadingProgress: UIProgressView!
    @IBOutlet weak var webContainer: UIView!
    var webview: WKWebView = WKWebView()
    
    var webviewHelper = UIWebViewHelper()
    var browserViewController: BrowserViewController!
    
    var page:Page?
    
    var isShowingLandscapeView = false
    var updatePageDate = true
    
    var coreDataHelpers = CoreDataHelpers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.autoresizingMask = webContainer.autoresizingMask
        
        webContainer.addSubview(webview)
        //orientationChanged()
        
        webview.navigationDelegate = self
        webviewHelper.delegate = self
        webviewHelper.webview = webview
        webview.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        browserViewController.updateNavigationToPage(page)
    }
    
    func loadPageWithoutUpdate(_ page: Page?){
        updatePageDate = false
        loadPage(page)
    }
    
    func loadPage(_ page: Page?) {
        if self.page != page {
            self.page = page
            navigateToUrl()
        }
    }
    
    func navigateToUrl() {
        browserViewController.disableNavigation()
        if page != nil {
            webviewHelper.startLoadProgress()
            webview.load(page!.urlRequest() as URLRequest)
        } else {
            webview.loadHTMLString(webviewHelper.getResourceContents("start.html"), baseURL: webviewHelper.baseUrlFilePath())
        }
    }
    
    func canNavigateToUrl(_ navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        /*
        let url = NSURL(string: "http://www.stackoverflow.com")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        */
    }
    
    func webviewHelperProgressUpdated(_ progress: Float) {
        loadingProgress.progress = progress
    }
    
    /**
    * WebView Delegate implementation.
    */
    
    
    
    /*! @abstract Decides whether to allow or cancel a navigation.
    @param webView The web view invoking the delegate method.
    @param navigationAction Descriptive information about the action
    triggering the navigation request.
    @param decisionHandler The decision handler to call to allow or cancel the
    navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
    @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
    */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("1")
        if navigationAction.navigationType.rawValue > -1 && !updatePageDate {
            //updatePageDate = true
        }
        print("*******Request type: \(navigationAction.navigationType.rawValue)")
        let headers = navigationAction.request.allHTTPHeaderFields as [AnyHashable: Any]!
        for header in headers! {
            print("----------Header: \(header)")
        }
        canNavigateToUrl(navigationAction, decisionHandler: decisionHandler)
    }
    
    /*! @abstract Decides whether to allow or cancel a navigation after its
    response is known.
    @param webView The web view invoking the delegate method.
    @param navigationResponse Descriptive information about the navigation
    response.
    @param decisionHandler The decision handler to call to allow or cancel the
    navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
    @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
    */
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("2")
        print("mime type: \(String(describing: navigationResponse.response.mimeType))")
        /*let headers = navigationResponse.response.MIMEType as [NSObject: AnyObject]!
        for header in headers {
            println("----------Header: \(header)")
        }*/
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    /*! @abstract Invoked when a main frame navigation starts.
    @param webView The web view invoking the delegate method.
    @param navigation The navigation.
    */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("3")
    }
    
    /*! @abstract Invoked when a server redirect is received for the main
    frame.
    @param webView The web view invoking the delegate method.
    @param navigation The navigation.
    */
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("4")
    }
    
    /*! @abstract Invoked when an error occurs while starting to load data for
    the main frame.
    @param webView The web view invoking the delegate method.
    @param navigation The navigation.
    @param error The error that occurred.
    */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("5")
    }
    
    /*! @abstract Invoked when content starts arriving for the main frame.
    @param webView The web view invoking the delegate method.
    @param navigation The navigation.
    */
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("6")
    }
    
    /*! @abstract Invoked when a main frame navigation completes.
    @param webView The web view invoking the delegate method.
    @param navigation The navigation.
    */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        page = browserViewController.pageFromUrl(webView.url!.absoluteString)
        
        print("*****final \(webView.estimatedProgress) URL: \(webView.url!.absoluteString)")
        if updatePageDate {
            page?.created = Date()
        } else {
            updatePageDate = true
        }
        
        page?.urlFinal = webView.url!.absoluteString
        page?.title = webView.title!
        page?.screenshot.image = webviewHelper.screenshot()!
        
        do {
            try browserViewController.browserService.coreDataPagesRepository.save()
        } catch {
            print("problem saving to managed object")
        }
        
        browserViewController.updateNavigationToPage(page)
        webviewHelper.finishedLoading = true
    }
    
    /*! @abstract Invoked when an error occurs during a committed main frame
    navigation.
    @param webView The web view invoking the delegate method.
    @param navigation The navigation.
    @param error The error that occurred.
    */
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("8")
        webviewHelper.finishedLoading = true
    }
    
    /*! @abstract Invoked when the web view needs to respond to an authentication challenge.
    @param webView The web view that received the authentication challenge.
    @param challenge The authentication challenge.
    @param completionHandler The completion handler you must invoke to respond to the challenge. The
    disposition argument is one of the constants of the enumerated type
    NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
    the credential argument is the credential to use, or nil to indicate continuing without a
    credential.
    @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
    */
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        
//        print("9")
//    }
   
}
