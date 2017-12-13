// Copyright © 2015 Giuseppe Morana aka Eugenio
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

open class GMIRCClient: NSObject {
    
    open weak var delegate: GMIRCClientDelegate?
    
    fileprivate enum REPLY: String {
        case WELCOME = "001"
    }
    
    fileprivate var _socket: GMSocketProtocol
    fileprivate var _nickName: String = ""
    fileprivate var _user: String = ""
    fileprivate var _realName: String = ""
    
    /// true when a I registered successfully (user and nick)
    fileprivate var _connectionRegistered = false
    
    /// true when waiting for registration response
    fileprivate var _waitingForRegistration = false
    
    /// true when received the welcome message from the server
    fileprivate var _ready = false
    
    /// each IRC message should end with this sequence
    fileprivate let ENDLINE = "\r\n"
    
    required public init(socket: GMSocketProtocol) {
        
        _socket = socket
        
        super.init()
        
        _socket.delegate = self
    }
}

// MARK: - GMIRCClientProtocol
extension GMIRCClient: GMIRCClientProtocol {
    
    public func host() -> String {
        return _socket.host
  }
    
    public func port() -> Int {
        return _socket.port
    }
    
    public func register( nickName: String, user: String, realName: String) {

        _nickName = nickName
        _user = user
        _realName = realName
        
        _socket.delegate = self
        _socket.open()
    }
    
    public func join( channel: String) {
        guard !channel.isEmpty && channel.hasPrefix("#") else {
            return
        }
        _sendCommand("JOIN \(channel)")
    }
    
    public func sendPrivateMessage(_ message: String, toNickName: String) {
        guard !toNickName.hasPrefix("#") else {
            print("Invalid nickName")
            return
        }
        _sendCommand("PRIVMSG \(toNickName) :\(message)")
    }
    
    public func sendMessage(_ message: String, toChannel: String) {
        guard toChannel.hasPrefix("#") else {
            print("Invalid channel")
            return
        }
        _sendCommand("PRIVMSG \(toChannel) :\(message)")
    }
}

// MARK: - SocketDelegate
extension GMIRCClient: GMSocketDelegate {
    
    public func didOpen() {
        print("[DEBUG] Socket opened")
    }
    
    public func didReadyToSendMessages() {
        
        if !_connectionRegistered && !_waitingForRegistration {
            
            _waitingForRegistration = true
            
            _sendCommand("NICK \(_nickName)")
            _sendCommand("USER \(_user) 0 * : \(_realName)")
        }
    }
    
    
    public func didReceiveMessage(_ msg: String) {
        
        let msgList = msg.components(separatedBy: ENDLINE)
        for line in msgList {
            if line.hasPrefix("PING") {
                _pong(msg)
            } else {
                _handleMessage(line)
            }
        }
    }
    
    public func didClose() {
        print("[DEBUG] Socket closed")
        
        _connectionRegistered = false
    }
}

// MARK: - private
private extension GMIRCClient {
    
    func _sendCommand(_ command: String) {
        let msg = command + ENDLINE
        _socket.sendMessage(msg)
    }
    
    func _pong(_ msg: String) {
        let token = msg.replacingOccurrences(of: "PING :", with: "").replacingOccurrences(of: ENDLINE, with: "")
        
        _connectionRegistered = true    // When I receive the first PING I suppose my registration is done
        _waitingForRegistration = false
        
        _sendCommand("PONG \(token)")
    }
    
    func _handleMessage(_ msg: String) {
        
        if( msg.isEmpty )
        {
            return
        }
        print("msg: |\(msg)|")
        
        guard let ircMsg = GMIRCMessage(message: msg),
        let command = ircMsg.command
            else {
            return
        }
        
        switch command {
        case "001":
            _ready = true
            delegate?.didWelcome()
        case "JOIN":
            delegate?.didJoin(ircMsg.params!.textToBeSent!)
        case "PRIVMSG":
            delegate?.didReceivePrivateMessage(ircMsg.params!.textToBeSent!, from: ircMsg.prefix!.nickName!)
        default:
            print("cmd not handled: |\(command)|" )
            break;
        }
    }
}
