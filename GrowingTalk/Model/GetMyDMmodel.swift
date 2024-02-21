//
//  GetMyDMmodel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/25/24.
//

import Foundation


struct GetMyDMResultModel: Decodable {
    let workspaceId: Int
    let roomId: Int
    let createdAt: String
    let user: UserInfoModel
    
    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case roomId = "room_id"
        case createdAt, user
    }
}
