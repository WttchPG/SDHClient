//
//  UserDTO.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/27.
//

import Foundation

struct UserDTO: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let realName: String
    let tel: String
    let email: String
}
