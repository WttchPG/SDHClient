//
//  LoginView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import SwiftUI
import Combine

// MARK: VIEW
struct LoginView: View {
    // 打开关闭窗口
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @AppStorage("jwt") private var storagedJwt: String?
    @AppStorage("login_username") private var username: String = ""
    
    @State private var password: String = ""
    @ObservedObject private var vm = LoginViewModel()
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                Spacer()
                if let jwt = self.storagedJwt {
                    if let userInfo = vm.userInfo {
                        Text("你好! \(userInfo.realName), \(userInfo.email)")
                    }
                    if vm.loadingUserInfo {
                        ProgressView(label: {
                            Text("获取用户信息!")
                        })
                    }
                } else {
                    loginView(geometry: geometry)
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
        .onChange(of: vm.alertMessage, initial: false) { msg, _ in
            guard let msg = vm.alertMessage else { return }
            AlertMessageManager.send(msg)
        }
        .onChange(of: vm.jwt, initial: false) { _, newJwt in
            self.storagedJwt = newJwt
            if let _ = newJwt {
                // 登录成功
                AlertMessageManager.success("登录成功!")
            } else {
                // jwt 失效
                AlertMessageManager.warning("jwt 失效!")
            }
        }
        .onChange(of: vm.userInfo, { _, newValue in
            if let userInfo = newValue {
                dismissWindow(window: .login)
                openWindow(window: .main, data: userInfo)
            }
        })
        .onChange(of: vm.jwtExpired, { oldValue, newValue in
            if newValue {
                self.storagedJwt = nil
            }
        })
        .onAppear {
            if let jwt = self.storagedJwt {
                vm.userInfo(jwt: jwt)
            }
        }
    }
    
    private func login() {
        guard !username.isEmpty && !password.isEmpty else {
            AlertMessageManager.warning("账号或密码为空!")
            return
        }
        
        vm.login(username: username, password: password)
    }
    
    private func loginView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            HStack {
                Text("Every word\ncounts here")
                Spacer()
            }
            .font(.largeTitle)
            HStack {
                Text("记住单词，记录改变")
                Spacer()
            }
            
            TextField("请输入账号", text: $username)
                .multilineTextAlignment(.center)
            SecureField("请输入密码", text: $password)
                .multilineTextAlignment(.center)
            
            Button(action: {
                login()
            }, label: {
                Text("登录")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
            })
        }
        .foregroundColor(.white)
        .font(.title)
    }
}

#Preview {
    LoginView()
}


// MARK: ViewModel
class LoginViewModel: ObservableObject {
    @Published var alertMessage: AlertMessage? = nil
    @Published var jwt: String? = nil
    @Published var loadingUserInfo = false
    @Published var userInfo: UserDTO? = nil
    @Published var jwtExpired: Bool = false
    
    private var service = LoginService()
    
    private var cancelles: [AnyCancellable] = []
    
    init() {
        service.$alertMessage.sink{
            self.alertMessage = $0
        }.store(in: &cancelles)
        
        service.$jwt.sink {
            self.jwt = $0
        }.store(in: &cancelles)
        
        service.$userInfo.sink {
            self.userInfo = $0
        }.store(in: &cancelles)
        
        service.$jwtExpired.sink {
            self.jwtExpired = $0
        }.store(in: &cancelles)
    }
    
    func login(username: String, password: String) {
        service.login(username: username, password: password)
    }
    
    func userInfo(jwt: String) {
        self.loadingUserInfo = true
        service.userInfo(jwt: jwt) {
            self.loadingUserInfo = false
        }
    }
    
}
