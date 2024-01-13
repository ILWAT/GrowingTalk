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
    case login_v2(body: LoginBodyModel)
    
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
        case .login_v2:
            return "v2/users/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .email, .signup, .login_v2:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .email(let body):
            return .requestJSONEncodable(body)
        case .signup(let body):
            return .requestJSONEncodable(body)
        case .login_v2(let body):
            return .requestJSONEncodable(body)
            
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["SesacKey": SecretKeys.serverSecretKey]
        }
    }
    
    
}


extension Router: AccessTokenAuthorizable{
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        case .email, .login_v2, .signup:
            return .none
        default:
            return .custom("")
        }
    }
}
