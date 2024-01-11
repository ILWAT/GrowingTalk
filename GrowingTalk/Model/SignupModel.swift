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
    /*
     {
       "user_id": 61,
       "email": "mooneo@test.com",
       "nickname": "새싹",
       "profileImage": null,
       "phone": "010-1234-1234",
       "vendor": null,
       "createdAt": "2024-01-09T17:04:49.906Z",
       "token": {
         "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo2MSwibmlja25hbWUiOiLsg4jsi7kiLCJpYXQiOjE3MDQ3ODc0ODksImV4cCI6MTcwNDc5MTA4OSwiaXNzIjoic2xwIn0.jYLQow-P2Ptu69OXKCh-jm6KggycivvI8x4by2ERm1U",
         "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo2MSwiaWF0IjoxNzA0Nzg3NDg5LCJleHAiOjE3MDQ3OTQ2ODksImlzcyI6InNscCJ9.tUWLVLYbBHNXxkZUMZI0VtETA2q-aA56F3kb_ADQ7BU"
       }
     }
     */
    
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
