//
//  APIResponse.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/26.
//

import Foundation

struct APIResponse<T: Codable> : Codable {
    let code: Int
    let message: String
    let data: T?
    
}

class APICodeError: Error {
    let code: Int
    let message: String?
    
    init(code: Int, message: String?) {
        self.code = code
        self.message = message
    }
}
