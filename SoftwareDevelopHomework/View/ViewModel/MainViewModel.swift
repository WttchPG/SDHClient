//
//  MainViewModel.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation
import Combine
import CoreData

class MainViewModel: ObservableObject {
    // 服务器最新的词库信息
    @Published var wordDictionaries: [WordDictionaryDTO] = []
    // 本地词库
    @Published var localWordDictionaries: [WordDictionary] = []
    
    // 已经存在的词库
    @Published var exists: [WordDictionaryDTO] = []
    // 需要添加的词库
    @Published var needAdd: [WordDictionaryDTO] = []
    // 需要更新的词库
    @Published var needUpdateLocal: [WordDictionary] = []
    
    @Published var needUpdateMap: [Int: WordDictionaryDTO] = [:]
    
    private var service = WordSerivce()
    private var anyCancellables: [AnyCancellable] = []
    
    init() {
        service.$wordDictionaries.sink {
            self.wordDictionaries = $0
            logger.info("词典列表加载完成!")
        }.store(in: &anyCancellables)
        
        self.$wordDictionaries.combineLatest(self.$localWordDictionaries)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { wordDictionaries, localWordDictionaries in
                logger.info("开始比对网络/本地词库...")
                
                if wordDictionaries.isEmpty {
                    logger.warning("网络库为空，跳过!")
                    return
                }
                
                self.exists = []
                self.needAdd = []
                self.needUpdateLocal = []
                self.needUpdateMap = [:]
                for dictionary in wordDictionaries {
                    var exist = false
                    for localDictionary in localWordDictionaries {
                        if dictionary.id == localDictionary.id {
                            // 相同 id
                            if dictionary.lastVersion == localDictionary.lastVersion {
                                // 相同版本
                                self.exists.append(dictionary)
                            } else {
                                // 不同版本
                                self.needUpdateLocal.append(localDictionary)
                                self.needUpdateMap[dictionary.id] = dictionary
                            }
                            exist = true
                            break
                        }
                    }
                    if !exist {
                        // 不存在
                        self.needAdd.append(dictionary)
                    }
                }
                let total = self.exists.count + self.needAdd.count + self.needUpdateLocal.count
                logger.info("比对结束，有 \(self.needAdd.count)/\(total) 个词库需要添加，\(self.needUpdateLocal.count)/\(total) 个词库需要同步!")
            }
            .store(in: &anyCancellables)
    }
    
    func loadWordDictionary(jwt: String) {
        logger.info("开始加载词典列表...")
        service.dictionaryList(jwt: jwt)
    }
    
    func loadLocalWordDictionary() {
        logger.info("开始加载本地词典...")
        let fetch = NSFetchRequest<WordDictionary>(entityName: "WordDictionary")
        // fetch.predicate = NSPredicate(format: "name == %s", "name")
        
        self.localWordDictionaries = CoreDataManager.fetch(fetch)
        logger.info("加载本地词典成功!")
    }
}
