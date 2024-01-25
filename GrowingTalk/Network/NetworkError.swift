//
//  NetworkError.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/8/24.
//

import Foundation

protocol NetworkErrorProtocol: RawRepresentable, Error where RawValue == String{
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
        case decodedError = "decodedError"
        case unknownError = "unknownError"
        
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
    
    enum checkEmail_SignupError: String, NetworkErrorProtocol{
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
    
    enum AddWorkSpaceErrorCase: String, NetworkErrorProtocol {
        case wrongRequest = "E11"
        case duplicated = "E12"
        case noCoin = "E21"
        
        var errorMessage: String {
            switch self {
            case .wrongRequest:
                return "잘못된 요청입니다."
            case .duplicated:
                return "존재하는 스페이스 이름이 있습니다."
            case .noCoin:
                return "코인이 부족합니다."
            }
        }
    }
    
    
    enum LoginError: String, NetworkErrorProtocol{
        case failedLogin = "E03"
        
        var errorMessage: String {
            switch self {
            case .failedLogin:
                return "로그인에 실패하였습니다."
            }
        }
    }
    
    enum RefreshAccessTokenError: String, NetworkErrorProtocol {
        case validToken = "E04"
        case unknownAccount = "E03"
        case expiredRefreshToken = "E06"
        case failedValidation = "E02"
        
        var errorMessage: String{
            switch self {
            case .validToken:
                return "토큰이 아직 유효합니다."
            case .unknownAccount:
                return "알 수 없는 계정입니다."
            case .expiredRefreshToken:
                return "다시 로그인해주세요."
            case .failedValidation:
                return "인증에 실패하였습니다."
            }
        }
    }
    
    enum GetUserWorkSpaceError: String, NetworkErrorProtocol {
        case unknwonError
        case noneWorkspace
        
        var errorMessage: String {
            switch self {
            case .unknwonError:
                return "알 수 없는 에러"
            case .noneWorkspace:
                return "워크 스페이스가 없습니다."
            }
        }
    }
    
    enum GetMyChannelError: String, NetworkErrorProtocol {
        case noneData = "E13"
        
        var errorMessage: String{
            switch self {
            case .noneData:
                return "존재하지 않는 데이터입니다."
            }
        }
    }
    
    enum GetMyAllDMInWorkspaceError: String, NetworkErrorProtocol {
        case noneData = "E13"
        
        var errorMessage: String {
            switch self{
            case .noneData:
                return "존재하지 않는 데이터입니다."
            }
        }
    }
}
