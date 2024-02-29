//
//  SearchChannelViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/17/24.
//

import Foundation
import RxCocoa
import RxSwift

final class SearchChannelViewModel: ViewModelType {
    struct Input {
        let closedButtonTap: ControlEvent<Void>
        let workspaceID: Int
        let selectedChannel: ControlEvent<ChannelModel>
    }
    
    struct Output {
        let closedButtonTap: Driver<Void>
        let allChannelInWorkspace: Driver<[ChannelModel]>
        let isUserParticipated: Driver<(ControlEvent<ChannelModel>.Element, Bool)>
    }
    
    private let disposeBag = DisposeBag()
    func transform(_ input: Input) -> Output {
        let toastMessage = PublishRelay<String>()
        let allChannelInWorkspace = PublishSubject<[ChannelModel]>()
        let participatedChannelInWorkspace = BehaviorSubject<[ChannelModel]>(value: [])
        let isUserParticipated = PublishSubject<Bool>()
        
        APIManger.shared.requestByRx(requestType: .getAllChannelInWorkspace(workspaceID: input.workspaceID), decodableType: [ChannelModel].self, defaultErrorType: NetworkError.GetChannelError.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let workspaces):
                    allChannelInWorkspace.onNext(workspaces)
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.GetChannelError.self)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        APIManger.shared.requestByRx(requestType: .getMyAllChannelInWorkspace(workSpaceID: input.workspaceID), decodableType: [ChannelModel].self, defaultErrorType: NetworkError.GetChannelError.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let participatedChannel):
                    participatedChannelInWorkspace.onNext(participatedChannel)
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.GetChannelError.self)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(input.selectedChannel, participatedChannelInWorkspace.asObservable())
            .subscribe(with: self) { owner, combineValue in
                if combineValue.1.contains(where: { $0.channelId == combineValue.0.channelId }) {
                    isUserParticipated.onNext(true)
                } else {
                    isUserParticipated.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            closedButtonTap: input.closedButtonTap.asDriver(),
            allChannelInWorkspace: allChannelInWorkspace.asDriver(onErrorJustReturn: []),
            isUserParticipated: Observable.zip(input.selectedChannel, isUserParticipated).asDriver(onErrorJustReturn: (ChannelModel(workspaceId: 0, channelId: 0, name: "", description: nil, ownerId: 0, isPrivate: 0, createdAt: ""), false))
        )
    }
}
