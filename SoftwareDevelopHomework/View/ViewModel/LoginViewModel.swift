//
//  LoginViewModel.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/8.
//

import Foundation


class LoginViewModel: ObservableObject {
    @APIPublisher("auth/login") var jwt: String = ""
    @APIPublisher("auth/user") var userInfo: UserDTO? = nil
}
