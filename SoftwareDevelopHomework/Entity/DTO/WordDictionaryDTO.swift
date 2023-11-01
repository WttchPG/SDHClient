//
//  WordDictionaryDTO.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation
import CoreData

struct WordDictionaryDTO: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let system: Int
    let lastVersion: String
    let createBy: Int?
    let count: Int
    let words: [WordDTO]?
    
    var hashValue: Int { return id.hashValue }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.system = try container.decode(Int.self, forKey: .system)
        self.lastVersion = try container.decode(String.self, forKey: .lastVersion)
        self.createBy = try container.decodeIfPresent(Int.self, forKey: .createBy)
        self.count = try container.decode(Int.self, forKey: .count)
        self.words = try container.decodeIfPresent([WordDTO].self, forKey: .words)
    }
    
    public init(id: Int, name: String, system: Int, lastVersion: String, createBy: Int?, count: Int, words: [WordDTO]?) {
        self.id = id
        self.name = name
        self.system = system
        self.lastVersion = lastVersion
        self.createBy = createBy
        self.count = count
        self.words = words
    }
    
    public init(dictionary: WordDictionary) {
        self.id = Int(dictionary.id)
        self.name = dictionary.name ?? "Unknown"
        self.system = Int(dictionary.system)
        self.lastVersion = dictionary.lastVersion ?? "Unknown"
        self.createBy = Int(dictionary.createBy)
        self.count = Int(dictionary.count)
        if let words = dictionary.words?.allObjects as? [Word] {
            self.words = words.map({ WordDTO(from: $0)! })
        } else {
            self.words = nil
        }
    }
    
    public func toCoreData(context: NSManagedObjectContext) {
        let dictionary = WordDictionary(context: context)
        dictionary.id = Int64(id)
        dictionary.name = name
        dictionary.system = Int64(system)
        dictionary.lastVersion = lastVersion
        if let createBy = createBy {
            dictionary.createBy = Int64(createBy)
        }
        dictionary.count = Int64(count)
        
        if let words = self.words {
            var newWords: [Word] = []
            for wordDTO in words {
                newWords.append(wordDTO.toWord(context))
            }
            dictionary.words = NSSet(array: newWords)
        }
    }
}
