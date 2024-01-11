//
//  Router.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/7/24.
//

import Foundation
import Moya

enum Router {
    case email(email: CheckEmailBodyModel)
    case signup(signupData: SignupBodyModel)
    
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
            return "v1/users/join"
        case .email:
            return "v1/users/validation/email"
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
