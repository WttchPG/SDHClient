//
//  APIResponse.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/26.
//

import Foundation

struct APIResponse<T: Codable & Equatable> : Codable, Equatable {
    let code: Int
    let message: String?
    let data: T?
    
    static func ==<E: Codable & Equatable>(lhs: APIResponse<E>, rhs: APIResponse<E>) -> Bool {
        return lhs.code == rhs.code && lhs.message == rhs.message && lhs.data == rhs.data
    }
}

class APICodeError: Error {
    let code: Int
    let message: String?
    
    init(code: Int, message: String?) {
        self.code = code
        self.message = message
    }
}
