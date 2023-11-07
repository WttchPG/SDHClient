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
    @AppStorage("login_password") private var password: String = ""
    
    @API("auth/login") var test: String = ""
    @API("auth/user") var userInfo: UserDTO? = nil
    @FocusState private var passwordFieldFocus: Bool
    
    private let uiMessagePublisher = PassthroughSubject<AlertMessage, Never>()
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                Spacer()
                if let jwt = self.storagedJwt {
                    if let userInfo = userInfo {
                        Text("你好! \(userInfo.realName), \(userInfo.email)")
                    }
                    if $userInfo.running {
                        HStack {
                            ProgressView()
                            Text("正在获取用户信息...")
                        }
                        .font(.title)
                        .foregroundStyle(.white)
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
        .wrapperAlert(publisher: self.alertMessagePublisher)
        .onChange(of: $test.data, { _, newValue in
            self.uiMessagePublisher.send(.success("登录成功!"))
            self.storagedJwt = newValue
            $userInfo.post(jwt: self.storagedJwt, delay: 2)
        })
        .onChange(of: userInfo, { _, newValue in
            if let userInfo = newValue {
                dismissWindow(window: .login)
                openWindow(window: .main, data: userInfo)
                self.userInfo = nil
            }
        })
        .on401 {
            logger.info("收到 401 事件:\($0)")
            self.storagedJwt = nil
        }
        .onAppear {
            if let jwt = self.storagedJwt {
                logger.debug("已存在 jwt， 尝试获取用户信息...")
                $userInfo.post(jwt: jwt, delay: 2)
            }
            logger.logLevel = .debug
        }
        .onReceive($userInfo.errorPublisher.catchServiceCode(401), perform: { _ in
            self.storagedJwt = nil
        })
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
                Text("登录\($test.running ? "中..." : "")")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
            })
            .disabled($test.running)
        }
        .foregroundColor(.white)
        .font(.title)
    }
    
    /// 登录
    private func login() {
        guard !username.isEmpty && !password.isEmpty else {
            self.uiMessagePublisher.send(AlertMessage.warning("账号或密码为空!"))
            return
        }
        
        $test.post([
            "username": username,
            "password": password
        ])
    }
    
    /// 处理错误消息给弹窗
    private var alertMessagePublisher: AnyPublisher<AlertMessage, Never>  {
        return $test.errorPublisher
            .merge(with: $userInfo.errorPublisher)
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
