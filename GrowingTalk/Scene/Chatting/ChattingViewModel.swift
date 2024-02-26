//
//  ChattingViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/21/24.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

final class ChattingViewModel: ViewModelType {
    struct Input {
        let workspaceID: Int
        let ownName: String
        let ownID: Int
        let sendButtonTap: ControlEvent<Void>
        let contentText: ControlProperty<String>
        let imageContent: BehaviorSubject<[UIImage]>
        let viewWillDisappearTrigger: PublishRelay<String>
    }
    
    struct Output {
        let willUpdateChatData: Driver<[ChannelChatModel]>
        let postChatIsSuccess: Driver<Void>
    }
    private var realmManger = RealmManager()
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let toastMessage = PublishRelay<String>()
        let localChattingData = BehaviorSubject<[ChannelChatModel]>(value: [])
        let serverRequestTrigger = BehaviorSubject<String>(value: "")
        let imageContent = BehaviorSubject<[Data]>(value: [])
        let postChatIsSuccess = PublishRelay<Void>()
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
                    owner.saveServerModelInRealm(chattingDatas: chattingDatas)
                    
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.GetChannelChatError.self)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        input.imageContent
            .subscribe(with: self) { owner, images in
                guard !images.isEmpty else {
                    imageContent.onNext([]) 
                    return
                }
                
                var imageData: [Data] = []
                
                for image in images {
                    guard let convertedImage = image.compressionUnderMBjpegData(megabyteSize: 1) else {
                        toastMessage.accept("이미지 손실이 발생했습니다. 다시 시도해주세요")
                        return
                    }
                    
                    imageData.append(convertedImage)
                }
                
                imageContent.onNext(imageData)
            }
            .disposed(by: disposeBag)
        
        input.sendButtonTap
            .withLatestFrom(Observable.combineLatest(input.contentText.asObservable(), imageContent))
            .flatMap({ bodyValue in
                var userText = bodyValue.0
                if userText == "메세지를 입력해주세요." { userText = "" }
                return APIManger.shared.requestByRx(requestType: .postChannelChat(workspaceID: input.workspaceID, channelName: input.ownName, content: bodyValue.0, files: bodyValue.1), decodableType: ChannelChatModel.self, defaultErrorType: NetworkError.GetChannelChatError.self)
            })
            .subscribe(with: self, onNext: { owner, result in
                switch result {
                case .success(let chat):
                    willUpdateChatData.accept([chat])
                    owner.saveServerModelInRealm(chattingDatas: [chat])
                    postChatIsSuccess.accept(())
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.GetChannelChatError.self)
                    toastMessage.accept(errorMessage)
                }
            })
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
            willUpdateChatData: willUpdateChatData.asDriver(onErrorJustReturn: []),
            postChatIsSuccess: postChatIsSuccess.asDriver(onErrorJustReturn: ())
        )
    }
    
    private func saveServerModelInRealm(chattingDatas: [ChannelChatModel]) {
        
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
                try await realmManger.writeAsyncToRealmChattingModel(targetData: models)
            }
        }
    }
}
