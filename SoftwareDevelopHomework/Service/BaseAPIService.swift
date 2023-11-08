//
//  BaseAPIService.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation
import Combine
import SwiftUI


class BaseAPIService {
    // 请求的 host
    public static let HOST = "http://localhost:8080"
    
    func builder<T: Codable> (index: String, type: T.Type) -> APIRequestBuilder<T> {
        return APIRequestBuilder(index: index, type: type)
    }
}

