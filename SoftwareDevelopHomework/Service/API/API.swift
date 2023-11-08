//
//  API.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/8.
//

import Foundation
import Combine
import SwiftUI

@propertyWrapper
struct API<T: Codable>: DynamicProperty {
    private let index: String
    
    @ObservedObject private var result: RequestResult
    
    var wrappedValue: T {
        get {
            return result.data
        }
        nonmutating set {
            self.result.data = newValue
        }
    }
    
    var projectedValue: RequestResult {
        return result
    }
    
    
    class RequestResult: ObservableObject {
        @Published var running: Bool = false
        @Published var data: T
        let completionPublisher = PassthroughSubject<String, Never>()
        let errorPublisher = PassthroughSubject<Error, Never>()
        
        let index: String
        var anyCancellable: AnyCancellable? = nil
        
        init(_ data: T, index: String) {
            self._data = Published(initialValue: data)
            self.index = index
        }
        
        
        func post(_ data: (any Encodable)? = nil, jwt: String? = nil, delay: Float?=nil) {
            self.running = true
            self.anyCancellable = self.builder(index: index, type: T.self)
                .httpMethod("post")
                .delay(delay)
                .data(data)
                .token(jwt)
                .build()
                .sink { comp in
                    switch comp {
                    case .failure(let error):
                        self.errorPublisher.send(error)
                        fallthrough
                    default:
                        self.running = false
                        self.completionPublisher.send("")
                    }
                } receiveValue: { data in
                    self.data = data
                }

        }
        
        
        func builder (index: String, type: T.Type) -> APIRequestBuilder<T> {
            return APIRequestBuilder(index: index, type: type)
        }
    }
}

extension API {
    init(wrappedValue : T, _ index: String) {
        self.index = index
        self._result = ObservedObject(wrappedValue: RequestResult(wrappedValue, index: index))
    }
}
