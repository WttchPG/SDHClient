//
//  MainView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import SwiftUI

struct MainView: View {
    let userInfo: UserDTO?
    var body: some View {
        if let userInfo = userInfo {
            Text("\(userInfo.realName)")
        }
    }
}

#Preview {
    MainView(userInfo: UserDTO(id: 1, name: "wttch", realName: "王冲", tel: "187xxxx9458", email: "wttch@wttch.com"))
}
