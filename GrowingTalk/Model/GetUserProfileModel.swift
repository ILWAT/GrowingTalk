//
//  GetUserProfileModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/29/24.
//

import Foundation

struct GetUserProfileModel: Decodable {
    /*{
     "user_id": 1,
     "email": "sesac@gmail.com",
     "nickname": "새싹",
     "profileImage": null,
     "phone": null,
     "vendor": null,
     "sesacCoin": 0,
     "createdAt": "2023-12-21T22:47:30.236Z"
   }*/
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
