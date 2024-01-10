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
        let checkEmailButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let activeCheckBtn: Driver<Bool>
        let checkEmailToast: Driver<SignupToastMessageCase>
        let activeSignupBtn: Driver<Bool>
        let filteringPhoneNUmber: Driver<String>
        let requiredData: Driver<[SignupRequiredCase]>
        let signupResult: Driver<SignupResultModel>
    }
    
    //MARK: - disposeBag Properties
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let checkBtnActive = PublishSubject<Bool>() //이메일 체크 버튼 활성화: 한글자도 입력받으면 활성화됨
        let emailRequestable = BehaviorSubject(value: false) //유효성 검사 통과에 대한 값
        let emailIsUsable = BehaviorSubject(value: false) //이메일 중복확인에 대한 값
        let toastMessage = PublishRelay<SignupToastMessageCase>() //이메일 중복 확인에 대한 결과 값
        let signupBtnActive = BehaviorRelay(value: false)
        let patternedNumber = PublishRelay<String>() //"-" 들어간 전화번호
        let passwordMatch = BehaviorSubject(value: false)
        let passwordCorrect = BehaviorSubject(value: false)
        let nicknameIsUsable = BehaviorSubject(value: false)
        let requiredData = PublishSubject<[SignupRequiredCase]>()
        let signupResultSubject = PublishSubject<SignupResultModel>()
        
        let inputEmail = input.inputEmail
            .asDriver()
        
        inputEmail
            .filter({ $0.isEmpty })
            .drive(with: self) { owner, email in
                emailIsUsable.onNext(false)
                checkBtnActive.onNext(false)
            }
            .disposed(by: disposeBag)
        
        inputEmail
            .filter({ !$0.isEmpty })
            .drive(with: self) { owner, email in
                emailIsUsable.onNext(false)
                checkBtnActive.onNext(true)
                
                emailRequestable.onNext(owner.isValidEmail(email)) //유효성 검사를 통한 request가능 여부
                
            }
            .disposed(by: disposeBag)
        
        //MARK: E-mail 중복 확인 버튼
        let checkEmailBTNTap = input.checkEmailButtonTap.share(replay: 0, scope: .whileConnected)
        
        checkEmailBTNTap
            .withLatestFrom(emailRequestable)
            .filter({ !$0 })
            .subscribe(with: self) { owner, _ in
                toastMessage.accept(.emilNotValid)
            }
            .disposed(by: disposeBag)
        
        //이메일 중복 확인 서버 통신 여부 로직
        let emailValidedState = checkEmailBTNTap
            .withLatestFrom(emailRequestable)
            .filter({ $0 })
            .withLatestFrom(emailIsUsable)
        
        //이미 검증된 상태
        emailValidedState
            .filter({ $0 })
            .subscribe(with: self) { owner, _ in
                toastMessage.accept(.emailIsValid)
            }
            .disposed(by: disposeBag)
        
        //검증 안된 상태
        emailValidedState
            .filter({ !$0 })
            .withLatestFrom(input.inputEmail)
            .flatMapLatest { email in
                APIManger.shared.requestByRxNoResponse(requestType: .email(email: CheckEmailBodyModel(email: email)))
            }
            .debug("ViewModel Network")
            .subscribe(with: self) { owner, result in
                switch result {
                case .success:
                    print("성공")
                    toastMessage.accept(.emailIsValid)
                    emailIsUsable.onNext(true)
                case .failure(let error):
                    emailIsUsable.onNext(false)
                    print(error)
                    if let errorType = error as? NetworkError.commonError {
                        print(errorType.errorMessage)
                    }
                    if let errorType = error as? NetworkError.checkEmailError {
                        switch errorType {
                        case .wrongRequest:
                            toastMessage.accept(.emilNotValid)
                        case .duplicatedData:
                            toastMessage.accept(.emailDuplicated)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        //MARK: 닉네임
        input.inputNickname
            .subscribe(with: self) { owner, nickname in
                if nickname.count < 1 && nickname.count >= 30 { toastMessage.accept(.nicknameNotValid) }
                else { nicknameIsUsable.onNext(true)}
            }
            .disposed(by: disposeBag)
        
        
        //MARK: 연락처
        input.inputPhoneNumber
            .subscribe(with: self) { owner, phoneNumber in
                patternedNumber.accept(phoneNumber.convertPhoneNumber())
            }
            .disposed(by: disposeBag)
        
        //MARK: 비밀번호
        //비밀번호 정규식
        input.inputPassword
            .subscribe(with: self) { owner, password in
                passwordCorrect.onNext(owner.isValidPassword(password))
            }
            .disposed(by: disposeBag)
        
        //비밀번호 확인
        Observable.combineLatest(input.inputPassword, input.inputCheckPassword)
            .subscribe(with: self) { owner, allValues in
                if allValues.0 == allValues.1 { passwordMatch.onNext(true) }
                else { passwordMatch.onNext(false) }
            }
            .disposed(by: disposeBag)
        
        //MARK: 가입하기 버튼
        //가입하기 버튼 활성화 조건
        Observable.combineLatest(input.inputEmail, input.inputNickname, input.inputCheckPassword, input.inputCheckPassword)
            .subscribe(with: self) { owner, allValue in
                if !allValue.0.isEmpty && !allValue.1.isEmpty && !allValue.2.isEmpty && !allValue.3.isEmpty
                {
                    signupBtnActive.accept(true)
                } else {
                    signupBtnActive.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        let signupButtonTapFlow = input.signUpButtonTap
            .withLatestFrom(Observable.combineLatest(emailIsUsable, nicknameIsUsable, passwordCorrect, passwordMatch))
        
        signupButtonTapFlow
            .debug("not Valid")
            .filter { allValues in
                !(allValues.0 && allValues.1 && allValues.2 && allValues.3)
            }
            .subscribe(with: self) { owner, userData in
                var requiredDataArray: [SignupRequiredCase] = []
                if !userData.0 {
                    requiredDataArray.append(.email)
                }
                if !userData.1 {
                    requiredDataArray.append(.nickname)
                }
                if !userData.2 {
                    requiredDataArray.append(.password)
                }
                if !userData.3 {
                    requiredDataArray.append(.checkPassword)
                }
                requiredData.onNext(requiredDataArray)
            }
            .disposed(by: disposeBag)
        
        //회원가입 통신
        signupButtonTapFlow
            .debug("valid")
            .filter { allValues in
                allValues.0 && allValues.1 && allValues.2 && allValues.3
            }
            .withLatestFrom(Observable.combineLatest(input.inputEmail, input.inputPassword, input.inputNickname, input.inputPhoneNumber))
            .flatMapLatest { userData in
                APIManger.shared.requestByRx(requestType: .signup(signupData: SignupBodyModel(email: userData.0, password: userData.1, nickname: userData.2, phone: userData.3, deviceToken: nil)), decodableType: SignupResultModel.self)
            }
            .subscribe(with: self) { owner, response in
                switch response{
                case .success(let resultModel):
                    print(resultModel)
                    
                    TokenManger.shared.saveTokenInUserDefaults(tokenData: resultModel.token.accessToken, tokenCase: .accessToken)
                    TokenManger.shared.saveTokenInUserDefaults(tokenData: resultModel.token.refreshToken, tokenCase: .refreshToken)
                    
                    signupResultSubject.onNext(resultModel)
                    
                case .failure(let error):
                    if let commonError = error as? NetworkError.commonError {
                        print(commonError, commonError.errorMessage)
                    } else if let signupError = error as? NetworkError.checkEmailError {
                        print(signupError, signupError.errorMessage)
                    }
                    toastMessage.accept(.etc)
                }
            }
            .disposed(by: disposeBag)
        
        requiredData
            .subscribe(with: self) { owner, requiredDatas in
                if let firstRequired = requiredDatas.first {
                    switch firstRequired {
                    case .email:
                        toastMessage.accept(.emailNotChecked)
                    case .nickname:
                        toastMessage.accept(.nicknameNotValid)
                    case .password:
                        toastMessage.accept(.passwordNotValid)
                    case .checkPassword:
                        toastMessage.accept(.passwordNotMatch)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            activeCheckBtn: checkBtnActive.asDriver(onErrorJustReturn: false),
            checkEmailToast: toastMessage.asDriver(onErrorJustReturn: .emilNotValid),
            activeSignupBtn: signupBtnActive.asDriver(onErrorJustReturn: false),
            filteringPhoneNUmber: patternedNumber.asDriver(onErrorJustReturn: ""),
            requiredData: requiredData.asDriver(onErrorJustReturn: []),
            signupResult: signupResultSubject.asDriver(onErrorJustReturn: .init(userId: 0, email: "", nickname: "", profileImage: nil, phone: "", vendor: nil, createdAt: "", token: .init(accessToken: "", refreshToken: "")))
        )
    }
}

extension SignupViewModel {
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}$"
        
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

}
