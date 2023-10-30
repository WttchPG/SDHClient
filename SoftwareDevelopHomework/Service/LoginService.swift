//
//  LoginService.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation
import Combine

class LoginService: BaseAPIService {
    @Published var jwt: String?
    @Published var userInfo: UserDTO?
    @Published var jwtExpired: Bool = false
    
    private var loginCancelable: AnyCancellable? = nil
    private var userInfoCancellable: AnyCancellable? = nil
    
    func login(username: String, password: String) {
        loginCancelable = self.builder(index: "auth/login", type: String.self)
            .data([
                "username": username,
                "password": password
            ])
            .build()
            .sink(receiveValue: {
                self.jwt = $0
            })
    }
    
    func userInfo(jwt: String, completion: (() ->())? = nil) {
        userInfoCancellable = self.builder(index: "auth/user", type: UserDTO.self)
            .token(jwt)
            .serviceErrorAction(code: 401, { msg in
                print("获取用户信息失败: \(msg)")
                self.jwtExpired = true
            })
            .build()
            .sink(receiveCompletion: { fin in
                completion?()
            }, receiveValue: {
                self.userInfo = $0
            })
    }
}
