//
//  ContentView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/18.
//

import SwiftUI

struct ContentView: View {
    
    @State private var year: Int = 1999

    private var libraries = ["四级词库", "六级词汇", "生词库"]
    
    @State private var selectLibrary = "四级词库"
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(libraries, id: \.self, selection: $selectLibrary, rowContent: { library in
                Text(library)
            })
        }, detail: {
            VStack {
                Text(selectLibrary)
                    .font(.largeTitle)
                
                Spacer()
            }
            .navigationTitle(selectLibrary)
        })
    }
}

#Preview {
    ContentView()
}
