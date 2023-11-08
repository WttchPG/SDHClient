//
//  APIPublisher.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/8.
//

import Foundation
import Combine
import SwiftUI


///
/// API 的升级版，需要放在 ObservableObject 中，作为 ObservableObject 的属性。
///
@propertyWrapper
struct APIPublisher<T: Codable>: DynamicProperty {
    private let index: String
    // 实际数据保存的实体
    private let storage: Storage
    // 包裹的值，实际上的 get、set 是有 static subscript 方法进行赋值和获取的
    var wrappedValue: T {
        get {
            return storage.data
        }
        nonmutating set {
            storage.data = newValue
        }
    }
    // 连接外围 ObservableObject，当 storage 中 objectWillChange 改变时，通知外围 ObservableObject
    private var anyCancellable: AnyCancellable? = nil
    
    init(wrappedValue : T, _ index: String) {
        self.index = index
        self.storage = Storage(wrappedValue, index: index)
        self.wrappedValue = wrappedValue
    }
    
    var projectedValue: Storage {
        return storage
    }
    
    class Storage: ObservableObject {
        // 是否正在执行中
        @Published var running: Bool
        // 实际数据
        @Published var data: T
        // 完成请求的 Publisher 不管是否正确完成
        let completionPublisher = PassthroughSubject<Void, Never>()
        // 请求错误的 Publisher
        let errorPublisher = PassthroughSubject<Error, Never>()
        
        // 请求地址
        private let index: String
        // 请求的
        private var anyCancellable: AnyCancellable? = nil
        
        init(_ data: T, index: String) {
            self.data = data
            self.index = index
            self.running = false
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
                        self.completionPublisher.send()
                    }
                } receiveValue: { data in
                    self.data = data
                }

        }
        
        
        func builder (index: String, type: T.Type) -> APIRequestBuilder<T> {
            return APIRequestBuilder(index: index, type: type)
        }
    }
    
    
    public static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance observed: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> T where OuterSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        get {
            if observed[keyPath: storageKeyPath].anyCancellable == nil {
                // 只会执行一次,将实际对象在的对象 交给 保存的 propertyWrapper 的实际对象，进行 objectWillChange 进行连接
                observed[keyPath: storageKeyPath].setup(observed)
            }
            return observed[keyPath: storageKeyPath].wrappedValue
        }
        set {
            // 发送事件告知 UI 刷新
            observed.objectWillChange.send()
            observed[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
    
    // 订阅 wrappedvalue 的 objectWillChange
    // 每当 wrappedValue 发送通知时，调用 _enclosingInstance 的 objectWillChange.send。
    // 使用闭包对 _enclosingInstance 进行弱引用
    private mutating func setup<OuterSelf: ObservableObject>(_ enclosingInstance: OuterSelf) where OuterSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        anyCancellable = storage.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak enclosingInstance] _ in
                (enclosingInstance?.objectWillChange)?.send()
            })
    }
}


