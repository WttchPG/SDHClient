//
//  CalenderSeletor.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/19.
//

import SwiftUI

struct CalenderSeletor: View {
    @State var dateStr: String = ""
    
    
    @State private var valid: String? = ""
    
    @State private var dayCount: Int = 30
    @State private var startDay: Int = 3
    @State private var year: Int = 0
    @State private var month: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                TextField("请输入年月以,分割", text: $dateStr)
                    .frame(maxWidth: 200)
                    .onSubmit {
                        tryGeneratorCalenderView()
                    }
                
                if let valid = valid {
                    Text("\(valid)")
                        .foregroundStyle(.red)
                }
                
                Button("确定") { tryGeneratorCalenderView() }
                
                Spacer()
            }
            
            if valid == nil {
                VStack(spacing: 20) {
                    Text("\(year)年\(month)月 月历🗓️")
                        .font(.title)
                    CalenderView(startDay: startDay, dayCount: dayCount)
                }
            }
            
            Spacer()
        }
    }
    
    private func tryGeneratorCalenderView() {
        let strs = dateStr.split(separator: ",")
        if strs.count == 2, let year = Int(strs[0]), let month = Int(strs[1]) {
            if month < 1 || month > 12 {
                valid = "月份\(month)不正确"
            } else {
                valid = nil
                startDay = CalendarUtil.getWeek(year: year, month: month, day: 1)
                dayCount = CalendarUtil.getDayCount(year: year, month: month)
                self.year = year
                self.month = month
            }
        } else {
            valid = "解析失败，请检查输入格式."
        }
    }
}

#Preview {
    CalenderSeletor()
}
