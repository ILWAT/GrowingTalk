//
//  SignupMode.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/8/24.
//

import Foundation

struct SignupBodyModel: Encodable {
    let email: String
    let password: String
    let nickname: String
    let phone: String?
    let deviceToken: String?
}

struct SignupResultModel: Decodable {
    let userId: Int
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String
    let vendor: String?
    let createdAt: String
    let token: Tokens
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nickname
        case profileImage
        case phone
        case vendor
        case createdAt
        case token
    }
}

struct Tokens: Decodable{
    let accessToken: String
    let refreshToken: String
}
