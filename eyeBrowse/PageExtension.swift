//
//  PageExtension.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/7/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

extension Page {
    
    func getDisplayUrl() -> String {
        let value: AnyObject? = self.value(forKey: "urlFinal") as AnyObject
        if value != nil {
            return urlFinal
        }
        return url
    }
    
    func getDisplayTitle() -> String {
        let value: AnyObject? = self.value(forKey: "title") as AnyObject
        if value != nil {
            return title
        }
        return getDisplayUrl()
    }
    
    func getSearchType() -> String {
        return "https://duckduckgo.com/?q="
    }
    
    func regexUrl() -> String {
        return "^(?:(?:https?|ftp)://)(?:\\S+(?::\\S*)?@)?(?:(?!10(?:\\.\\d{1,3}){3})(?!127(?:\\.\\d{1,3}){3})(?!169\\.254(?:\\.\\d{1,3}){2})(?!192\\.168(?:\\.\\d{1,3}){2})(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\x{00a1}-\\x{ffff}0-9]+-?)*[a-z\\x{00a1}-\\x{ffff}0-9]+)(?:\\.(?:[a-z\\x{00a1}-\\x{ffff}0-9]+-?)*[a-z\\x{00a1}-\\x{ffff}0-9]+)*(?:\\.(?:[a-z\\x{00a1}-\\x{ffff}]{2,})))(?::\\d{2,5})?(?:/[^\\s]*)?$"
    }
    
    func regexProtocol() -> String {
        return "(http://|https://|ftp://)"
    }
    
    func regexDomain() -> String {
        return "([^\\/]+)"
    }
    
    func urlRequest() -> URLRequest {
        return URLRequest(url: URL(string: url)!)
    }
    
    func breakUpUrl() {
        if !Regex(regexUrl()).test(url) {
            let termEscaped = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            url = "\(getSearchType())\(termEscaped!)"
        }
        urlProtocol = Regex(regexProtocol()).matches(url)
        
        let urlWithOutProtocol = url.replacingOccurrences(of: urlProtocol, with: "", options: NSString.CompareOptions.literal, range: nil)
        urlDomain = Regex(regexDomain()).matches(urlWithOutProtocol)
        
        urlUri = urlWithOutProtocol.replacingOccurrences(of: urlDomain, with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
}
