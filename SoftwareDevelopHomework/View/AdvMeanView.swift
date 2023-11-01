//
//  AdvMeanView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/1.
//

import SwiftUI

/// 单词词性和释义
struct AdvMeanView: View {
    let adv: String
    let mean: String
    
    var body: some View {
        HStack {
            Text(adv)
                .foregroundStyle(.gray)
                .font(.caption)
            Text(mean)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    AdvMeanView(adv: "n.", mean: "苹果")
}
