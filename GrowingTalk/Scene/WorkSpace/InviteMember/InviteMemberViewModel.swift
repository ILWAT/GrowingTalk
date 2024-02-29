//
//  InviteMemberViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/14/24.
//

import Foundation
import RxCocoa
import RxSwift

final class InviteMemberViewModel: ViewModelType {
    struct Input {
        let workspaceID: Int
        let closeButtonTap: ControlEvent<Void>
        let inputEmailText: ControlProperty<String>
        let inviteButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let closeButtonTap: ControlEvent<Void>
        let buttonEnable: Driver<Bool>
        let inviteMemberRequestSuccess: Driver<UserInfoModel>
        let toastMessage: Driver<String>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let buttonValidation = PublishRelay<Bool>()
        let inviteMemberRequestSuccess = PublishSubject<UserInfoModel>()
        let toastMessage = PublishRelay<String>()
        
        input.inputEmailText
            .subscribe(with: self) { owner, email in
                if !email.isEmpty && email.isValidEmail {
                    buttonValidation.accept(true)
                } else {
                    buttonValidation.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.inviteButtonTap
            .withLatestFrom(input.inputEmailText)
            .flatMapLatest { email in
                APIManger.shared.requestByRx(requestType: .inviteWorkspaceMember(workspaceID: input.workspaceID, email: .init(email: email)), decodableType: UserInfoModel.self, defaultErrorType: NetworkError.InviteWorkspaceMember.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let userInfo):
                    print(userInfo)
                    inviteMemberRequestSuccess.onNext(userInfo)
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.InviteWorkspaceMember.self)
                    print(errorMessage)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            closeButtonTap: input.closeButtonTap,
            buttonEnable: buttonValidation.asDriver(onErrorJustReturn: false), 
            inviteMemberRequestSuccess: inviteMemberRequestSuccess.asDriver(onErrorJustReturn: UserInfoModel(userId: 0, email: "", nickname: "", profileImage: nil)),
            toastMessage: toastMessage.asDriver(onErrorJustReturn: "")
        )
    }
}
