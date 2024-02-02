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
    case addWorkSpace(addWorkSpaceData: AddWorkSpaceBodyModel)
    case getAllWorkSpace
    case refreshAccessToken(refreshAccessTokenBodyModel: RefreshAccessTokenBodyModel)
    case specificChannelInfo(workSpaceID: Int, channelName: String)
    case getMyAllChannelInWorkspace(workSpaceID: Int)
    case getMyAllDMInWorkspace(workspaceID: Int)
    case getUserProfile
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
            return "/v1/users/join"
        case .email:
            return "/v1/users/validation/email"
        case .login_v2:
            return "/v2/users/login"
        case .addWorkSpace, .getAllWorkSpace:
            return"/v1/workspaces"
        case .refreshAccessToken:
            return "/v1/auth/refresh"
        case .specificChannelInfo(let workSpaceID, let workSpaceName):
            let workSpaceNameParameter = workSpaceName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? workSpaceName
            
            return "/v1/workspaces/\(workSpaceID)/channels/\(workSpaceNameParameter)"
        case .getMyAllChannelInWorkspace(let workSpaceID):
            return "/v1/workspaces/\(workSpaceID)/channels/my"
        case .getMyAllDMInWorkspace(let workspaceID):
            return "/v1/workspaces/\(workspaceID)/dms"
        case .getUserProfile:
            return "/v1/users/my"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .email, .signup, .addWorkSpace, .login_v2:
            return .post
        case .refreshAccessToken, .getAllWorkSpace, .specificChannelInfo, .getMyAllChannelInWorkspace, .getMyAllDMInWorkspace, .getUserProfile:
            return .get
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
        case .addWorkSpace(let addWorkSpaceData):
            let imageData = MultipartFormData(provider: .data(addWorkSpaceData.image), name: "image", fileName: "\(addWorkSpaceData.name).jpeg", mimeType: "image/jpeg")
            let nameData = MultipartFormData(provider: .data(addWorkSpaceData.name.data(using: .utf8)!), name: "name")
            
            var multipartData: [MultipartFormData] = [nameData, imageData]
            
            if let description = addWorkSpaceData.description?.data(using: .utf8) {
                let descriptionData = MultipartFormData(provider: .data(description), name: "description")
                multipartData.append(descriptionData)
            }
            return .uploadMultipart(multipartData)
        case .refreshAccessToken:
            return .requestPlain
        case .getAllWorkSpace, .specificChannelInfo, .getMyAllChannelInWorkspace, .getMyAllDMInWorkspace, .getUserProfile:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .refreshAccessToken:
            return [
                "SesacKey": SecretKeys.serverSecretKey,
                "RefreshToken" : UserDefaultsManager.shared.obtainTokenFromUserDefaults(tokenCase: .refreshToken)
            ]
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
