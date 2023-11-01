//
//  DictionaryWordListWordView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/11/1.
//

import SwiftUI

/// 词典单词列表，单词的视图。
/// 可以点击隐藏/展示释义。
struct DictionaryWordListWordView: View {
    let word: WordDTO
    
    @State private var showMean: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(word.word)
                    .bold()
                    .font(.title)
                Text(word.symbol)
                    .foregroundStyle(Color.gray)
            }
            meanView
        }
        .padding(.bottom, 4)
    }
    
    private var meanView: some View {
        VStack(alignment: .leading) {
            if showMean {
                Spacer()
                if advs.count == means.count {
                    ForEach(0..<advs.count, id: \.self) { idx in
                        AdvMeanView(adv: advs[idx], mean: means[idx])
                    }
                } else {
                    AdvMeanView(adv: word.adv, mean: word.mean)
                }
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray)
                    .onTapGesture {
                        showMean.toggle()
                    }
            }
        }
    }
    
    private var advs: [String] {
        return word.adv.replacingOccurrences(of: " ", with: "").split(separator: "^").map { String($0) }
    }
    
    private var means: [String] {
        return word.mean.replacingOccurrences(of: "\r", with: "").split(separator: "^").map { String($0) }
    }
}

#Preview {
    DictionaryWordListWordView(word: WordDTO(id: 1, word: "apple", symbol: "/ apple /", adv: "n.^v.", mean: "苹果^苹果", system: 1))
}
