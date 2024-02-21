//
//  ChannelChatModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/21/24.
//

import Foundation

struct ChannelChatModel: Decodable, Hashable {
    let channelID: Int
    let chanelName: String
    let chatID: Int
    let content: String
    let createdAt: String
    let files: [String]
    let user: UserInfoModel
}
