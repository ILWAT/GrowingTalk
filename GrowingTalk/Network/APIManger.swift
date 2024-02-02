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
        UserDefaultsManager.shared.obtainTokenFromUserDefaults(tokenCase: .accessToken)
    })])
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    private init() {}
    
    func requestByRx<D:Decodable, E: NetworkErrorProtocol>(requestType: Router, decodableType: D.Type, defaultErrorType: E.Type) -> Single<Result<D, Error>>{
        return Single.create { single -> Disposable in
            self.provider.rx.request(requestType)
                .filterSuccessfulStatusCodes()
                .catch({ [weak self] error in
                    guard let moyaError = error as? MoyaError else { throw NetworkError.commonError.unknownError }
                    
                    guard let decodedError = try? moyaError.response?.map(NetworkErrorModel.self) else {
                        single(.success(.failure(NetworkError.commonError.decodedError)))
                        throw moyaError
                    }
                    
                    if let errorType = NetworkError.commonError(rawValue: decodedError.errorCode) {
                        if errorType == .expiredToken {
                            return try self!.requestRefreshTokenAPI()
                        } else {                            single(.success(.failure(errorType)))
                            throw errorType
                        }
                        
                    } else if let errorType = E.init(rawValue: decodedError.errorCode) {
                        single(.success(.failure(errorType)))
                        throw errorType
                    } else {
                        throw moyaError
                    }
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
                        single(.success(.failure(error)))
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
    
    func requestRefreshTokenAPI() throws -> PrimitiveSequence<SingleTrait, Response> {
        
        return Single.create { single in
            self.provider.request(.refreshAccessToken(refreshAccessTokenBodyModel: RefreshAccessTokenBodyModel(RefreshToken: UserDefaultsManager.shared.obtainTokenFromUserDefaults(tokenCase: .refreshToken)))){ result in
                switch result {
                case .success(let response):
                    do {
                        let successResponse = try response.filterSuccessfulStatusCodes()
                        guard let decodedData = try? successResponse.map(RefreshAccessTokenResultModel.self) else { return single(.failure(NetworkError.commonError.decodedError)) }
                        UserDefaultsManager.shared.saveTokenInUserDefaults(tokenData: decodedData.accessToken, tokenCase: .accessToken)
                        single(.failure(NetworkError.RefreshAccessTokenError.intentionalError))
                    } catch let error {
                        guard let moyaError = error as? MoyaError else { return single(.failure(NetworkError.commonError.unknownError)) }
                        guard let decodedError =  try? moyaError.response?.map(NetworkErrorModel.self) else { return single(.failure(NetworkError.commonError.decodedError)) }
                        if let refreshError = NetworkError.RefreshAccessTokenError(rawValue: decodedError.errorCode) {
                            return single(.failure(refreshError))
                        } else if let commonError = NetworkError.commonError(rawValue: decodedError.errorCode) {
                            single(.failure(commonError))
                        }
                    }
                case .failure(let moyaError):
                    single(.failure(moyaError))
                }
            }
            return Disposables.create()
        }
    }
}
