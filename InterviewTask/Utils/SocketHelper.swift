//
//  SocketHelper.swift
//  InterviewTask
//
//  Created by Adi Patel on 09/08/21.
//

import Foundation

import UIKit
import Foundation
import SocketIO

let kHost = "http://52.54.145.7:8081/"

//GTW Methods
let kJoinRideRoom = "join_ride_room"
let kExitRideRoom = "exit_ride_room"
let kSendLocation = "send_location"
let kGetLiveLocation = "get_live_location"

//Demo Methods
let kConnectUser = "connectUser"
let kUserList = "userList"
let kExitUser = "exitUser"

final class SocketHelper: NSObject {
    
    //MARK:- Variables
    static let shared = SocketHelper()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    //MARK:- Init Method
    override init() {
        super.init()
        configureSocketClient()
    }
    
    //MARK:- Socket Configurations
    private func configureSocketClient() {
        
        guard let url = URL(string: kHost) else {
            return
        }
        
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        //manager = SocketManager(socketURL: url, config: [.log(false), .compress])
        
        guard let manager = manager else {
            return
        }
        
        socket = manager.socket(forNamespace: "/**********")
    }
    
    //MARK:- To Connect
    func establishConnection() {
        
        guard let socket = manager?.defaultSocket else{
            return
        }
        
        socket.connect()
    }
    
    //MARK:- To Disconnect
    func closeConnection() {
        
        guard let socket = manager?.defaultSocket else{
            return
        }
        
        socket.disconnect()
    }
    
    //MARK:- Join Room
    /*
    socket method :
    1)join_ride_room
    param : {rideId:'abc132k'}
    */
    
    func joinRideRoom(rideData: String, completion: () -> Void) {
        
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        socket.emit(kJoinRideRoom, rideData)
        completion()
    }
    
    //MARK:- Exit Room
    func exitRideRoom(rideData: String, completion: () -> Void) {
        
        guard let socket = manager?.defaultSocket else{
            return
        }
        
        socket.emit(kExitRideRoom, rideData)
        completion()
    }
    
    //MARK:- To Send Currnet Location to Server
    /*
     socket method : send_location
     param to pass : {rideId:'abc132k',latitude:'21.545646546',longitude:'72.65465465464'}
    */
    
    func sendLocation(locationData : String, completion: () -> Void) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        socket.emit(kSendLocation, locationData)
        completion()
    }
    
    
    /*
    socket method :
    1) get_live_location
    you will recive driver's latlong. base on this , move marker on map
    */
    //Get Location Object
    func getLocationOfDriver(completion: @escaping (_ messageInfo: sLocation?) -> Void) {
        
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        //Get Location Object
        socket.on(kGetLiveLocation) { (dataArray, socketAck) -> Void in
            
            var locationInfo = [String: Any]()
            
            guard let location = dataArray[0] as? String else { return }
            
            let data = location.data(using: .utf8)!
            
            //locationInfo["nickname"] = location
            
            /*
            guard let data = UIApplication.jsonData(from: locationInfo) else {
                return
            }
            */
            
            do {
                let locationModel = try JSONDecoder().decode(sLocation.self, from: data)
                completion(locationModel)
                
            } catch let error {
                print("Something happen wrong here...\(error)")
                completion(nil)
            }
        }
    }
    
    //MARK:- Demo Methods for reference only.
    func joinChatRoom(nickname: String, completion: () -> Void) {
        
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        socket.emit(kConnectUser, nickname)
        completion()
    }
        
    func leaveChatRoom(nickname: String, completion: () -> Void) {
        
        guard let socket = manager?.defaultSocket else{
            return
        }
        
        socket.emit(kExitUser, nickname)
        completion()
    }
    
    func participantList(completion: @escaping (_ userList: [User]?) -> Void) {
        
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        socket.on(kUserList) { [weak self] (result, ack) -> Void in
            
            guard result.count > 0,
                let _ = self,
                let user = result.first as? [[String: Any]],
                let data = UIApplication.jsonData(from: user) else {
                    return
            }
            
            do {
                let userModel = try JSONDecoder().decode([User].self, from: data)
                completion(userModel)
                
            } catch let error {
                print("Something happen wrong here...\(error)")
                completion(nil)
            }
        }
        
    }
    
    //Get Location Object
    func getMessage(completion: @escaping (_ messageInfo: Message?) -> Void) {
        
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        //Get Location Object
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            
            var messageInfo = [String: Any]()
            
            guard let nickName = dataArray[0] as? String,
                let message = dataArray[1] as? String,
                let date = dataArray[2] as? String else {
                    return
            }
            
            messageInfo["nickname"] = nickName
            messageInfo["message"] = message
            messageInfo["date"] = date
            
            guard let data = UIApplication.jsonData(from: messageInfo) else {
                return
            }

            do {
                let messageModel = try JSONDecoder().decode(Message.self, from: data)
                completion(messageModel)
                
            } catch let error {
                print("Something happen wrong here...\(error)")
                completion(nil)
            }
        }
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        
        guard let socket = manager?.defaultSocket else {
            return
        }
        
        socket.emit("chatMessage", nickname, message)
    }
}


















/*
import SocketIO

class SocketHelper {

    static let shared = SocketHelper()
    var socket: SocketIOClient!

    let manager = SocketManager(socketURL: URL(string: "AppUrls.socketURL")!, config: [.log(true), .compress])

    private init() {
        socket = manager.defaultSocket
    }

    func connectSocket(completion: @escaping(Bool) -> () ) {
        disconnectSocket()
        socket.on(clientEvent: .connect) {[weak self] (data, ack) in
            print("socket connected")
            self?.socket.removeAllHandlers()
            completion(true)
        }
        socket.connect()
    }

    func disconnectSocket() {
        socket.removeAllHandlers()
        socket.disconnect()
        print("socket Disconnected")
    }

    func checkConnection() -> Bool {
        if socket.manager?.status == .connected {
            return true
        }
        return false

    }

    enum Events {

        case search

        var emitterName: String {
            switch self {
            case .searchTags:
                return "emt_search_tags"
            }
        }

        var listnerName: String {
            switch self {
            case .search:
                return "filtered_tags"
            }
        }

        func emit(params: [String : Any]) {
            SocketHelper.shared.socket.emit(emitterName, params)
        }

        func listen(completion: @escaping (Any) -> Void) {
            SocketHelper.shared.socket.on(listnerName) { (response, emitter) in
                completion(response)
            }
        }

        func off() {
            SocketHelper.shared.socket.off(listnerName)
        }
    }
}
*/

/*

How to use

Connect Socket using this code
SocketHelper.shared.connectSocket { (success) in

}
 
Start Listen event
SocketHelper.Events.search.listen { [weak self] (result) in
    // print(result[0])
}
 
Emit Event
SocketHelper.Events.search.emit(params: <--Your Params-->)

*/
