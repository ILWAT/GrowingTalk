//
//  GetMyDMmodel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/25/24.
//

import Foundation


struct GetMyDMResultModel: Decodable {
    /*
     {
         "workspace_id": 1,
         "room_id": 1,
         "createdAt": "2023-12-21T22:47:30.236Z",
         "user": {
           "user_id": 1,
           "email": "sesac@gmail.com",
           "nickname": "새싹",
           "profileImage": "/static/profiles/1701706651161.jpeg"
         }
       }
     */
    let workspaceId: Int
    let roomId: Int
    let createdAt: String
    let user: UserInfo
    
    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case roomId = "room_id"
        case createdAt, user
    }
}

struct UserInfo: Decodable {
    let userId: Int
    let email: String
    let nickname: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email, nickname, profileImage
    }
}
