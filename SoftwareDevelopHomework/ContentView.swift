//
//  ContentView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/18.
//

import SwiftUI

struct ContentView: View {
    
    @State private var year: Int = 1999

    private var libraries = ["四级词库", "六级词汇", "生词库"]
    
    @State private var selectLibrary = "四级词库"
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
//        NavigationSplitView(sidebar: {
//            List(libraries, id: \.self, selection: $selectLibrary, rowContent: { library in
//                Text(library)
//            })
//        }, detail: {
//            VStack {
//                Text(selectLibrary)
//                    .font(.largeTitle)
//
//                Spacer()
//            }
//            .navigationTitle(selectLibrary)
//        })
        GeometryReader(content: { geometry in
            VStack(spacing: 24) {
                Spacer()
                HStack {
                    VStack {
                        Text("Every word")
                        Text("counts here")
                    }
                    
                    Spacer()
                }
                .font(.largeTitle)
                .foregroundColor(.white)
                HStack {
                    Text("记住单词，记录改变")
                    Spacer()
                }
                .font(.title)
                .foregroundColor(.white)
                
                TextField("请输入账号", text: $username)
                SecureField("请输入密码", text: $password)
                
                Button("登录") {
                    guard !username.isEmpty && !password.isEmpty else {
                        AlertMessageManager.instance.publisher.send(AlertMessage(type: .warning, message: "账号或密码为空!"))
                        return
                    }
                    var request = URLComponents(string: "http://localhost:8080/auth/login")
                    NetworkHelper.requestAPI(url: request!.url!, type: String.self, data: [
                        "username": username,
                        "password": password
                    ])
                    .sink { fin in
                        switch fin {
                        case.finished:
                            break
                        case .failure(let error):
                            if error is Errors {
                                switch error as! Errors {
                                case .networkError(let msg):
                                    AlertMessageManager.instance.publisher.send(AlertMessage(type: .warning, message: msg ?? "None"))
                                case .badResponse(let code):
                                    AlertMessageManager.instance.publisher.send(AlertMessage(type: .warning, message: "网络请求失败, http code: [\(code)]"))
                                case .serviceError(let msg):
                                    AlertMessageManager.instance.publisher.send(AlertMessage(type: .warning, message: msg ?? "Nono"))
                                }
                                
                                return
                            }
                            
                            AlertMessageManager.instance.publisher.send(AlertMessage(type: .warning, message: error.localizedDescription))
                        }
                    } receiveValue: { data in
                        
                    }
                    
                }
                
                Spacer()
            }
            .background(content: {
                ZStack {
                    Image("login-bg")
                        .resizable()
                        .scaledToFill()
                    
                    Color.black
                        .opacity(0.5)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            })
            .padding(.horizontal, 48)
        })
        
        .ignoresSafeArea(edges: .top)
        .wrapperAlert()
    }
}

#Preview {
    ContentView()
        .presentedWindowStyle(.hiddenTitleBar)
        .ignoresSafeArea(edges: .top)
}
