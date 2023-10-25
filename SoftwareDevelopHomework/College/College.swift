//
//  College.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/25.
//

import Foundation

class College {
    // 学生信息
    private var students: [Student]
    // 班级信息
    private var groups: [Group]
    
    // 学生 id 到 学生信息的映射，方便根据 id 查找学生
    private var studentIdMap: [String: Student] = [:]
    
    init() {
        self.students = []
        self.groups = []
    }
    
    // MARK: 学生信息 和 函数
    
    
    // MARK: 班级信息 和 函数
    
    // MARK: 学院信息 和 函数
    /// 将学院信息保存到文件。
    /// - Parameter filename: 文件名字
    func saveTo(filename: String) {
        
    }
    
    
    /// 从文件加载学院信息。
    /// - Parameter filename: 文件名称
    func loadFrom(filename: String) {
        
    }
    
    
    /// 处理数据
    func prepareData() {
        self.studentIdMap = self.students.reduce(into: [:] as [String: Student], { partialResult, student in
            partialResult[student.id] = student
        })
    }
}
