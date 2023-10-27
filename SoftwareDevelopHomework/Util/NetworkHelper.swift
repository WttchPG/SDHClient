//
//  NetworkHelper.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/26.
//

import Foundation
import Combine

class NetworkHelper {
    static let applicationJsonUtf8 = "application/json; charset=utf-8"
    
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
}
