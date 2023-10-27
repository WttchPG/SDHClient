//
//  Errors.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation

enum Errors: LocalizedError {
    case networkError(msg: String?)
    
    case badResponse(code: Int)
    
    case serviceError(msg: String?)
}
