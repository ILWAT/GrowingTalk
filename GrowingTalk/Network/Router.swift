//
//  Router.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/7/24.
//

import Foundation
import Moya

enum Router {
    case email(email: String)
    case signup(signupData: SignupModel)
    
}

extension Router: TargetType {
    var baseURL: URL {
        get{
           return URL(string: SecretKeys.severURL)!
        }
    }
    
    var path: String {
        switch self {
        case .signup:
            return "users/join"
        case .email:
            return "users/validation/email"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .email, .signup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .email(let email):
            return .requestJSONEncodable(email)
        case .signup(let signupData):
            return .requestJSONEncodable(signupData)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["SesacKey": SecretKeys.serverSecretKey]
        }
    }
    
    
}
