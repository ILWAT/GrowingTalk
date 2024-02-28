//
//  SocketRouter.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/28/24.
//

import Foundation

enum SocketRouter {
    case channel(id: Int)
    
    var baseUrlPath: String {
        switch self {
        case .channel:
            return SecretKeys.serverURL
        }
    }
    
    var endPoint: String {
        switch self {
        case .channel(let id):
            return "/ws-channel-\(id)"
        }
    }
    
    var receivedEventType: String {
        switch self {
        case .channel:
            return "channel"
        }
    }
}
