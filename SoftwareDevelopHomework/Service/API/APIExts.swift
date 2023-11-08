//
//  APIExts.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/8.
//

import Foundation
import Combine


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
