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
        
    }
    
    struct Output {
        let userOwnWorkspace: Driver<[GetUserWorkSpaceResultModel]>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let workSpaceData = BehaviorSubject<[GetUserWorkSpaceResultModel]>(value: [])
        
        APIManger.shared.requestByRx(requestType: .getAllWorkSpace, decodableType: [GetUserWorkSpaceResultModel].self, defaultErrorType: NetworkError.GetUserWorkSpaceError.self)
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
        
        return Output(
            userOwnWorkspace: workSpaceData.asDriver(onErrorJustReturn: [])
        )
    }
}
