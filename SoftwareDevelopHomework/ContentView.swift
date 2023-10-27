//
//  ContentView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginView()
    }
}

#Preview {
    ContentView()
        .presentedWindowStyle(.hiddenTitleBar)
        .ignoresSafeArea(edges: .top)
}
