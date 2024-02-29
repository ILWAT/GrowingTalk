//
//  UserInfo.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/11/24.
//

import Foundation

struct UserInfoModel: Decodable, Hashable {
    let userId: Int
    let email: String
    let nickname: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email, nickname, profileImage
    }
}

