//
//  Group.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/25.
//

import Foundation

/// 班级信息
class Group : Identifiable, Codable {
    // 班级编号
    var id: String
    // 所学专业
    var major: String
    // 入学时间
    var beginDate: Date
    // 学院 id
    var collegeId: String
    // 学生 id 列表
    private var studentIds: [String]
    
    init(id: String, major: String, beginDate: Date, collegeId: String, studentIds: [String]) {
        self.id = id
        self.major = major
        self.beginDate = beginDate
        self.collegeId = collegeId
        self.studentIds = studentIds
    }
    
    
    /// 添加学生到班级。
    /// 实际只保留学生id，即保存班级到学生的id映射。
    /// - Parameter student: 学生信息
    func addStudent(student: Student) {
        self.studentIds.append(student.id)
    }
    
    /// 从班级移除学生
    /// - Parameter student: 要移除的学生信息
    func removeStudent(student: Student) {
        self.studentIds.removeAll { $0 == student.id }
    }
}
