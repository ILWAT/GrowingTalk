//
//  WorkSpaceInitialViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/11/24.
//

import Foundation
import RxCocoa
import RxSwift

final class WorkSpaceInitialViewModel: ViewModelType {
    struct Input {
        let makingButtonTap: ControlEvent<Void>
        let closeButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let workSpaceIsExist: Observable<Result<[WorkSpaceModel], NetworkError.GetUserWorkSpaceError>>
        let makingButtonTap: ControlEvent<Void>
    }
    
    let disposBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let existedOwnWorkspace = PublishSubject<Result<[WorkSpaceModel],NetworkError.GetUserWorkSpaceError>>()
        
        input.closeButtonTap
            .flatMapLatest { _ in
                APIManger.shared.requestByRx(requestType: .getAllWorkSpace, decodableType: [WorkSpaceModel].self, defaultErrorType: NetworkError.GetUserWorkSpaceError.self)
                    .debug()
            }
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let userWorkspaceData):
                    if userWorkspaceData.count > 0 {
                        existedOwnWorkspace.onNext(.success(userWorkspaceData))
                    } else {
                        existedOwnWorkspace.onNext(.failure(.noneWorkspace))
                    }
                case .failure(let error):
                    if let commonError = error as? NetworkError.commonError {
                        print(commonError.errorMessage)
                    }
                }
            }
            .disposed(by: disposBag)
        
        let sharedExistedOwnWorkSpace = existedOwnWorkspace.share()
        
        return Output(
            workSpaceIsExist: sharedExistedOwnWorkSpace,
            makingButtonTap: input.makingButtonTap
        )
    }
}
