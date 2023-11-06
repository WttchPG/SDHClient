//
//  LoginService.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation
import Combine

class LoginService: BaseAPIService {
    @Published var jwt: String? = nil
    @Published var userInfo: UserDTO? = nil
    
    private var userInfoCancellable: AnyCancellable? = nil
    
    func userInfo(jwt: String, completion: (() ->())? = nil) {
        userInfoCancellable = self.builder(index: "auth/user", type: UserDTO.self)
            .token(jwt)
//            .serviceErrorAction(code: 401, { msg in
//                print("获取用户信息失败: \(msg)")
//                self.jwtExpired = true
//            })
            .build()
            .sink(receiveCompletion: { fin in
                completion?()
            }, receiveValue: {
                logger.info("获取 user info 成功!")
                self.userInfo = $0
            })
    }
}
