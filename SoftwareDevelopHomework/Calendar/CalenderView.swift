//
//  CalenderView.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/19.
//

import SwiftUI

struct CalenderView: View {
    // 第一天星期几
    let startDay: Int
    // 该月几天
    let dayCount: Int
    
    // 行数
    private let rawCount: Int
    
    init(startDay: Int, dayCount: Int) {
        self.startDay = startDay
        self.dayCount = dayCount
        
        self.rawCount = (startDay + dayCount) / 7 + ((startDay + dayCount) % 7 == 0 ? 0 : 1)
    }
    
    private let labels = "日一二三四五六".split(separator: "")
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<7) { i in
                    Text(labels[i])
                        .foregroundStyle(getDayColor(day: i))
                        .frame(width: 42)
                }
            }
            ForEach(0..<self.rawCount, id: \.self) { line in
                HStack {
                    ForEach(0..<7) { col in
                        HStack {
                            let day = line * 7 + col - startDay + 1
                            if day > 0 && day <= dayCount {
                                Text("\(day)")
                                    .font(.headline)
                                    .foregroundStyle(getDayColor(day: col))
                                    .bold()
                            } else {
                                // 站位
                                Text("")
                            }
                        }
                        .frame(width: 42)
                    }
                }
            }
        }
    }
    
    private func getDayColor(day: Int) -> Color {
        return day == 0 || day == 6 ? Color.red : Color.white
    }
}

#Preview {
    CalenderView(startDay: 3, dayCount: 31)
}
