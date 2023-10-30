//
//  WordDictionaryDTO.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation

struct WordDictionaryDTO: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let system: Int
    let lastVersion: String
    let createBy: Int?
    let count: Int
    let words: [WordDTO]?
}
