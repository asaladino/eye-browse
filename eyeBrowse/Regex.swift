//
//  Regex.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/17/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

class Regex: NSObject {
    var internalExpression: NSRegularExpression?
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        do {
            internalExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch {}
    }
    
    func test(_ input: String) -> Bool {
        let matches = internalExpression?.matches(in: input, options: .anchored, range:NSMakeRange(0, input.characters.count))
        return matches!.count > 0
    }
    
    func matches(_ input: String) -> String {
        let matches = internalExpression?.matches(in: input, options: .anchored, range:NSMakeRange(0, input.characters.count))
        for match in matches! {
            let stuff = match as NSTextCheckingResult
            let output = (input as NSString).substring(with: stuff.range)
            return output
        }
        return ""
    }
}
