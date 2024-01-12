//
//  APIManger.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/8/24.
//

import Foundation
import Moya
import RxMoya
import RxSwift


final class APIManger {
    //MARK: - Properties
    static let shared = APIManger()
    
    let provider = MoyaProvider<Router>(plugins: [AccessTokenPlugin(tokenClosure: { _ in
        TokenManger.shared.obtainTokenFromUserDefaults(tokenCase: .accessToken)
    })])
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    private init() {}
    
    func requestByRx<D:Decodable>(requestType: Router,decodableType: D.Type) -> Single<Result<D, Error>>{
        return Single.create { single -> Disposable in
            self.provider.rx.request(requestType)
                .subscribe({ event in
                    switch event {
                    case .success(let response):
                        do {
                            let successResponse = try response.filter(statusCode: 200)
                            guard let decodedData = try? successResponse.map(decodableType.self) else {
                                return single(.success(.failure(NetworkError.commonError.decodedError)))
                            }
                            single(.success(.success(decodedData)))
                        } catch let error {
                            guard let decodedError = try? response.map(NetworkErrorModel.self) else { return single(.success(.failure(NetworkError.commonError.decodedError))) }
                            if let errorType = NetworkError.checkEmailError(rawValue: decodedError.errorCode) {
                                single(.success(.failure(errorType)))
                            } else if let errorType = NetworkError.commonError(rawValue: decodedError.errorCode) {
                                single(.success(.failure(errorType)))
                            }
                        }
                        
                    case .failure(let error):
                        single(.success(.failure(NetworkError.commonError.unknownError)))
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func requestByRxNoResponse(requestType: Router) -> Single<Result<Bool, Error>>{
        return Single.create { single -> Disposable in
            self.provider.rx.request(requestType)
                .debug()
                .subscribe({ event in
                switch event {
                case .success(let response):
                    do {
                        _ = try response.filter(statusCode: 200)
                        single(.success(.success(true)))
                    } catch let error {
                        guard let decodedError = try? response.map(NetworkErrorModel.self) else { return single(.success(.failure(NetworkError.commonError.decodedError)))}
                        if let errorType = NetworkError.checkEmailError(rawValue: decodedError.errorCode) {
                            single(.success(.failure(errorType)))
                        } else if let errorType = NetworkError.commonError(rawValue: decodedError.errorCode) {
                            single(.success(.failure(errorType)))
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    single(.success(.failure(NetworkError.commonError.unknownError)))
                }
            })
            .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
