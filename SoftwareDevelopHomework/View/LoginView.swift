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
    @AppStorage("login_username") private var username: String = ""
    @State private var password: String = ""
    
    @ObservedObject private var vm = LoginViewModel()
    
    var body: some View {
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
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                SecureField("请输入密码", text: $password)
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    login()
                }, label: {
                    Text("登录")
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity)
                })
                
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
            guard let msg = msg else { return }
            AlertMessageManager.send(msg)
        }
    }
    
    private func login() {
        guard !username.isEmpty && !password.isEmpty else {
            AlertMessageManager.warning("账号或密码为空!")
            return
        }
        
        vm.login(username: username, password: password)
    }
}

#Preview {
    LoginView()
}


// MARK: ViewModel
class LoginViewModel: ObservableObject {
    @Published var alertMessage: AlertMessage? = nil
    @Published var jwt: String? = nil
    
    private var service = LoginService()
    
    private var cancelles: [AnyCancellable] = []
    
    init() {
        service.$alertMessage.sink{
            self.alertMessage = $0
        }
            .store(in: &cancelles)
        service.$jwt.sink { self.jwt = $0 }
            .store(in: &cancelles)
    }
    
    func login(username: String, password: String) {
        service.login(username: username, password: password)
    }
    
}
