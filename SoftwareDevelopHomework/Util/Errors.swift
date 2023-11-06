//
//  Errors.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/6.
//

import Foundation

///
/// 网络请求错误。
///
enum NetworkError: LocalizedError {
    /// 网络错误
    case networkError(msg: String)
    /// http 请求 code 不为 200
    case badResponse(code: Int)
}


/// API 服务错误
/// TODO 所有请求的 401 都关闭窗口，重新登录
enum ServiceError: LocalizedError {
    /// 未知错误。
    /// - Parameter error: 原始错误
    case unknown(error: Error)
    
    /// 错误的 http 请求。
    /// - Parameter code: http 响应码
    /// - Parameter msg: 错误信息
    case badRequest(code: Int?, msg: String?)
    
    /// api 服务错误。
    /// - Parameter code: api 服务错误响应码
    /// - Parameter msg: 服务器错误信息
    case serviceError(code: Int, msg: String)

    /// api 响应数据为 nil。
    case dataNil
}

extension NetworkError {
    /// 将网络错误转换为 ServiceError
    /// - Returns: 服务错误
    func toServiceError() -> ServiceError {
        switch self {
        case .badResponse(let code):
            return ServiceError.badRequest(code: code, msg: nil)
        case .networkError(let msg):
            return ServiceError.badRequest(code: nil, msg: msg)
        }
    }
}
