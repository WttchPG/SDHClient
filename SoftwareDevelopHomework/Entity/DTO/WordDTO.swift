//
//  WordDTO.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation
import CoreData

struct WordDTO: Codable, Equatable, Identifiable {
    let id: Int
    // 单词
    let word: String
    // 音标
    let symbol: String
    // 词性
    let adv: String
    // 含义
    let mean: String
    // 是否系统单词
    let system: Int
    
    init(id: Int, word: String, symbol: String, adv: String, mean: String, system: Int) {
        self.id = id
        self.word = word
        self.symbol = symbol
        self.adv = adv
        self.mean = mean
        self.system = system
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.word = try container.decode(String.self, forKey: .word)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.adv = try container.decode(String.self, forKey: .adv)
        self.mean = try container.decode(String.self, forKey: .mean)
        self.system = try container.decode(Int.self, forKey: .system)
    }
    
    init?(from: Word) {
        if let word = from.word, let symbol = from.symbol, let adv = from.adv, let mean = from.mean {
            self.id = Int(from.id)
            self.word = word
            self.symbol = symbol
            self.adv = adv
            self.mean = mean
            self.system = Int(from.system)
        } else {
            return nil
        }
    }
    
    func toWord(_ context: NSManagedObjectContext) -> Word {
        let word = Word(context: context)
        word.id = Int64(self.id)
        word.word = self.word
        word.symbol = self.symbol
        word.adv = self.adv
        word.mean = self.mean
        word.system = Int64(self.system)
        return word
    }
    
    static func ==(lhs: WordDTO, rhs: WordDTO) -> Bool {
        return lhs.id == rhs.id
    }
}
