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
        let makingButtonTap: ControlEvent<Void>
        let closeButtonTap: ControlEvent<Void>
    }
    
    let disposBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        return Output(
            makingButtonTap: input.makingButtonTap,
            closeButtonTap: input.closeButtonTap
        )
    }
}
