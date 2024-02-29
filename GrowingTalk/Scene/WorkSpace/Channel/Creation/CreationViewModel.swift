//
//  CreationViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/15/24.
//

import Foundation
import RxCocoa
import RxSwift

final class CreationViewModel: ViewModelType {
    struct Input {
        let workspaceID: Int
        let closeButtonTap: ControlEvent<Void>
        let createButtonTap: ControlEvent<Void>
        let channelNameText: ControlProperty<String>
        let channelDescriptionText: ControlProperty<String>
    }
    
    struct Output {
        let closedButtonTap: Driver<Void>
        let toastMessage: Driver<String>
        let creationButtonIsEnabled: Driver<Bool>
        let createChannelResult: Driver<Result<ChannelModel, Error>>
    }
    
    private let realmManager = RealmManager()
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let toastMessage = PublishRelay<String>()
        let creationButtonIsEnabled = BehaviorRelay<Bool>(value: false)
        let createChannelResult = PublishSubject<Result<ChannelModel, Error>>()
        
        input.channelNameText
            .subscribe(with: self) { owner, channelNameText in
                if channelNameText.isEmpty {
                    creationButtonIsEnabled.accept(false)
                } else {
                    creationButtonIsEnabled.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        input.createButtonTap
            .withLatestFrom(Observable.combineLatest(input.channelNameText, input.channelDescriptionText))
            .flatMapLatest { inputData in
                APIManger.shared.requestByRx(requestType: .createChannel(workspaceID: input.workspaceID, targetChannel: .init(name: inputData.0, description: inputData.1)), decodableType: ChannelModel.self, defaultErrorType: NetworkError.CreateChannelError.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    createChannelResult.onNext(.success(response))
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.CreateChannelError.self)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        let createChannelResultDriver = createChannelResult.asDriver(onErrorJustReturn: .failure(DeviceError.unknownError))
        
        createChannelResultDriver
            .drive(with: self) { onwer, result in
                switch result{
                case .success(let channel):
                    Task {[weak self] in
                        try await self?.realmManager.writeAsyncWriteToRealm(type: RealmChannelModel.self, targetData: RealmChannelModel(channelID: channel.channelId, channelName: channel.name, finalMessageDate: "", ownUser: channel.ownerId))
                    }
                case .failure(_):
                    break
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            closedButtonTap: input.closeButtonTap.asDriver(),
            toastMessage: toastMessage.asDriver(onErrorJustReturn: DeviceError.unknownError.errorMessage),
            creationButtonIsEnabled: creationButtonIsEnabled.asDriver(),
            createChannelResult: createChannelResultDriver
        )
    }
}
