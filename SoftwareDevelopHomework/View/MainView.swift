//
//  MainView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import SwiftUI

struct MainView: View {
    // 打开关闭窗口
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    let userInfo: UserDTO
    
    @AppStorage("jwt") private var storagedJwt: String?
    
    @State private var showExit: Bool = false
    
    @ObservedObject private var vm = MainViewModel()
    // 显示更新的词库面板
    @State var showDictionaryUpdate: Bool = false
    @State var selectionDictionary: WordDictionaryDTO? = nil
    @State var showDictionarySelector: Bool = false
    
    init(userInfo: UserDTO) {
        self.userInfo = userInfo
    }
    
    var body: some View {
    
        VStack {
            if let words: [WordDTO] = selectionDictionary?.words {
                List(words) { word in
                    DictionaryWordListWordView(word: word)
                }
//                    .scrollContentBackground(.hidden)
//                    .colorScheme(.light)
//                    .tableStyle(InsetTableStyle())
            }
            if showDictionaryUpdate {
                Spacer()
                
                HStack {
                    Text("\(vm.syncStateDesc)")
                    ProgressView(value: vm.syncProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                .frame(height: 24)
                .padding(.horizontal, 24)
                .background(Color.black.opacity(0.6))
                .onAppear {
                    let needAddIds = vm.needAdd.map { $0.id }
                    vm.loadDictionaryWithWord(jwt: storagedJwt, ids: needAddIds)
                }
                .onChange(of: vm.dictionaryWithWord) { _, newValue in
                    vm.syncDictionary()
                }
            }
        }
        .navigationTitle(selectionDictionary?.name ?? "")
        .onChange(of: vm.needAdd, { oldValue, newValue in
            self.showDictionaryUpdate = true
        })
        .onChange(of: vm.needUpdateLocal, { oldValue, newValue in
            self.showDictionaryUpdate = true
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigation, content: {
                Button(action: {
                    self.showDictionarySelector.toggle()
                }, label: {
                    Image(systemName: "arrow.left.arrow.right.square")
                })
                .popover(isPresented: $showDictionarySelector, arrowEdge: .bottom, content: {
                    VStack(spacing: 12) {
                        ForEach(vm.localWordDictionaryDTO) { dictionary in
                            Text(dictionary.name)
                                .onTapGesture {
                                    self.selectionDictionary = dictionary
                                    self.showDictionarySelector = false
                                }
                        }
                    }
                    .padding()
                })
            })
        })
        .toolbar(content: {
            ToolbarItemGroup(content: {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .popover(isPresented: $showExit, arrowEdge: .bottom, content: {
                            HStack {
                                VStack {
                                    Text(userInfo.tel)
                                    Text(userInfo.email)
                                }
                                Button("登出") {
                                    self.storagedJwt = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                        // 重新登录
                                        dismissWindow(window: .main)
                                        openWindow(window: .login)
                                    })
                                }
                                .buttonStyle(.link)
                            }
                            .padding()
                        })
            
                    Text("\(userInfo.realName)(\(userInfo.name))")
                        .font(.title2)
                }
                .onTapGesture {
                    self.showExit.toggle()
                }
            })
        })
        .onAppear {
            if let jwt = storagedJwt {
                vm.loadWordDictionary(jwt: jwt)
                vm.loadLocalWordDictionary()
            } else {
                // 重新登录
                dismissWindow(window: .main)
                openWindow(window: .login)
            }
        }
    }
}

#Preview {
    MainView(userInfo: UserDTO(id: 1, name: "wttch", realName: "王冲", tel: "187xxxx9458", email: "wttch@wttch.com"))
}
