//
//  RealmChatModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/22/24.
//

import Foundation
import RealmSwift

class RealmChatModel: Object {
    @Persisted(primaryKey: true) var chatID: Int
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    
    @Persisted var channel: RealmChannelModel!
    @Persisted var user: RealmUserInfoModel!
    
    convenience init(chatID: Int, content: String, createdAt: String, files: List<String>, channel: RealmChannelModel? = nil, user: RealmUserInfoModel? = nil) {
        self.init()
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.channel = channel
        self.user = user
    }
}

class RealmUserInfoModel: Object {
    @Persisted(primaryKey: true) var userID: Int
    @Persisted var nickName: String
    @Persisted var profileImage: String?
    
    convenience init(userID: Int, nickName: String, profileImage: String? = nil) {
        self.init()
        self.userID = userID
        self.nickName = nickName
        self.profileImage = profileImage
    }
}

class RealmChannelModel: Object {
    @Persisted(primaryKey: true) var channelID: Int
    @Persisted var channelName: String
    @Persisted var finalMessageDate: String
    @Persisted var ownUser: Int
    
    convenience init(channelID: Int, channelName: String, finalMessageDate: String, ownUser: Int) {
        self.init()
        self.channelID = channelID
        self.channelName = channelName
        self.finalMessageDate = finalMessageDate
        self.ownUser = ownUser
    }
}
