//
//  SignupViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/5/24.
//

import Foundation
import RxCocoa
import RxSwift

enum emailCheckingCase: String{
    case notValid = "이메일 형식이 올바르지 않습니다."
    case isValid = "사용 가능한 이메일입니다."
    case duplicated = "이미 가입된 회원입니다. 로그인을 진행해주세요."
}

final class SignupViewModel: ViewModelType {
    struct Input {
        let inputEmail: ControlProperty<String>
        let inputNickname: ControlProperty<String>
        let inputPhoneNumber: ControlProperty<String>
        let inputPassword: ControlProperty<String>
        let inputCheckPassword: ControlProperty<String>
        let signUpButtonTap: ControlEvent<Void>
        let checkEmailButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let activeCheckBtn: Driver<Bool>
        let checkEmailToast: Driver<emailCheckingCase>
        let activeSignupBtn: Driver<Bool>
    }
    
    //MARK: - disposeBag Properties
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let activeCheckBtn = PublishSubject<Bool>() //이메일 체크 버튼 활성화: 한글자도 입력받으면 활성화됨
        let requestable = BehaviorSubject(value: false) //유효성 검사 통과에 대한 값
        let isChecked = BehaviorSubject(value: false) //이메일 중복확인에 대한 값
        let checkEmailToast = PublishRelay<emailCheckingCase>() //이메일 중복 확인에 대한 결과 값
        let activeSignupBtn = PublishRelay<Bool>()
        
        let inputEmail = input.inputEmail
            .asDriver()
        
        inputEmail
            .filter({ $0.isEmpty })
            .drive(with: self) { owner, email in
                activeCheckBtn.onNext(false)
            }
            .disposed(by: disposeBag)
        
        inputEmail
            .filter({ !$0.isEmpty })
            .drive(with: self) { owner, email in
                activeCheckBtn.onNext(true)
                
                requestable.onNext(owner.isValidEmail(email)) //유효성 검사를 통한 request가능 여부
                
            }
            .disposed(by: disposeBag)
        
        input.checkEmailButtonTap
            .withLatestFrom(requestable)
            .filter({ !$0 })
            .debug("Check")
            .subscribe(with: self) { owner, _ in
                checkEmailToast.accept(.notValid)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.inputEmail, input.inputNickname, input.inputPassword, input.inputCheckPassword)
            .subscribe(with: self) { owner, allValue in
                if !allValue.0.isEmpty && !allValue.1.isEmpty && !allValue.2.isEmpty && !allValue.3.isEmpty
                {
                    activeSignupBtn.accept(true)
                } else {
                    activeSignupBtn.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            activeCheckBtn: activeCheckBtn.asDriver(onErrorJustReturn: false),
            checkEmailToast: checkEmailToast.asDriver(onErrorJustReturn: .notValid),
            activeSignupBtn: activeSignupBtn.asDriver(onErrorJustReturn: false)
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
