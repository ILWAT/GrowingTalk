//
//  WorkSpaceAddViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/14/24.
//

import UIKit
import RxCocoa
import RxSwift

final class WorkSpaceAddViewModel: ViewModelType {
    struct Input{
        let closeButtonTap: ControlEvent<()>
        let imgButtonTap: ControlEvent<Void>
        let imgAddButtonTap: ControlEvent<Void>
        let spaceNameText: ControlProperty<String>
        let spaceDiscriptionText: ControlProperty<String>
        let spaceImage: PublishRelay<UIImage?>
    }
    
    struct Output{
        let closeButtonTap: ControlEvent<()>
        let imgAddReactive: Driver<Void>
        let buttonActive: Driver<Bool>
        let toastMessage: Driver<ToastMessageCase.WorkSpaceAdd>
        let spaceImage: SharedSequence<DriverSharingStrategy, UIImage?>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let isValidSpaceName = PublishSubject<Bool>()
        let isValidSpaceImage = PublishSubject<Bool>()
        let buttonActive = PublishRelay<Bool>()
        let imgAddReactive = PublishRelay<Void>()
        let toastMessage = PublishRelay<ToastMessageCase.WorkSpaceAdd>()
        let requestSuccess = PublishRelay<Bool>()
        
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
                    toastMessage.accept(.nameIsNotValid)
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
            .withLatestFrom(Observable.combineLatest(input.spaceNameText, input.spaceDiscriptionText, input.spaceDiscriptionText))
//            .flatMap { allBodyValue in
//                <#code#>
//            }
        
        
        
        
        return Output(
            closeButtonTap: input.closeButtonTap,
            imgAddReactive:imgAddReactive.asDriver(onErrorJustReturn: ()),
            buttonActive: buttonActive.asDriver(onErrorJustReturn: false),
            toastMessage: toastMessage.asDriver(onErrorJustReturn: .etc),
            spaceImage: spaceImage
        )
    }
}
