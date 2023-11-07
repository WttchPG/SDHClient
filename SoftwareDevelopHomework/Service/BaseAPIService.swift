//
//  BaseAPIService.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation
import Combine
import SwiftUI

/// API 请求构建器
class APIRequestBuilder<T: Codable> {
    // api 路径
    private let index: String
    // 请求方法
    private var httpMethod: String?
    // 请求数据
    private var data: (any Encodable)?
    // 请求 token
    private var token: String?
    // 延迟一点
    private var delay: Float?
    
    /// 创建 API 请求构造器
    /// - Parameters:
    ///   - index: api 路径
    ///   - type: 返回数据类型
    fileprivate init(index: String, type: T.Type) {
        self.index = index
    }
    
    /// 设置 http 请求方法
    /// - Parameter method: 请求方法
    /// - Returns: 自身，方便链式调用
    func httpMethod(_ method: String) -> APIRequestBuilder<T> {
        self.httpMethod = method
        return self
    }
    
    /// 设置请求体数据，json body
    /// - Parameter data: 请求数据
    /// - Returns: 自身，方便链式调用
    func data(_ data: (any Encodable)?) -> APIRequestBuilder<T> {
        if let data = data {
            self.data = data
        }
        return self
    }
    
    /// 设置请求 token
    /// - Parameter token: 请求 token
    /// - Returns: 自身，方便链式调用
    func token(_ token: String?) -> APIRequestBuilder<T> {
        if let token = token {
            self.token = token
        }
        return self
    }
    
    func delay(_ delay: Float?) -> APIRequestBuilder<T> {
        self.delay = delay
        return self
    }
    
    
    func build() -> AnyPublisher<T, ServiceError> {
        let url = "\(BaseAPIService.HOST)/\(index)"
        
        return NetworkHelper.request(url: url, data: data, type: APIResponse<T>.self, httpMethod: self.httpMethod ?? "POST", bearerToken: token)
            .delay(for: .seconds(Double(delay ?? 0)), scheduler: DispatchQueue.main)
            // 统一错误映射
            .mapError(self.mapErrorRequest2Service)
            .tryMap{ resp in
                // api 服务逻辑错误
                guard resp.code == 200 else {
                    throw ServiceError.serviceError(code: resp.code, msg: resp.message)
                }
                
                // 服务逻辑正确，data 必不为空
                if let data = resp.data {
                    return data
                } else {
                    throw ServiceError.dataNil
                }
            }
            .mapError{ $0 as! ServiceError }
            .eraseToAnyPublisher()
    }
    
    
    /// 映射 http 请求错误到 ServiceError。
    /// - Parameter error: http 请求中可能出现的错误
    /// - Returns: 转换后的 ServiceError
    private func mapErrorRequest2Service(_ error: Error) -> ServiceError {
        // 错误处理为 ServiceError, 此处之前不会出现 ServiceError
        if let error = error as? NetworkError {
            return error.toServiceError()
        }
        return ServiceError.unknown(error: error)
    }
}

class BaseAPIService {
    // 请求的 host
    public static let HOST = "http://localhost:8080"
    
    // 请求 401 Publisher
    public static let service401Publisher: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    
    // 包装的错误，可以直接交给弹窗管理器进行弹窗错误提示
    @Published var alertMessage: AlertMessage? = nil
    
    func builder<T: Codable> (index: String, type: T.Type) -> APIRequestBuilder<T> {
        return APIRequestBuilder(index: index, type: type)
    }
}

extension View {
    func on401(_ action: @escaping (String) -> Void) -> some View {
        return self.onReceive(BaseAPIService.service401Publisher, perform: { msg in
            action(msg)
        })
    }
}



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

extension PassthroughSubject where Output == Error, Failure == Never {
    func catchServiceCode(_ listenCode: Int) -> AnyPublisher<AlertMessage, Never> {
        return self
            .map { error in
                guard let error = error as? ServiceError, case .serviceError(let code, let msg) = error else {
                    return nil
                }
                if code == listenCode {
                    return AlertMessage(type: .warning, message: msg)
                }
                
                return nil
            }
            .filter {
                $0 != nil
            }.map {
                $0!
            }.eraseToAnyPublisher()
    }
}

