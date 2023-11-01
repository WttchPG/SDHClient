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
    // 服务器词典，包含单词
    @Published var dictionaryWithWord: [WordDictionaryDTO] = []
    
    @Published var localWordDictionaryDTO: [WordDictionaryDTO] = []
    
    // 已经存在的词库
    @Published var exists: [WordDictionaryDTO] = []
    // 需要添加的词库
    @Published var needAdd: [WordDictionaryDTO] = []
    // 需要更新的词库
    @Published var needUpdateLocal: [WordDictionary] = []
    
    @Published var needUpdateMap: [Int: WordDictionaryDTO] = [:]
    
    // 是否正在同步词典
    @Published var syncingDictionary: Bool = false
    // 已经同步完成的词典
    @Published var syncedDictionaryIds: [Int] = []
    
    @Published var syncStateDesc: String = "发现新版本词库..."
    @Published var syncProgress: Float = 0.1
    
    private var service = WordSerivce()
    private var anyCancellables: [AnyCancellable] = []
    
    init() {
        service.$wordDictionaries.sink {
            self.wordDictionaries = $0
        }.store(in: &anyCancellables)
        
        service.$dictionariesWithWords.sink {
            self.dictionaryWithWord = $0
        }.store(in: &anyCancellables)
        
        service.$localWordDictionaries.sink {
            self.localWordDictionaries = $0
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
                
                if self.needAdd.isEmpty && self.needUpdateLocal.isEmpty {
                    self.loadDictionaryDTOs()
                }
            }
            .store(in: &anyCancellables)
    }
    
    /// 下载词库版本
    func loadWordDictionary(jwt: String?) {
        service.loadDictionaryList(jwt: jwt)
    }
    
    /// 下载词库
    func loadDictionaryWithWord(jwt: String?, ids: [Int]) {
        self.syncStateDesc = "开始同步词库..."
        self.syncProgress = 0.2
        service.loadDictionaryWords(jwt: jwt, dictionaryIds: ids) {
            self.syncStateDesc = "词库下载完成。"
            self.syncProgress = 0.25
        }
    }
    
    /// 加载本地词库
    func loadLocalWordDictionary() {
        logger.info("开始加载本地词典...")
        let fetch = NSFetchRequest<WordDictionary>(entityName: "WordDictionary")
        // fetch.predicate = NSPredicate(format: "name == %s", "name")
        
        self.localWordDictionaries = CoreDataManager.fetch(fetch)
        logger.info("加载本地词典成功!")
    }
    
    /// 同步词典到本地
    func syncDictionary() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.syncStateDesc = "正在同步到本地..."
            self.syncProgress = 0.3
            
            let total = self.needAdd.count + self.needUpdateLocal.count
            let syncConut = 0
            
            let serverDictionaryMap = self.dictionaryWithWord.toMap(keyMapper: { $0.id }, valueMapper: { $0 })
            
            for local in self.needUpdateLocal {
                CoreDataManager.delete(local)
                if let serverDictionary = serverDictionaryMap[Int(local.id)] {
                    serverDictionary.toCoreData(context: CoreDataManager.instance.context)
                    logger.info("已同步词库[\(serverDictionary.name)][\(serverDictionary.count)]个单词...")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(syncConut) * 0.2, execute: {
                        self.syncProgress = 0.3 + Float(syncConut) / Float(total) * 0.7
                        self.syncStateDesc = "已同步 \(syncConut)/\(total) 个词库..."
                    })
                } else {
                    logger.warning("未从服务器获取到词库[\(local.name ?? "\(local.id)")], 直接删除...")
                }
                CoreDataManager.save()
            }
            
            for add in self.needAdd {
                serverDictionaryMap[add.id]?.toCoreData(context: CoreDataManager.instance.context)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(syncConut) * 0.2, execute: {
                    self.syncProgress = 0.3 + Float(syncConut) / Float(total) * 0.7
                    self.syncStateDesc = "已同步 \(syncConut)/\(total) 个词库..."
                })
                logger.info("已添加词库[\(add.name)][\(add.count)]个单词...")
                
                CoreDataManager.save()
            }
            
            self.loadDictionaryDTOs()
            self.syncingDictionary = false
        })
    }
    
    func loadDictionaryDTOs() {
        // 读取本地词库
        let fetch = NSFetchRequest<WordDictionary>(entityName: "WordDictionary")
//        
//        CoreDataManager.fetch(fetch).map{ CoreDataManager.delete($0)}
//        CoreDataManager.save()
        
        self.localWordDictionaryDTO = CoreDataManager.fetch(fetch).map({ WordDictionaryDTO(dictionary: $0) })
    }
}
