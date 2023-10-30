//
//  WordSerivce.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation
import Combine

class WordSerivce: BaseAPIService {
    @Published var wordDictionaries: [WordDictionaryDTO] = []
    
    private var dictionaryListRequest: AnyCancellable? = nil
    
    func dictionaryList(jwt: String, completion: (() -> ())? = nil) {
        self.dictionaryListRequest = self.builder(index: "word-dictionary/list", type: [WordDictionaryDTO].self)
            .token(jwt)
            .build()
            .sink { _ in
                // 下载完成
                completion?()
            } receiveValue: { data in
                if let data = data, !data.isEmpty {
                    self.wordDictionaries = data
                }
            }
    }
}
