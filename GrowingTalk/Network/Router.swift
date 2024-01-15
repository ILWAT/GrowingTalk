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
<<<<<<< HEAD
    case login_v2(body: LoginBodyModel)
    
=======
    case addWorkSpace(addWorkSpaceData: AddWorkSpaceBodyModel)
>>>>>>> ab57151 ([Feat] - #15 워크스페이스 생성 기능 구현 백업)
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
<<<<<<< HEAD
        case .login_v2:
            return "v2/users/login"
=======
        case .addWorkSpace:
            return"v1/workspaces"
>>>>>>> ab57151 ([Feat] - #15 워크스페이스 생성 기능 구현 백업)
        }
    }
    
    var method: Moya.Method {
        switch self {
<<<<<<< HEAD
        case .email, .signup, .login_v2:
=======
        case .email, .signup, .addWorkSpace:
>>>>>>> ab57151 ([Feat] - #15 워크스페이스 생성 기능 구현 백업)
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
<<<<<<< HEAD
        case .email(let body):
            return .requestJSONEncodable(body)
        case .signup(let body):
            return .requestJSONEncodable(body)
        case .login_v2(let body):
            return .requestJSONEncodable(body)
            
=======
        case .email(let email):
            return .requestJSONEncodable(email)
        case .signup(let signupData):
            return .requestJSONEncodable(signupData)
        case .addWorkSpace(let addWorkSpaceData):
            let imageData = MultipartFormData(provider: .data(addWorkSpaceData.image), name: "image", fileName: "\(addWorkSpaceData.name).jpeg", mimeType: "image/jpeg")
            let nameData = MultipartFormData(provider: .data(addWorkSpaceData.name.data(using: .utf8)!), name: "name")
            
            var multipartData: [MultipartFormData] = [nameData, imageData]
            
            if let description = addWorkSpaceData.description?.data(using: .utf8) {
                let descriptionData = MultipartFormData(provider: .data(description), name: "description")
                multipartData.append(descriptionData)
            }
            return .uploadMultipart(multipartData)
>>>>>>> ab57151 ([Feat] - #15 워크스페이스 생성 기능 구현 백업)
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
