//
//  NetworkHelper.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/26.
//

import Foundation
import Combine


/// api 网路请求
/// 只是简单的 http 请求包装，不做太多的错误处理。
class NetworkHelper {
    static let applicationJsonUtf8 = "application/json; charset=utf-8"
    
    
    static func request<T: Codable>(url urlStr: String, data: (any Encodable)?, type: T.Type, httpMethod: String?, bearerToken: String?) -> AnyPublisher<T, Error> {
        let requestPublisher = PassthroughSubject<T, Error>()
        
        guard let url = URL(string: urlStr) else {
            // 拼接 url 出现问题，延迟后发送错误消息
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2, execute: {
                requestPublisher.send(completion: .failure(NetworkError.networkError(msg: "请求url错误:\(urlStr)")))
            })
            
            return requestPublisher
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setContentType(applicationJsonUtf8)
        urlRequest.setAccept(applicationJsonUtf8)
        urlRequest.httpMethod = httpMethod
        
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
                    throw NetworkError.networkError(msg: "\(url): url response 为空!")
                }
                let statusCode = resp.statusCode
                guard statusCode >= 200 && statusCode < 300 else {
                    throw NetworkError.badResponse(code: statusCode)
                }
                
                logger.debug("响应数据: \(String(bytes: output.data, encoding: .utf8) ?? "None")")
                
                return output.data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
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
