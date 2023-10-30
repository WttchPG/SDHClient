//
//  Windows.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/29.
//

import Foundation
import SwiftUI

enum Windows : String {
    case login
    case main
}


func loginWindow() -> some Scene {
    return Window(Text("登录"), id: Windows.login.rawValue, content: {
        LoginView()
            .frame(width: 400, height: 500)
    })
    .windowStyle(.hiddenTitleBar)
    .windowResizability(.contentSize)
}

func mainWindow() -> some Scene {
    return WindowGroup(id: Windows.main.rawValue, for: UserDTO.self) { userInfo in
        if let userInfo = userInfo.wrappedValue {
            MainView(userInfo: userInfo)
        } else {
            Text("错误! 没有用户信息！")
        }
    }
    .windowStyle(.hiddenTitleBar)
}

extension DismissWindowAction {
    func callAsFunction(window: Windows) {
        self.callAsFunction(id: window.rawValue)
    }
}

extension OpenWindowAction {
    func callAsFunction<D: Codable & Hashable>(window: Windows, data: D) {
        self.callAsFunction(id: window.rawValue, value: data)
    }
}
