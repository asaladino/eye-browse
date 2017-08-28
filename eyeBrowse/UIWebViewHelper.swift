//
//  UIWebViewProgressView.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/15/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import WebKit


class UIWebViewHelper: NSObject {

    var delegate: UIWebViewHelperDelegate?
    var webview: WKWebView!
    var progress: Float = 0.0
    var timer: Timer!
    
    var finishedLoading = false
    var loadingRunning = false
    
    
    func startLoadProgress() {
        if !loadingRunning {
            loadingRunning = true
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(UIWebViewHelper.watchLoadProgress), userInfo: nil, repeats: true)
            finishedLoading = false
            progress = 0.0
            updateProgress()
        }
    }
    
    func watchLoadProgress() {
        if (finishedLoading) {
            if (progress >= 1) {
                updateProgress()
                let blockSelf = self
                DispatchQueue.main.async {
                    if blockSelf.timer != nil {
                        blockSelf.timer.invalidate()
                        blockSelf.timer = nil;
                        blockSelf.loadingRunning = false
                    }
                }
            }
            else {
                progress = Float(webview.estimatedProgress)
                updateProgress()
            }
        }
        else {
            progress = Float(webview.estimatedProgress)
            if (progress >= 0.95) {
                updateProgress()
            }
        }
    }
    
    func updateProgress() {
        self.delegate?.webviewHelperProgressUpdated(self.progress)
    }
    
    
    
    /**
    Get the base file path as url

    :returns: the url for base file.
    */
    func baseUrlFilePath() -> URL {
        let path = Bundle.main.resourcePath!
        return URL(fileURLWithPath:path)
    }
    
    /**
    Get a resource contents as a string.

    :param: resource name
    :returns: the contents of the resource.
    */
    func getResourceContents(_ resource:String) -> String {
        let resourcePath = "\(Bundle.main.resourcePath!)/\(resource)"
        do {
            return try String(contentsOfFile: resourcePath, encoding:String.Encoding.utf8)
        } catch {
            return ""
        }
    }
    
    /**
    Get a screenshot of the UIWebView.
    
    :returns: the UIImage as NSData
    */
    func screenshot() -> Data? {
        UIGraphicsBeginImageContextWithOptions(webview.frame.size, false, 0);
        webview.scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(image!)
    }
}
