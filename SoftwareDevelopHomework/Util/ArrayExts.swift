//
//  ArrayExts.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/25.
//

import Foundation


extension Array {
    
    func toMap<Key, Value> (keyMapper: (Element) -> Key, valueMapper: (Element) -> Value) -> [Key: Value] {
        return self.reduce(into: [:] as [Key: Value]) { partialResult, element in
            let key = keyMapper(element)
            let value = valueMapper(element)
            partialResult[key] = value
        }
    }
    
}
