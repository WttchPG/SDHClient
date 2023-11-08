//
//  APIRequestBuilder.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/8.
//

import Foundation
import Combine

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
    init(index: String, type: T.Type) {
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
