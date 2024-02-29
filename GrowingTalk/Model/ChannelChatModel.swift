//
//  ChannelChatModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/21/24.
//

import Foundation

struct ChannelChatModel: Decodable, Hashable {
    let channelID: Int
    let channelName: String
    let chatID: Int
    let content: String
    let createdAt: String
    let files: [String]
    let user: UserInfoModel
    
    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case channelName
        case chatID = "chat_id"
        case content
        case createdAt
        case files
        case user
    }
}
