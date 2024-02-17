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
    }
    
    struct Output {
        let closedButtonTap: Driver<Void>
        let allChannelInWorkspace: Driver<[ChannelModel]>
    }
    
    private let disposeBag = DisposeBag()
    func transform(_ input: Input) -> Output {
        let toastMessage = PublishRelay<String>()
        let allChannelInWorkspace = PublishSubject<[ChannelModel]>()
        
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
        
        return Output(
            closedButtonTap: input.closedButtonTap.asDriver(),
            allChannelInWorkspace: allChannelInWorkspace.asDriver(onErrorJustReturn: [])
        )
    }
}
