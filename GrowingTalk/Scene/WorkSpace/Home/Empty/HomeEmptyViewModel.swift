//
//  HomeViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/17/24.
//

import Foundation
import RxCocoa
import RxSwift

final class HomeEmptyViewModel: ViewModelType {
    struct Input {
        let addWorkSpaceButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let addWorkSpaceButtonTap: ControlEvent<Void>
    }
    
    func transform(_ input: Input) -> Output {
        
        return Output(
            addWorkSpaceButtonTap: input.addWorkSpaceButtonTap
        )
    }
}
