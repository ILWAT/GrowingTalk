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
        let changingAdminTrigger: PublishSubject<Void>
        let beAdminUserID: PublishSubject<Int>
    }
    
    struct Output {
        let getMembersResult: Driver<Result<[UserInfo],Error>>
        let chagingAdimnResult:Driver<Result<WorkSpaceModel, Error>>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let getMembersResult = PublishSubject<Result<[UserInfo], Error>>()
        let changingAdminResult = PublishSubject<Result<WorkSpaceModel, Error>>()
        
        
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
        
        Observable.combineLatest(input.changingAdminTrigger, input.beAdminUserID)
            .flatMapLatest({ value in
                APIManger.shared.requestByRx(requestType: .changeAdminOfWorkspace(workspaceID: input.workspaceID, userID: value.1), decodableType: WorkSpaceModel.self, defaultErrorType: NetworkError.changeAdminOfWorkSpaceError.self)
            })
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let workspace):
                    changingAdminResult.onNext(.success(workspace))
                case .failure(let error):
                    let errorMessages = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.changeAdminOfWorkSpaceError.self)
                    print(errorMessages)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            getMembersResult: getMembersResult.asDriver(onErrorJustReturn: .failure(DeviceError.unknownError)), 
            chagingAdimnResult: changingAdminResult.asDriver(onErrorJustReturn: .failure(DeviceError.unknownError))
        )
    }
}
