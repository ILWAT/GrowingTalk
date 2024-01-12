//
//  NetworkError.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/8/24.
//

import Foundation

protocol NetworkErrorProtocol: Error {
    var errorMessage: String { get }
}

enum NetworkError{
    
    enum commonError: String, NetworkErrorProtocol{
        case noneAccessAuth = "E01"
        case unknownPath = "E97"
        case expiredToken = "E05"
        case failedAuthToken = "E02"
        case unknownAccount = "E03"
        case overRequest = "E98"
        case ServerError = "E99"
        case decodedError
        case unknownError
        
        var errorMessage: String{
            switch self {
            case .noneAccessAuth:
                return "접근 권한이 없습니다."
            case .unknownPath:
                return "잘못된 라우터 경로입니다."
            case .expiredToken:
                return "액세스 토큰이 만료되었습니다."
            case .failedAuthToken:
                return "토큰 인증에 실패하였습니다."
            case .unknownAccount:
                return "알수 없는 계정입니다."
            case .overRequest:
                return "과호출 입니다."
            case .ServerError:
                return "서버 오류입니다."
            case .decodedError:
                return "네트워크 디코딩에 실패했습니다."
            case .unknownError:
                return "알 수 없는 에러가 발생했습니다."
            }
        }
    }
    
    enum checkEmailError: String, NetworkErrorProtocol{
        case wrongRequest = "E11"
        case duplicatedData = "E12"
        
        var errorMessage: String {
            switch self {
            case .wrongRequest:
                return "잘못된 요청입니다."
            case .duplicatedData:
                return "중복된 이메일입니다."
            }
        }
    }
    
    
    enum loginError: String, NetworkErrorProtocol{
        case failedLogin = "E03"
        
        var errorMessage: String {
            switch self {
            case .failedLogin:
                return "로그인에 실패하였습니다."
            }
        }
    }
    
}
