//
//  MainView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import SwiftUI

struct MainView: View {
    let userInfo: UserDTO
    
    @AppStorage("jwt") private var storagedJwt: String?
    
    @State private var showExit: Bool = false
    
    @ObservedObject private var vm = MainViewModel()
    // 显示更新的词库面板
    @State var showDictionaryUpdate: Bool = false
    
    init(userInfo: UserDTO) {
        self.userInfo = userInfo
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
//            .background(content: {
//                ZStack {
//                    Image("login-bg")
//                        .resizable()
//                        .scaledToFill()
//                    
//                    Color.black
//                        .opacity(0.5)
//                }
//            })
        })
        .sheet(isPresented: $showDictionaryUpdate, content: {
            VStack {
                ForEach(vm.needAdd, content: {dict in
                    HStack {
                        Text("\(dict.name) 词汇量: \(dict.count)需要添加")
                    }
                })
                ForEach(vm.needUpdateLocal, content: { dict in
                    HStack {
                        Text("\(dict.name ?? "None")需要更新!")
                    }
                })
            }
            .padding()
        })
        .onChange(of: vm.needAdd, { oldValue, newValue in
            self.showDictionaryUpdate = true
        })
        .onChange(of: vm.needUpdateLocal, { oldValue, newValue in
            self.showDictionaryUpdate = true
        })
        .toolbar(content: {
            HStack {
                Image(systemName: "person.circle")
                    .font(.largeTitle)
                    .popover(isPresented: $showExit, arrowEdge: .bottom, content: {
                        HStack {
                            VStack {
                                Text(userInfo.tel)
                                Text(userInfo.email)
                            }
                            Button("登出") {
                                
                            }
                            .buttonStyle(.link)
                        }
                        .padding()
                    })
        
                Text("\(userInfo.realName)(\(userInfo.name))")
                    .font(.title)
            }
            .onTapGesture {
                self.showExit.toggle()
            }
        })
        .onAppear {
            if let jwt = storagedJwt {
                vm.loadWordDictionary(jwt: jwt)
                vm.loadLocalWordDictionary()
            } else {
                // 重新登录
            }
        }
    }
}

#Preview {
    MainView(userInfo: UserDTO(id: 1, name: "wttch", realName: "王冲", tel: "187xxxx9458", email: "wttch@wttch.com"))
}
