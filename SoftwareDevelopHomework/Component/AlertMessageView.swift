//
//  AlertMessageView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/26.
//

import SwiftUI
import Combine

// MARK: ENTITY

/// 消息
struct AlertMessage {
    // 消息类型
    let type: AlertMessageType
    let message: String
}

/// 消息类型
enum AlertMessageType {
    case info
    case success
    case warning
    case error
}

// MARK: Manager

class AlertMessageManager {
    static let instance: AlertMessageManager = AlertMessageManager()
    
    let publisher: PassthroughSubject<AlertMessage, Never>
    
    private init() {
        publisher = PassthroughSubject<AlertMessage, Never>()
    }
}

// MARK: View
struct AlertMessageView<Content>: View where Content: View{
    
    private var wrappedView: Content
    
    @State private var offset: CGFloat = -36
    @State private var message: AlertMessage? = nil
    
    private var cancelles: [AnyCancellable] = []
    
    init(@ViewBuilder content: () -> Content) {
        self.wrappedView = content()
    }
    
    init(content: Content) {
        self.wrappedView = content
    }
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                VStack {
                    HStack {
                        Text("\(message?.message ?? "")")
                        
                        Spacer()
                        
                        Button("关闭") {
                            withAnimation {
                                self.offset = -36
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(.red.opacity(0.4))
                    .cornerRadius(4)
                    .padding(.horizontal, 8)
                    .offset(y: offset)
                    .clipped() // 让弹窗不影响标题栏
                    
                    Spacer()
                }
            })
            .zIndex(1000)
            
            wrappedView
        }
        .onReceive(AlertMessageManager.instance.publisher, perform: { msg in
            self.message = msg
            withAnimation {
                self.offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                withAnimation {
                    self.offset = -36
                }
            })
        })
    }
}

struct AlertMessageViewModifer: ViewModifier {
    func body(content: Content) -> some View {
        return AlertMessageView(content: content)
    }
}

extension View {
    func wrapperAlert() -> some View {
        return self.modifier(AlertMessageViewModifer())
    }
}

#Preview {
    VStack {
        Text("测试")
    
        Text("测试")
        
        Button("发送") {
            AlertMessageManager.instance.publisher.send(AlertMessage(type: .error, message: "测试"))
        }
    }
    .frame(width: 400, height: 200)
    .wrapperAlert()
}
