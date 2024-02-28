//
//  SocketManager.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/28/24.
//

import Foundation
import SocketIO
import RxSwift

final class SocketControlManager {
    
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    
    init(target: SocketRouter) {
        self.manager = SocketManager(socketURL: URL(string: target.baseUrlPath)!, config: [.log(true), .compress])
        self.socket = self.manager.socket(forNamespace: target.endPoint)
        
        socket.on(clientEvent: .connect) { data, ack in
            print("SOCKET IS CONNECTED", data, ack)
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("SOCKET IS DISCONNECTED")
        }
    }
    
    
    
    func connectSocket() {
        self.socket.connect()
    }
    
    func disconnectSocket() {
        self.socket.disconnect()
    }
    
    
    
}
