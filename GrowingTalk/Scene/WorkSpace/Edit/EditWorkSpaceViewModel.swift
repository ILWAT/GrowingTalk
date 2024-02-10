//
//  EditWorkSpaceViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/10/24.
//

import UIKit
import RxCocoa
import RxSwift

final class EditWorkSpaceViewModel: ViewModelType {
    struct Input{
        let workspaceID: Int
        let userID: Int
        let closeButtonTap: ControlEvent<()>
        let imgButtonTap: ControlEvent<Void>
        let imgAddButtonTap: ControlEvent<Void>
        let spaceNameText: ControlProperty<String>
        let spaceDiscriptionText: ControlProperty<String>
        let spaceImage: PublishRelay<UIImage?>
        let completeButtonTap: ControlEvent<Void>
    }
    
    struct Output{
        let closeButtonTap: ControlEvent<()>
        let imgAddReactive: Driver<Void>
        let buttonActive: Driver<Bool>
        let toastMessage: Driver<String>
        let spaceImage: SharedSequence<DriverSharingStrategy, UIImage?>
        let editedWorkspaceInfo: Driver<GetUserWorkSpaceResultModel>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let isValidSpaceName = PublishSubject<Bool>()
        let isValidSpaceImage = PublishSubject<Bool>()
        let buttonActive = PublishRelay<Bool>()
        let imgAddReactive = PublishRelay<Void>()
        let toastMessage = PublishRelay<String>()
        let requestSuccess = PublishRelay<GetUserWorkSpaceResultModel>()
        
        let spaceImage = input.spaceImage.asDriver(onErrorJustReturn: UIImage(named: "WorkSpace"))
        let spaceNameText = input.spaceNameText.share()
        
        spaceNameText
            .filter({ !$0.isEmpty })
            .subscribe(with: self) { owner, nameText in
                let nameTextCount = nameText.count
                if nameTextCount <= 30 {
                    isValidSpaceName.onNext(true)
                } else {
                    isValidSpaceName.onNext(false)
                    toastMessage.accept(ToastMessageCase.WorkSpaceAdd.nameIsNotValid.rawValue)
                }
            }
            .disposed(by: disposeBag)
        
        spaceNameText
            .filter({ $0.isEmpty })
            .subscribe(with: self) { owner, _ in
                buttonActive.accept(false)
            }
            .disposed(by: disposeBag)
        
        Observable.of(input.imgAddButtonTap, input.imgButtonTap)
            .merge()
            .subscribe(with: self) { owner, _ in
                imgAddReactive.accept(())
            }
            .disposed(by: disposeBag)
        
        spaceImage
            .drive(with: self) { owner, image in
                guard image != nil else {
                    isValidSpaceImage.onNext(false)
                    return
                }
                isValidSpaceImage.onNext(true)
            }
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(isValidSpaceName, isValidSpaceImage)
            .filter({ $0.0 && $0.1 })
            .subscribe(with: self) { onwer, value in
                buttonActive.accept(true)
            }
            .disposed(by: disposeBag)
        
        input.completeButtonTap
            .withLatestFrom(Observable.combineLatest(input.spaceNameText, input.spaceDiscriptionText, input.spaceImage))
            .flatMap { allBodyValue in
                //이미지 용량 Compression
                guard let imageData = allBodyValue.2?.compressionUnderMBjpegData(megabyteSize: 1) else {
                    toastMessage.accept(ToastMessageCase.WorkSpaceAdd.imageRequired.rawValue)
                    return Single<Result<GetUserWorkSpaceResultModel, Error>>.just(.failure(NetworkError.EditWorkSpaceError.wrongRequest))
                }
                
                return APIManger.shared.requestByRx(requestType: .editWorkspace(workSpaceID: input.workspaceID, workspaceData: .init(name: allBodyValue.0, description: allBodyValue.1, image: imageData)), decodableType: GetUserWorkSpaceResultModel.self, defaultErrorType: NetworkError.EditWorkSpaceError.self)
            }
            .subscribe(with: self) { owner, result in
                switch result{
                case .success(let resultData):
                    print(resultData)
                    requestSuccess.accept(resultData)
                case .failure(let error):
                    if let commonError  = error as? NetworkError.commonError{
                        toastMessage.accept(commonError.errorMessage)
                    } else if let addError = error as? NetworkError.EditWorkSpaceError{
                        toastMessage.accept(addError.errorMessage)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            closeButtonTap: input.closeButtonTap,
            imgAddReactive:imgAddReactive.asDriver(onErrorJustReturn: ()),
            buttonActive: buttonActive.asDriver(onErrorJustReturn: false),
            toastMessage: toastMessage.asDriver(onErrorJustReturn: NetworkError.commonError.unknownError.errorMessage),
            spaceImage: spaceImage,
            editedWorkspaceInfo: requestSuccess.asDriver(onErrorJustReturn: .init(workspace_id: 0, name: "", description: "", thumbnail: "", owner_id: 0, createdAt: ""))
        )
    }
}
