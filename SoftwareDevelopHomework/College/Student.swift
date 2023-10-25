//
//  Student.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/25.
//

import Foundation

/// 学生信息，因为对学生没有太多的操作要求，故设计为结构体。
///
/// 学号、姓名、身份证、入学时间、专业、学生电话和班级编号。
struct Student : Identifiable {
    // 学号
    var id: String
    
    // 姓名
    var name: String
    
    // 身份证号
    var idcard: String
}
