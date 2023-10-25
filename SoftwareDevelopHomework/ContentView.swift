//
//  ContentView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/18.
//

import SwiftUI

struct ContentView: View {
    
    @State private var year: Int = 1999
    
    var body: some View {
        VStack {
            CalenderSeletor()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
