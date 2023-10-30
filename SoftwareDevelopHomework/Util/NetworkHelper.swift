//
//  NetworkHelper.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/26.
//

import Foundation
import Combine

/// api 网路请求
class NetworkHelper {
    static let applicationJsonUtf8 = "application/json; charset=utf-8"
    
    
    static func post<T: Codable>(url urlStr: String, data: (any Encodable)?, type: T.Type, bearerToken: String?) -> AnyPublisher<T?, Error> {
        let requestPublisher = PassthroughSubject<T?, Error>()
        
        guard let url = URL(string: urlStr) else {
            // 拼接 url 出现问题，延迟后发送错误消息
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2, execute: {
                requestPublisher.send(completion: .failure(Errors.networkError(msg: "请求url错误:\(urlStr)")))
            })
            
            return requestPublisher
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setContentType(applicationJsonUtf8)
        urlRequest.setAccept(applicationJsonUtf8)
        urlRequest.httpMethod = "POST"
        
        // json 请求体
        if let data = data {
            urlRequest.httpBody = try? JSONEncoder().encode(data)
        }
        
        // token
        if let token = bearerToken {
            urlRequest.setBearerAuthorization(token)
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            // http 请求所在的线程
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap({ output in
                guard let resp = output.response as? HTTPURLResponse else {
                    throw Errors.networkError(msg: "\(url): url response 为空!")
                }
                let statusCode = resp.statusCode
                guard statusCode >= 200 && statusCode < 300 else {
                    throw Errors.badResponse(code: statusCode)
                }
                
                return output.data
            })
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .tryMap{
                guard $0.code == 200 else {
                    throw Errors.serviceError(msg: $0.message)
                }
                
                return $0.data
            }
            .eraseToAnyPublisher()
    }
    
    static func requestAPI<T: Codable & Equatable, D: Encodable>(
        url: URL, type: T.Type, data: D, method: String = "POST") -> AnyPublisher<T?, Error> {
        var urlRequest = URLRequest(url: url)
        urlRequest.setContentType(applicationJsonUtf8)
        urlRequest.setAccept(applicationJsonUtf8)
        urlRequest.httpMethod = method
        urlRequest.httpBody = try? JSONEncoder().encode(data)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            // http 请求所在的线程
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap({ output in
                guard let resp = output.response as? HTTPURLResponse else {
                    throw Errors.networkError(msg: "\(url): url response 为空!")
                }
                let statusCode = resp.statusCode
                guard statusCode >= 200 && statusCode < 300 else {
                    throw Errors.badResponse(code: statusCode)
                }
                
                return output.data
            })
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .tryMap{
                guard $0.code == 200 else {
                    throw Errors.serviceError(msg: $0.message)
                }
                
                return $0.data
            }
            .eraseToAnyPublisher()
    }
}

extension URLRequest {
    mutating func setContentType(_ contentType: String) {
        self.setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    
    mutating func setAccept(_ contentType: String) {
        self.setValue(contentType, forHTTPHeaderField: "Accept")
    }
    
    /// 在 header 中添加 token。
    ///
    /// "Authorization": "Bearer xxxxxxxxx"
    ///
    /// - Parameter token: jwt token
    mutating func setBearerAuthorization(_ token: String) {
        self.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
