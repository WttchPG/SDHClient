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
    
    private var loginCancelable: AnyCancellable? = nil
    private var userInfoCancellable: AnyCancellable? = nil
    
    func login(username: String, password: String) {
        loginCancelable = post(index: "auth/login", data: [
            "username": username,
            "password": password
        ], type: String.self)
        .sink {
            self.jwt = $0
        }
    }
    
    func userInfo(jwt: String) {
        userInfoCancellable = post(index: "auth/user", type: UserDTO.self, token: jwt)
            .sink {
                self.userInfo = $0
            }
    }
}
