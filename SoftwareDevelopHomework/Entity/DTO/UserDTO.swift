//
//  UserDTO.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation

struct UserDTO: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let name: String
    let realName: String
    let tel: String
    let email: String
    
    static func ==(lhs: UserDTO, rhs: UserDTO) -> Bool {
        return lhs.id == rhs.id
    }
}
