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
        self.manager = SocketManager(socketURL: URL(string: target.baseUrlPath)!, config: [/*.log(true),*/ .compress])
        self.socket = self.manager.socket(forNamespace: target.endPoint)
        
        socket.on(clientEvent: .connect) {[weak self] data, ack in
            guard let owner = self else {return}
            print("SOCKET IS CONNECTED", data, ack)
        }
        
        socket.on(clientEvent: .disconnect) {[weak self] data, ack in
            guard let owner = self else {return}
            print("SOCKET IS DISCONNECTED", data, ack)
        }
    }
    
    deinit {
        print("SocketManager deinit")
    }
    
    func openSocket(target: SocketRouter) {
        socket = self.manager.socket(forNamespace: target.endPoint)
    }
    
    func receivedDataFromSocket<T: Decodable>(type: T.Type, router: SocketRouter, emitEvent: PublishSubject<T>) {
        socket.on(router.receivedEventType) {[weak self] data, ack in
            guard let owner = self else {return}
            print("data received")
            
            guard let data = data.first, let jsonData = try? JSONSerialization.data(withJSONObject: data), let decodedData = try? JSONDecoder().decode(type, from: jsonData) else { return }
            
            emitEvent.onNext(decodedData)
        }
    }
    
    func connectSocket() {
        self.socket.connect()
    }
    
    func disconnectSocket() {
        self.socket.disconnect()
        self.socket = nil
    }
    
    
    
    
    
}
