//
//  ChattingViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/21/24.
//

import Foundation
import RxCocoa
import RxSwift
import RealmSwift

final class ChattingViewModel: ViewModelType {
    struct Input {
        let workspaceID: Int
        let ownName: String
        let ownID: Int
        let cursorDate: String?
        let viewWillDisappearTrigger: PublishRelay<String>
    }
    
    struct Output {
        let willUpdateChatData: Driver<[ChannelChatModel]>
    }
    private var realmManger = RealmManager()
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let toastMessage = PublishRelay<String>()
        let localChattingData = BehaviorSubject<[ChannelChatModel]>(value: [])
        let serverRequestTrigger = BehaviorSubject<String>(value: "")
        let willUpdateChatData = BehaviorRelay<[ChannelChatModel]>(value: [])
        
        let localSavedChatData = realmManger.getAllObjectFromRealm(type: RealmChatModel.self)
            .where({
                $0.channel.channelID == input.ownID
            })
            .sorted(by: { value1, value2 in
                return value1.chatID < value2.chatID
            })
            .map { realmChatModel in
                let userInfo = UserInfoModel(userId: realmChatModel.user.userID, email: "", nickname: realmChatModel.user.nickName, profileImage: realmChatModel.user.profileImage)
                
                return ChannelChatModel(channelID: realmChatModel.channel.channelID, channelName: realmChatModel.channel.channelName, chatID: realmChatModel.chatID, content: realmChatModel.content, createdAt: realmChatModel.createdAt, files: Array(realmChatModel.files), user: userInfo)
            }
        
        localChattingData.onNext(Array(localSavedChatData))
        
        localChattingData
            .debug("localChatting")
            .subscribe(with: self) { owner, chatModels in
                willUpdateChatData.accept(chatModels)
                serverRequestTrigger.onNext(chatModels.last?.createdAt ?? "")
            }
            .disposed(by: disposeBag)
        
        serverRequestTrigger
            .flatMapLatest { lastDate in
                APIManger.shared.requestByRx(requestType: .getChannelChat(workspaceID: input.workspaceID, channelName: input.ownName, cursorDate: lastDate), decodableType: [ChannelChatModel].self, defaultErrorType: NetworkError.GetChannelChatError.self)
            }
            .debug("server chat")
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let chattingDatas):
                    guard !chattingDatas.isEmpty else { return }
                    willUpdateChatData.accept(chattingDatas)
                    
                    let convertRealmModel = chattingDatas.map({ chatting in
                        
                        //realmChatModel 생성
                        let convertToList = List<String>()
                        convertToList.append(objectsIn: chatting.files)
                    
                        //realmChatModel에 담을 UserInfo 생성
                        let realmUserInfo = RealmUserInfoModel(userID: chatting.user.userId, nickName: chatting.user.nickname, profileImage: chatting.user.profileImage)

                        
                        //RealmChatModel에 넣을 channelModel 생성
                        let realmChannelInfo = RealmChannelModel(channelID: chatting.channelID, channelName: chatting.channelName, finalMessageDate: "", ownUser: UserDefaults.standard.integer(forKey: "currentUser"))
                        
                        return RealmChatModel(chatID: chatting.chatID, content: chatting.content, createdAt: chatting.createdAt, files: convertToList, channel: realmChannelInfo, user: realmUserInfo)
                    })

                    for models in convertRealmModel {
                        Task{
                            try await owner.realmManger.writeAsyncToRealmChattingModel(targetData: models)
                        }
                    }
                    
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.GetChannelChatError.self)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        input.viewWillDisappearTrigger
            .subscribe(with: self) { owner, lastDate in
                let filterData = owner.realmManger.getSpecificObjectFromRealm(type: RealmChannelModel.self, constraints: { $0.channelID == input.ownID })
                
                guard let firstData = filterData.first else {return}
                
                let updatingModel = RealmChannelModel(channelID: firstData.channelID, channelName: firstData.channelName, finalMessageDate: lastDate, ownUser: UserDefaults.standard.integer(forKey: "currentUser"))
                
                Task {
                    try await owner.realmManger.updateAsyncWriteToRealm(type: RealmChannelModel.self, targetData: updatingModel)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            willUpdateChatData: willUpdateChatData.asDriver(onErrorJustReturn: [])
        )
    }
}
