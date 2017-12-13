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

/// A simplet implementation of a socket protocol
open class GMSocket: NSObject {
    
    /// The host to which the socket will connect (e.g. "irc.freenode.net")
    fileprivate(set) open var host: String
    
    /// The port to which the socket will connect (e.g. 6667)
    fileprivate(set) open var port: Int
    
    open var delegate: GMSocketDelegate?
    
    fileprivate var inputStream: InputStream?
    fileprivate var outputStream: OutputStream?
    fileprivate var isOpen: Bool = false
    
    required public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
}

// MARK: - GMSocketProtocol
extension GMSocket: GMSocketProtocol {
    
    public func open() {
        
        guard !isOpen else {
            print("Socket already open")
            return
        }
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream!.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream!.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        
        inputStream!.delegate = self
        outputStream!.delegate = self
        
        inputStream!.open()
        outputStream!.open()
    }
    
    public func close() {
        guard isOpen else {
            print("Socket already closed")
            return
        }
        
        inputStream!.delegate = nil
        outputStream!.delegate = nil
        
        inputStream!.close()
        outputStream!.close()
        
        isOpen = false
    }
    
    public func sendMessage(_ message: String) {
        
        guard isOpen else {
            print("Can't send message: socket is closed")
            return
        }
        
        let data = NSData(data: message.data(using: String.Encoding.ascii)!) as Data
        let buffer = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        
        outputStream!.write(buffer, maxLength: data.count)
    }
}

// MARK: - NSStreamDelegate
extension GMSocket: StreamDelegate {
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event():
            print("Socket event: None")
        case Stream.Event.openCompleted:
            _openCompleted()
        case Stream.Event.hasBytesAvailable:
            _hasBytesAvailable(aStream)
        case Stream.Event.hasSpaceAvailable:
            _hasSpaceAvailable()
        case Stream.Event.errorOccurred:
            print("Socket: unknown error")
        case Stream.Event.endEncountered:
            _endEncountered(aStream)
        default:
            print("Unknown socket event")
        }
    }
}

// MARK: - private
private extension GMSocket {
    
    func _openCompleted() {
        isOpen = true
        delegate?.didOpen()
    }
    
    func _hasBytesAvailable(_ aStream: Stream) {
        
        guard aStream == inputStream else {
            print("Received bytes aren't for my inputStream")
            return
        }
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        while inputStream!.hasBytesAvailable {
            let len = inputStream!.read(&buffer, maxLength: 1024)
            if len > 0 {
                let output = NSString(bytes: buffer, length: len, encoding: String.Encoding.ascii.rawValue)
                if output != nil && delegate != nil {
                    delegate!.didReceiveMessage(output! as String)
                }
            }
        }
    }
    
    func _hasSpaceAvailable() {
        delegate?.didReadyToSendMessages()
    }
    
    func _endEncountered(_ aStream: Stream) {
        aStream.close()
        aStream.remove(from: .main, forMode: RunLoopMode.defaultRunLoopMode)
        delegate?.didClose()
    }
}
