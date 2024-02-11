//
//  GetUserProfileModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/29/24.
//

import Foundation

struct GetUserProfileModel: Decodable {
    let userId: Int
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let vendor: String?
    let sesacCoin: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email, nickname, profileImage, phone, vendor, sesacCoin, createdAt
    }
}
