//
//  AppStorageKey.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/8.
//

import Foundation
import SwiftUI


public enum AppStorageKey: String {
    case jwt = "jwt"
    case loginUserName = "login_username"
    case loginPassword = "login_password"
}

extension AppStorage {
    public init(_ key: AppStorageKey, store: UserDefaults? = nil) where Value == String? {
        self.init(key.rawValue, store: store)
    }
    
    public init(wrappedValue: Value, _ key: AppStorageKey, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
