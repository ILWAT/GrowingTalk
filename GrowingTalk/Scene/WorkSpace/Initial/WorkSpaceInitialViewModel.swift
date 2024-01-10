//
//  WorkSpaceViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/10/24.
//

import Foundation
import RxCocoa
import RxSwift

final class WorkSpaceInitialViewModel: ViewModelType {
    struct Input {
        let userData: PublishRelay<SignupResultModel>
        let buttonTap: ControlEvent<Void>
    }
    
    struct Output {
        let subTitleText: Driver<String>
        let buttonTap: ControlEvent<Void>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let subTitleText = PublishRelay<String>()
        
        input.userData
            .debug("viewModel")
            .subscribe(with: self) { owner, userData in
                subTitleText.accept("\(userData.nickname)의 조직을 위해 새로운 새싹톡 워크스페이스를 시작할 준비가 완료되었어요!")
            }
            .disposed(by: disposeBag)
        
        return Output(
            subTitleText: subTitleText.asDriver(onErrorJustReturn: ""),
            buttonTap: input.buttonTap
        )
    }
}
