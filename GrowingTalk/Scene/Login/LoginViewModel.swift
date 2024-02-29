//
//  LoginViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/12/24.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import FirebaseMessaging

final class LoginViewModel: ViewModelType {
    struct Input {
        let closeButtonTap: ControlEvent<()>
        let idText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let closebuttonTap: Driver<()>
        let wrongType: Driver<Result<Void, LoginWrongTypeCase>>
        let LoginButtonActive: Driver<Bool>
//        let userHaveWorkspace: Driver<Bool>
        let usersOwnWorkspace: PublishSubject<[WorkSpaceModel]>
        let loginResult: PublishSubject<LoginResultModel_V2>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let idValidation = PublishSubject<Bool>()
        let passwordValidation = PublishSubject<Bool>()
        let wrongType = PublishRelay<Result<Void,LoginWrongTypeCase>>()
        let loginButtonActive = BehaviorRelay(value: false)
        let loginResult = PublishSubject<LoginResultModel_V2>()
        let usersWorkspaces = PublishSubject<[WorkSpaceModel]>()
        let fcmTrigger = PublishSubject<String>()
        
        let inputIDText = input.idText.share()
        let inputPasswordText = input.passwordText.share()
        
        inputIDText
            .subscribe(with: self) { owner, id in
                guard !id.isEmpty else {
                    loginButtonActive.accept(false)
                    idValidation.onNext(false)
                    return
                }
                guard id.isValidEmail else {
                    idValidation.onNext(false)
                    return
                }
                
                idValidation.onNext(true)
            }
            .disposed(by: disposeBag)
        
        inputPasswordText
            .subscribe(with: self) { owner, password in
                guard !password.isEmpty else {
                    loginButtonActive.accept(false)
                    passwordValidation.onNext(false)
                    return
                }
                guard password.isValidPassword else {
                    passwordValidation.onNext(false)
                    return
                }
                passwordValidation.onNext(true)
            }
            .disposed(by: disposeBag)
        
        let allText = Observable.combineLatest(inputIDText, inputPasswordText)
            .share()
        
        allText
            .filter({ !($0.0.isEmpty || $0.1.isEmpty) })
            .subscribe(with: self) { owner, allTextElement in
                loginButtonActive.accept(true)
            }
            .disposed(by: disposeBag)
        
        let allValidation = Observable.combineLatest(idValidation, passwordValidation)
            .share()
        
        input.loginButtonTap
            .withLatestFrom(allValidation)
            .filter({ !($0.0 && $0.1) })
            .subscribe(with: self) { owner, allValidation in
                if allValidation.0 && allValidation.1 {
                    wrongType.accept(.success(()))
                } else if !allValidation.0 {
                    wrongType.accept(.failure(.id))
                } else if !allValidation.1 {
                    wrongType.accept(.failure(.password))
                } else {
                    wrongType.accept(.failure(.all))
                }
            }
            .disposed(by: disposeBag)
        
        input.loginButtonTap
            .withLatestFrom(allValidation)
            .filter({ $0.0 && $0.1 })
            .withLatestFrom(allText)
            .flatMapLatest { loginValue in
                APIManger.shared.requestByRx(requestType: .login_v2(body: LoginBodyModel(email: loginValue.0, password: loginValue.1, deviceToken: nil)), decodableType: LoginResultModel_V2.self, defaultErrorType: NetworkError.LoginError.self)
            }
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let response):
                    print("response", response)
                    UserDefaultsManager.shared.saveTokenInUserDefaults(tokenData: response.token.accessToken, tokenCase: .accessToken)
                    UserDefaultsManager.shared.saveTokenInUserDefaults(tokenData: response.token.refreshToken, tokenCase: .refreshToken)
                    UserDefaults.standard.setValue(response.email, forKey: "currentUser")
                    Messaging.messaging().token { token, error in
                        if let error = error {
                            print("Error fetching FCM registration token: \(error)")
                        } else if let token = token {
                            print("FCM registration token: \(token)")
                            fcmTrigger.onNext(token)
                        }
                    }
                    loginResult.onNext(response)
                    
                case .failure(let error):
                    if let commonError = error as? NetworkError.commonError {
                        print(commonError, commonError.errorMessage)
                    } else if let failedLogin = error as? NetworkError.LoginError {
                        print(failedLogin, failedLogin.errorMessage)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        loginResult
            .flatMapLatest { resultModel in
                APIManger.shared.requestByRx(requestType: .getAllWorkSpace, decodableType: [WorkSpaceModel].self, defaultErrorType: NetworkError.GetUserWorkSpaceError.self)
            }
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let response):
                    usersWorkspaces.onNext(response)
                    
                case .failure(let error):
                    if let commonError = error as? NetworkError.commonError {
                        print(commonError, commonError.errorMessage)
                    } else if let getWorkspaceError = error as? NetworkError.GetUserWorkSpaceError {
                        print(getWorkspaceError)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        fcmTrigger
            .flatMapLatest({ token in
                APIManger.shared.requestNoresponseByRx(requestType: .registFCMToken(deviceToken: FCMDeviceTokenModel(deviceToken: token)), defaultErrorType: NetworkError.RegistDeviceTokenError.self)
            })
            .subscribe(with: self) { owner, resposne in
                switch resposne {
                case .success(_):
                    print("FCM Regist Success")
                case .failure(let error):
                    print("FCM Regist failed", error)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output (
            closebuttonTap: input.closeButtonTap.asDriver(),
            wrongType: wrongType.asDriver(onErrorJustReturn: .failure(.all)), 
            LoginButtonActive: loginButtonActive.asDriver(),
            usersOwnWorkspace: usersWorkspaces,
            loginResult: loginResult
        )
    }
}
