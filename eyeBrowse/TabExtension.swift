//
//  SettingExtension.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/14/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

extension Tab {
    
    func addPage(_ page:Page) {
        let pagez = self.mutableSetValue(forKey: "pages")
        pagez.add(page)
    }

}
