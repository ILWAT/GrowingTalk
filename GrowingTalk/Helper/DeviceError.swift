//
//  DeviceError.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/22/24.
//

import Foundation

protocol DeviceErrorProtocol: Error {
    var errorMessage: String { get }
}

enum DeviceError: DeviceErrorProtocol {
    case changeViewError
    case unknownError
    
    var errorMessage: String {
        get {
            switch self {
            case .changeViewError:
                return "화면 전환에 실패하였습니다."
            case .unknownError:
                return "알 수없는 에러가 발생했습니다. 앱 종료후 다시 시도해주세요."
            }
        }
    }
}
