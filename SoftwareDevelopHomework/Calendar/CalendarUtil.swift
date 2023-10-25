//
//  CalendarUtil.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/18.
//

import Foundation

/// 日历工具类
class CalendarUtil {
    ///  获取某年某月某日星期几
    /// - Parameters:
    ///   - y: 年份
    ///   - m:  月份
    ///   - d:  日
    /// - Returns: 星期，0 - 6 分别代表 日、一 ~ 六
    static func getWeek(year: Int, month: Int, day: Int) -> Int {
        // 蔡勒公式
        let c = year / 100
        let y = (month <= 2 ? year - 1 : year) % 100
        let m = month <= 2 ? month + 12 : month
        
        return (c / 4 - 2 * c + y + y / 4 + 13 * (m + 1) / 5 + day - 1) % 7
    }
    
    /// 获取指定月的天数
    /// - Parameters:
    ///   - year: 指定年
    ///   - month: 指定月
    /// - Returns: 指定的月的天数
    static func getDayCount(year: Int, month: Int) -> Int {
        let dayCount = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        // 闰年2月?
        let isLeayYearFebruary = isLeapYear(year: year) && month == 2
        // 闰年2月加1天
        return dayCount[month - 1] + (isLeayYearFebruary ? 1 : 0)
    }
    
    /// 判断给定的年是否为闰年
    /// - Parameter year: 要判断的年
    /// - Returns: true 如果为闰年，否则 false
    static func isLeapYear(year: Int) -> Bool {
        return year % 4 == 0 && year % 100 != 0 || year % 400 == 0
    }
}
