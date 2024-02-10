//
//  SideBarViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/6/24.
//

import UIKit
import RxCocoa
import RxSwift

final class SideBarViewModel: ViewModelType {
    struct Input {
        let requestWorkspaceAPI: BehaviorSubject<Void>
        let workspaceID: Int?
        let ownerID: Int?
        let exitAction: PublishSubject<Void>
        let editAction: PublishSubject<Void>
        let changeAdminAction: PublishSubject<Void>
        let deleteWorkspaceAction: PublishSubject<Void>
    }
    
    struct Output {
        let userOwnWorkspace: Driver<[GetUserWorkSpaceResultModel]>
        let isUserAdmin: Driver<Void>
        let changeWorkspace: Driver<Result<GetUserWorkSpaceResultModel, Error>>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let workSpaceData = BehaviorSubject<[GetUserWorkSpaceResultModel]>(value: [])
        let isUserAdmin = PublishSubject<Void>()
        let changeWorkspace = PublishRelay<Result<GetUserWorkSpaceResultModel, Error>>()
        
        input.requestWorkspaceAPI
            .flatMapLatest { _ in
                APIManger.shared.requestByRx(requestType: .getAllWorkSpace, decodableType: [GetUserWorkSpaceResultModel].self, defaultErrorType: NetworkError.GetUserWorkSpaceError.self)
            }
            .subscribe(with: self) { owner, response in
                switch response{
                case .success(let workspaces):
                    workSpaceData.onNext(workspaces)
                case .failure(let error):
                    if let commonError = error as? NetworkError.commonError {
                        print(commonError)
                    } else if let getWorkspaceError = error as? NetworkError.GetUserWorkSpaceError {
                        print(getWorkspaceError)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.exitAction
            .flatMapLatest<PrimitiveSequence<SingleTrait, Result<[GetUserWorkSpaceResultModel], Error>>> { _ in
                APIManger.shared.requestByRx(requestType: .exitWorkspace(workSpaceID: input.workspaceID!), decodableType: [GetUserWorkSpaceResultModel].self, defaultErrorType: NetworkError.ExitWorkSpaceError.self)
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let result):
                    if let firstWorkspace = result.first {
                        changeWorkspace.accept(.success(firstWorkspace))
                    } else {
                        changeWorkspace.accept(.failure(DeviceError.intentionalError))
                    }
                    
                case .failure(let error):
                    if let commonError = error as? NetworkError.commonError {
                        print(commonError.errorMessage)
                    } else if let exitWorkspaceError = error as? NetworkError.ExitWorkSpaceError {
                        if exitWorkspaceError == .rejectRequest {
                            isUserAdmin.onNext(())
                        }
                        print(exitWorkspaceError.errorMessage)
                    } else {
                        print(NetworkError.commonError.unknownError.errorMessage)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            userOwnWorkspace: workSpaceData.asDriver(onErrorJustReturn: []),
            isUserAdmin: isUserAdmin.asDriver(onErrorJustReturn: ()), 
            changeWorkspace: changeWorkspace.asDriver(onErrorJustReturn: .failure(NetworkError.commonError.unknownError))
        )
    }
}
