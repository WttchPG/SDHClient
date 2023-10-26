//
//  College.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/25.
//

import Foundation

class College: Codable {
    // 学院id
    var id: String
    // 学院名称
    var name: String
    // 学生信息
    private var students: [Student]
    // 班级信息
    private var groups: [Group]
    
    // 学生 id 到 学生信息的映射，方便根据 id 查找学生
    private var studentIdMap: [String: Student] = [:]
    // 班级 id 到 班级信息的映射，方便根据 id 查找班级
    private var groupIdMap: [String: Group] = [:]
    
    // MARK: 学生信息 和 函数
    /// 根据学生编号 查询学生
    /// - Parameter id: 学生编号
    /// - Returns: 学生信息
    func findStudent(id: String) -> Student? {
        return self.studentIdMap[id]
    }
    
    /// 添加学生。
    /// 如果指定了班级信息则添加到指定班级。
    /// - Parameters:
    ///   - id: 学生编号
    ///   - name: 姓名
    ///   - idcard: 身份证号
    ///   - beginDate: 入学时间
    ///   - groupId: 班级 id
    func addStudent(id: String, name: String, idcard: String, beginDate: Date, groupId: String?) {
        var student = Student(id: id, name: name, idcard: idcard, beginDate: beginDate, groupId: groupId)
        
        if let groupId = groupId, let group = self.groupIdMap[groupId] {
            // 添加到指定班级
            group.addStudent(student: student)
        }
        
        // 处理映射关系
        self.studentIdMap[id] = student
    }
    
    /// 根据学生编号删除学生
    /// - Parameter id: 学生编号。
    func removeStudent(id: String) {
        // 学生存在
        guard let student = self.studentIdMap[id] else { return }

        self.students.removeAll(where: { $0.id == student.id })
        // 处理映射关系
        self.studentIdMap.removeValue(forKey: id)
        
        if let groupId = student.groupId, let group = self.groupIdMap[groupId] {
            // 学生已经分好班级
            group.removeStudent(student: student)
        }
    }
    
    // MARK: 班级信息 和 函数
    func findGroup(id: String) -> Group? {
        return self.groupIdMap[id]
    }
    
    // MARK: 学院信息 和 函数
    /// 将学院信息保存到文件。
    /// - Parameter filename: 文件名字
    func saveTo(filename: String) {
        let url = URL(filePath: filename)
        do {
            try JSONEncoder().encode(self).write(to: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    /// 从文件加载学院信息。
    /// - Parameter filename: 文件名称
    static func loadFrom(filename: String) -> College? {
        let url = URL(filePath: filename)
        do {
            return try JSONDecoder().decode(College.self, from: Data(contentsOf: url))
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    /// 处理数据
    func prepareData() {
        self.studentIdMap = self.students.toMap(keyMapper: { $0.id }, valueMapper: { $0 })
        self.groupIdMap = self.groups.toMap(keyMapper: { $0.id }, valueMapper: { $0 })
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case students
        case groups
    }
}
