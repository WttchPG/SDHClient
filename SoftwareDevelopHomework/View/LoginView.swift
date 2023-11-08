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
    
    @AppStorage(.jwt) private var storagedJwt: String?
    @AppStorage(.loginUserName) private var username: String = ""
    @AppStorage(.loginPassword) private var password: String = ""
    
    @FocusState private var passwordFieldFocus: Bool
    
    @ObservedObject private var vm = LoginViewModel()
    
    private let uiMessagePublisher = PassthroughSubject<AlertMessage, Never>()
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                Spacer()
                if let _ = self.storagedJwt {
                    loadingUserInfoView
                } else {
                    loginView(geometry: geometry)
                }
                Spacer()
            }
            .background { background(geometry) }
            .padding(.horizontal, 48)
        })
        // .ignoresSafeArea(edges: .top)
        .wrapperAlert(publisher: self.alertMessagePublisher)
        .onChange(of: vm.jwt, { self.loginSuccess($1) })
        .onChange(of: vm.userInfo, { self.showUserInfo($1) })
        .onAppear {
            if let jwt = self.storagedJwt {
                self.uiMessagePublisher.send(.warning("欢迎回来..."))
                vm.$userInfo.post(jwt: jwt, delay: 2)
            }
            logger.logLevel = .debug
        }
        .onReceive(vm.$userInfo.errorPublisher.catchServiceCode(401), perform: { _ in
            self.storagedJwt = nil
        })
    }
}

extension LoginView {
    // MARK: 子视图
    
    @ViewBuilder
    private var loadingUserInfoView: some View {
        if let userInfo = vm.userInfo {
            Text("\(userInfo.realName), \(userInfo.email)")
                .font(.largeTitle)
        }
        if vm.$userInfo.running {
            HStack {
                ProgressView()
                Text("正在获取用户信息...")
            }
            .font(.title)
            .foregroundStyle(.white)
        }
    }
    
    /// 背景
    private func background(_ geometry: GeometryProxy) -> some View {
        ZStack {
            Image("login-bg")
                .resizable()
                .scaledToFill()
            
            Color.black
                .opacity(0.5)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    /// 登录视图
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
                .onSubmit {
                    self.passwordFieldFocus = true
                }
            SecureField("请输入密码", text: $password)
                .multilineTextAlignment(.center)
                .focused($passwordFieldFocus, equals: true)
                .onSubmit {
                    self.login()
                }
            
            Button(action: {
                login()
            }, label: {
                Text("\(vm.jwt)")
                Text("\(vm.userInfo?.name ?? "")")
                Text("登录\(vm.$jwt.running ? "中..." : "")")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
            })
            .disabled(vm.$jwt.running)
        }
        .foregroundColor(.white)
        .font(.title)
    }
    
    // MARK: 行为
    
    /// 登录
    private func login() {
        guard !username.isEmpty && !password.isEmpty else {
            self.uiMessagePublisher.send(AlertMessage.warning("账号或密码为空!"))
            return
        }
        
        let data = [
            "username": username,
            "password": password
        ]
        
        vm.$jwt.post(data)
    }
    
    /// 登录成功
    private func loginSuccess( _ jwt: String) {
        self.uiMessagePublisher.send(.success("登录成功!"))
        self.storagedJwt = jwt
        vm.$userInfo.post(jwt: jwt, delay: 2)
    }
    /// 展示登录后获取的用户信息
    private func showUserInfo(_ userInfo: UserDTO?) {
        if let userInfo = userInfo {
            uiMessagePublisher.send(.success("你好: \(userInfo.name)"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                dismissWindow(window: .login)
                openWindow(window: .main, data: userInfo)
                self.vm.userInfo = nil
            })
        }
    }
    
    /// 处理错误消息给弹窗
    private var alertMessagePublisher: AnyPublisher<AlertMessage, Never>  {
        return vm.$jwt.errorPublisher
            .merge(with: vm.$userInfo.errorPublisher)
            .map { error in
                if let error = error as? ServiceError {
                    switch error {
                    case .dataNil:
                        return AlertMessage(type: .warning, message: "数据为空")
                    case .serviceError(_, let msg):
                        return AlertMessage.warning(msg)
                    default:
                        return AlertMessage(type: .error, message: "未知错误")
                    }
                }
                
                return AlertMessage(type: .warning, message: error.localizedDescription)
            }
            .merge(with: self.uiMessagePublisher)
            .eraseToAnyPublisher()
    }
}


#Preview {
    LoginView()
}
