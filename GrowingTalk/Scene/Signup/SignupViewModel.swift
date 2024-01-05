//
//  SignupViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/5/24.
//

import Foundation
import RxCocoa
import RxSwift

final class SignupViewModel: ViewModelType {
    struct Input {
        let inputEmail: ControlProperty<String>
        let inputNickname: ControlProperty<String>
        let inputPhoneNumber: ControlProperty<String>
        let inputPassword: ControlProperty<String>
        let inputCheckPassword: ControlProperty<String>
        let signUpButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let activeCheckBtn: Driver<Bool>
    }
    
    //MARK: - disposeBag Properties
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let activeCheckBtn = PublishSubject<Bool>()
        let requestable = BehaviorSubject(value: false)
        
        let inputEmail = input.inputEmail
            .asDriver()
        
        inputEmail
            .filter({ $0.isEmpty })
            .drive(with: self) { owner, _ in
                activeCheckBtn.onNext(false)
            }
            .disposed(by: disposeBag)
        
        inputEmail
            .filter({ !$0.isEmpty })
            .drive(with: self) { owner, email in
                activeCheckBtn.onNext(true)
                
                if owner.isValidEmail(email) {
                    requestable.onNext(true)
                } else {
                    requestable.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            activeCheckBtn: activeCheckBtn.asDriver(onErrorJustReturn: false)
        )
    }
}

extension SignupViewModel {
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

}
