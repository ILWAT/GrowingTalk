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
    
    func requestByRx<D:Decodable, E: NetworkErrorProtocol>(requestType: Router, decodableType: D.Type, defaultErrorType: E.Type) -> Single<Result<D, Error>>{
        return Single.create { single -> Disposable in
            self.provider.rx.request(requestType)
                .filterSuccessfulStatusCodes()
                .catch({ error in
                    guard let moyaError = error as? MoyaError else { throw NetworkError.commonError.unknownError }
                    guard let decodedError = try? moyaError.response?.map(NetworkErrorModel.self) else {
                        single(.success(.failure(NetworkError.commonError.decodedError)))
                        throw moyaError
                    }
                    if let errorType = NetworkError.commonError(rawValue: decodedError.errorCode) {
                        if errorType == .expiredToken {
                            //토큰 갱신 로직 구현
                            throw errorType
                        } else {
                            single(.success(.failure(errorType)))
                            throw errorType
                        }
                        
                    } else if let errorType = E.init(rawValue: decodedError.errorCode) {
                        single(.success(.failure(errorType)))
                        throw errorType
                    }
                    throw moyaError
                })
                .retry(3)
                .subscribe({ event in
                    switch event {
                    case .success(let response):
                        guard let decodedData = try? response.map(decodableType.self) else {
                            return single(.success(.failure(NetworkError.commonError.decodedError)))
                        }
                        single(.success(.success(decodedData)))
                        
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
                        guard let moyaError = error as? MoyaError else {return single(.success(.failure(NetworkError.commonError.unknownError))) }
                        guard let decodedError = try? moyaError.response?.map(NetworkErrorModel.self) else { return single(.success(.failure(NetworkError.commonError.decodedError))) }
                        if let errorType = NetworkError.checkEmail_SignupError(rawValue: decodedError.errorCode) {
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
