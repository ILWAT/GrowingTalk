//
//  RealmManager.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/25/24.
//

import Foundation
import RealmSwift

final class RealmManager {
    private let realm: Realm!
    
    init(){
        do {
            realm = try Realm()
            print("realm Path:", realm.configuration.fileURL)
        } catch {
            fatalError("realm init failed")
        }
    }
    
    func getAllObjectFromRealm<T: Object>(type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func getSpecificObjectFromRealm<T:Object>(type: T.Type, constraints: ((Query<T>) -> Query<Bool>)) -> Results<T> {
        return realm.objects(type).where(constraints)
    }
    
    func writeAsyncWriteToRealm<T: Object>(type: T.Type, targetData: T) async throws  {
        try await realm.asyncWrite {
            realm.create(RealmChatModel.self, value: targetData)
        }
    }
    
    func writeAsyncToRealmChattingModel(targetData: RealmChatModel) async throws {
        try await realm.asyncWrite {
            if let userInfo = realm.object(ofType: RealmUserInfoModel.self, forPrimaryKey: targetData.user.userID) {
                targetData.user = userInfo
            }
            
            if let channelInfo = realm.object(ofType: RealmChannelModel.self, forPrimaryKey: targetData.channel.channelID) {
                targetData.channel = channelInfo
            }
            
            realm.create(RealmChatModel.self, value: targetData)
        }
    }
    
    func updateAsyncWriteToRealm<T:Object>(type: T.Type, targetData: T) async throws {
        try await realm.asyncWrite {
            realm.create(type, value: targetData, update: .modified)
        }
    }

    
    
}
