//
//  CoreDataHelpers.swift
//  eEvents
//
//  Created by Adam Saladino on 12/2/14.
//  Copyright (c) 2014 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelpers: NSObject {
    
    let formatterDate = DateFormatter()
    let formatterTime = DateFormatter()
    
    let htmlEntities: [String: String] = [
        "&#8211;": "\"",
        "&#8212;": "'",
        "&#8217;": "'"
    ]
    
    override init() {
        formatterDate.dateFormat = "EEE, MMM d, yyyy"
        formatterTime.dateFormat = "hh:mm aaa"
    }
    
    func pr(_ item:NSManagedObject) {
        for attribute in item.entity.attributesByName {
            let value: AnyObject? = item.value(forKey: attribute.0 as String) as AnyObject
            print("attribute \(attribute.0 as String) = \(value!)")
        }
    }
    
    func valueOrEmptyString(_ item:NSManagedObject, field: String) -> String {
        let value: AnyObject? = item.value(forKey: field) as AnyObject
        if value == nil {
            return ""
        }
        return value as! String
    }
    
    func encodeHtmlEntities(_ encodedString:String) -> String? {
        var decode = encodedString
        for (htmlEntity, value) in htmlEntities {
            decode = decode.replacingOccurrences(of: htmlEntity,
                with: value,
                options: NSString.CompareOptions.literal,
                range: nil)
        }
        return decode
    }
    
    func encodeHtmlEntitiesAlt(_ encodedString:String) -> String? {
        let encodedData = encodedString.data(using: String.Encoding.utf8)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        print("--")
        print(encodedString)
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            return attributedString.string
        } catch {
            return nil
        }
    }
    
    func dateAtBeginningOfDayForDate(_ inputDate:Date) -> Date {
        // Use the user's current calendar and time zone
        var calendar = Calendar.current
        let timeZone = TimeZone.current
        calendar.timeZone = timeZone
        
        var dateComps = calendar.dateComponents(in: .current, from: inputDate)
        
        // Set the time components manually
        dateComps.hour = 0
        dateComps.minute = 0
        dateComps.second = 0
        return calendar.date(from: dateComps)!
    }
    
    func dateByAddingYears(_ numberOfYears:NSInteger, toDate inputDate:Date) -> Date {
        // Use the user's current calendar
        let calendar = Calendar.current
        var dateComps = DateComponents()
        dateComps.year = numberOfYears
        return calendar.date(byAdding: dateComps, to: inputDate)!
    }
}
