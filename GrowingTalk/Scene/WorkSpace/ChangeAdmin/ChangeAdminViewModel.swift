//
//  ChangeAdminViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/11/24.
//

import Foundation
import RxCocoa
import RxSwift

final class ChangeAdminViewModel: ViewModelType {
    struct Input {
        let viewUpdateTrigger: BehaviorSubject<Void>
        let workspaceID: Int
    }
    
    struct Output {
        let getMembersResult: Driver<Result<[UserInfo],Error>>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let getMembersResult = PublishSubject<Result<[UserInfo], Error>>()
        
        input.viewUpdateTrigger
            .flatMapLatest({ _ in
                APIManger.shared.requestByRx(requestType: .getWorkspaceMembers(workSpaceID: input.workspaceID), decodableType: [UserInfo].self, defaultErrorType: NetworkError.getWorkspaceMemberError.self)
            })
            .debug("changeAdmin")
            .subscribe(with: self, onNext: { owner, result in
                switch result {
                case .success(let members):
                    if members.count == 1 {
                        getMembersResult.onNext(.failure(DeviceError.intentionalError))
                    } else {
                        getMembersResult.onNext(.success(members))
                    }
                    
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.getWorkspaceMemberError.self)
                    print(errorMessage)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            getMembersResult: getMembersResult.asDriver(onErrorJustReturn: .failure(DeviceError.unknownError))
        )
    }
}
