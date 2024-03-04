//
//  CoinShopViewModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 3/1/24.
//

import Foundation
import RxCocoa
import RxSwift
import iamport_ios

final class CoinShopViewModel: ViewModelType {
    typealias CoinShopCellItem = CoinShopViewController.CoinShopCellItem
    
    struct Input {
        let selectedItem: Observable<CoinShopViewController.CoinShopCellItem?>
        let paymentResultSubject: PublishSubject<IamportResponse?>
    }
    
    struct Output {
        let userCoin: Driver<CoinShopCellItem>
        let coinShopItems: Driver<[CoinShopCellItem]>
        let paymentSubject: PublishSubject<IamportPayment>
        let toastMessage: Driver<String>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let willUserCoinUpdate = BehaviorSubject(value: ())
        let userCoin = BehaviorRelay<CoinShopCellItem>(value: .init(section: .status, title: "0", description: "코인이란?"))
        let coinItemSubject = PublishRelay<[CoinShopCellItem]>()
        let paymentSubject = PublishSubject<IamportPayment>()
        let postPaymentResultToServer = PublishSubject<PostPaymentValidationModel>()
        let toastMessage = PublishRelay<String>()
        
        willUserCoinUpdate
            .flatMapLatest { _ in
                APIManger.shared.requestByRx(requestType: .getUserProfile, decodableType: GetUserProfileModel.self, defaultErrorType: NetworkError.commonError.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let userProfile):
                    let coinStatusData = CoinShopCellItem(section: .status, title: "\(userProfile.sesacCoin)", description: "코인이란?")
                    userCoin.accept(coinStatusData)
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.commonError.self)
                    print(errorMessage)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        APIManger.shared.requestByRx(requestType: .getCoinShopItem, decodableType: [CoinShopItemModel].self, defaultErrorType: NetworkError.commonError.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let items):
                    let itemToShow = items.map { itemModel in
                        return CoinShopViewController.CoinShopCellItem(section: .coinItem, title: itemModel.item, description: itemModel.amount)
                    }
                    coinItemSubject.accept(itemToShow)
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.commonError.self)
                    print(errorMessage)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        input.selectedItem
            .subscribe(with: self, onNext: { owner, coinItem in
                guard let coinItem else {return}
                if coinItem.section == .coinItem {
                    let payment = IamportPayment(
                        pg: PG.html5_inicis.makePgRawName(pgId: SecretKeys.portOnePGID),
                        merchant_uid: "ios_\(SecretKeys.serverSecretKey)_\(Int(Date().timeIntervalSince1970))",
                        amount: coinItem.description).then {              // 가격
                            $0.pay_method = PayMethod.card.rawValue   // 결제수단
                            $0.name = "\(coinItem.title)"                // 주문명
                            $0.buyer_name = "문일왓"
                            $0.app_scheme = "GrowingTalk"                   // 결제 후 앱으로 복귀 위한 app scheme
                        }
                    
                        paymentSubject.onNext(payment)
                } else {
                    toastMessage.accept("코인 설명입니다!")
                }
            })
            .disposed(by: disposeBag)
        
        input.paymentResultSubject
            .subscribe(with: self) { owner, iamportResponse in
                if let iamportResponse, let imp_uid = iamportResponse.imp_uid, let merchant_uid = iamportResponse.merchant_uid{
                    let bodyData = PostPaymentValidationModel(
                        imp_uid: imp_uid,
                        merchant_uid: merchant_uid
                    )
                    postPaymentResultToServer.onNext(bodyData)
                } else {
                    toastMessage.accept("결제중 오류가 발생했습니다.")
                }
            }
            .disposed(by: disposeBag)
        
        postPaymentResultToServer
            .flatMapLatest { bodyData in
                APIManger.shared.requestByRx(requestType: .postPayedCoinValidation(bodyModel: bodyData), decodableType: PostPaymentValidationResultModel.self, defaultErrorType: NetworkError.PostPaymentValidationError.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let paymentValidation):
                    if paymentValidation.success {
                        willUserCoinUpdate.onNext(())
                        toastMessage.accept("코인 충전에 성공했습니다! :)")
                    }
                case .failure(let error):
                    let errorMessage = APIManger.shared.changeErrorToString(error: error, targetError: NetworkError.PostPaymentValidationError.self)
                    print(errorMessage, error)
                    toastMessage.accept(errorMessage)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            userCoin: userCoin.asDriver(),
            coinShopItems: coinItemSubject.asDriver(onErrorJustReturn: []),
            paymentSubject: paymentSubject,
            toastMessage: toastMessage.asDriver(onErrorJustReturn: DeviceError.unknownError.errorMessage)
        )
    }
}
