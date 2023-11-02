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
struct AlertMessage: Equatable {
    private let id: String
    // 消息类型
    let type: AlertMessageType
    let message: String
    
    init(type: AlertMessageType, message: String) {
        self.id = UUID().uuidString
        self.type = type
        self.message = message
    }
    
    static func ==(lhs: AlertMessage, rhs: AlertMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

/// 消息类型
enum AlertMessageType {
    case info
    case success
    case warning
    case error
    
    var color: Color {
        let colors: [AlertMessageType: Color] = [
            .info: .black,
            .success: .green,
            .warning: .orange,
            .error: .red
        ]
        
        return colors[self]!
    }
}

// MARK: Manager

class AlertMessageManager {
    static let instance: AlertMessageManager = AlertMessageManager()
    
    let publisher: PassthroughSubject<AlertMessage, Never>
    
    private init() {
        publisher = PassthroughSubject<AlertMessage, Never>()
    }
    
    static func send(_ msg: AlertMessage) {
        instance.publisher.send(msg)
    }
    
    static func warning(_ msg: String) {
        instance.publisher.send(AlertMessage(type: .warning, message: msg))
    }
    
    static func success(_ msg: String) {
        instance.publisher.send(AlertMessage(type: .success, message: msg))
    }
}

// MARK: View
struct AlertMessageView<Content>: View where Content: View{
    
    private var wrappedView: Content
    
    @State private var offset: CGFloat = -36
    @State private var message: AlertMessage? = nil
    
    private var cancelles: [AnyCancellable] = []
    private let publisher: AnyPublisher<AlertMessage, Never>
    
    init(publisher: AnyPublisher<AlertMessage, Never>, @ViewBuilder content: () -> Content) {
        self.publisher = publisher
        self.wrappedView = content()
    }
    
    init(publisher: AnyPublisher<AlertMessage, Never>, content: Content) {
        self.publisher = publisher
        self.wrappedView = content
    }
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                VStack {
                    HStack {
                        Text("\(message?.message ?? "")")
                        
                        Spacer()
                    }
                    .cornerRadius(4)
                    .padding(.horizontal, 48)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .foregroundColor(.white)
                    .background(message?.type.color.opacity(0.4))
                    .offset(y: offset)
                    .clipped() // 让弹窗不影响标题栏
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            })
            .zIndex(1000)
            
            wrappedView
        }
        .onReceive(publisher, perform: { msg in
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
    let publisher: AnyPublisher<AlertMessage, Never>
    
    func body(content: Content) -> some View {
        return AlertMessageView(publisher: publisher, content: content)
    }
}

extension View {
    func wrapperAlert(publisher: AnyPublisher<AlertMessage, Never>) -> some View {
        return self.modifier(AlertMessageViewModifer(publisher: publisher))
    }
}

#Preview {
    let publisher = PassthroughSubject<AlertMessage, Never>()
    return VStack {
        Text("测试")
    
        Text("测试")
        
        Button("发送") {
            publisher.send(AlertMessage(type: .error, message: "测试"))
        }
    }
    .frame(width: 400, height: 200)
    .wrapperAlert(publisher: publisher.eraseToAnyPublisher())
}
