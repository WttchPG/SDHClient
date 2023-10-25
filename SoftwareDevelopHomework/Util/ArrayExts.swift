//
//  ArrayExts.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/25.
//

import Foundation


extension Array where Element: Identifiable {
    
    func toMap() -> [Element.ID: Element] {
        return [:]
    }
    
}
