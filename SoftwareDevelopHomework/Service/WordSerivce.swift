//
//  WordSerivce.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation
import Combine
import CoreData

class WordSerivce: BaseAPIService {
    // 词典不包含单词
    @Published var wordDictionaries: [WordDictionaryDTO] = []
    // 词典并包含词典所有单词
    @Published var dictionariesWithWords: [WordDictionaryDTO] = []
    // 本地词库
    @Published var localWordDictionaries: [WordDictionary] = []
    
    private var dictionaryListRequest: AnyCancellable? = nil
    private var dictionaryWordRequest: AnyCancellable? = nil
    
    /// 从服务器下载词库信息，不包含单词。
    ///
    /// 用于判断本地和服务器的版本差距。
    ///
    /// - Parameters:
    ///   - jwt: jwt token
    ///   - completion: 请求完成回调函数
    func loadDictionaryList(jwt: String?, completion: (() -> ())? = nil) {
        logger.debug("开始下载词典列表...")
        self.dictionaryListRequest = self.builder(index: "word-dictionary/list", type: [WordDictionaryDTO].self)
            .token(jwt)
            .build()
            .sink { _ in
                // 下载完成
                completion?()
                logger.debug("下载词典列表完成.")
            } receiveValue: { data in
                if !data.isEmpty {
                    self.wordDictionaries = data
                }
            }
    }
    
    /// 下载词典和单词数据。
    /// - Parameters:
    ///   - jwt: jwt token
    ///   - dictionaryIds: 词典 id 数组
    ///   - completion: 下载完成回调函数
    func loadDictionaryWords(jwt: String?, dictionaryIds: [Int], completion: (() -> ())? = nil) {
        logger.debug("开始下载词典和单词数据...")
        self.dictionaryWordRequest = self.builder(index: "word-dictionary/words", type: [WordDictionaryDTO].self)
            .data([
                "ids": dictionaryIds
            ])
            .token(jwt)
            .build()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                completion?()
                logger.debug("下载词典和单词数据完成.")
            }, receiveValue: {
                self.dictionariesWithWords = $0
            })
    }
        
    func loadLocalWordDictionary() {
        logger.info("开始加载本地词典...")
        let fetch = NSFetchRequest<WordDictionary>(entityName: "WordDictionary")
        // fetch.predicate = NSPredicate(format: "name == %s", "name")
        
        self.localWordDictionaries = CoreDataManager.fetch(fetch)
        logger.info("加载本地词典成功!")
    }
}
