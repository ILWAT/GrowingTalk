//
//  GetMyChannelModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/24/24.
//

import Foundation

struct ChannelModel: Decodable {
    let workspaceId: Int
    let channelId: Int
    let name: String
    let description: String?
    let ownerId: Int
    let isPrivate: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case channelId = "channel_id"
        case ownerId = "owner_id"
        case isPrivate = "private"
        case name, createdAt, description
    }
}
