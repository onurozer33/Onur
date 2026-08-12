import Foundation
import Combine

public enum STK500Error: Error, LocalizedError {
    case connectionFailed
    case timeout
    case invalidResponse
    case programmingFailed(String)
    case verificationFailed
    case unsupportedBoard
    
    public var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Arduino'ya bağlanılamadı"
        case .timeout:
            return "Zaman aşımı"
        case .invalidResponse:
            return "Geçersiz yanıt"
        case .programmingFailed(let msg):
            return "Programlama hatası: \(msg)"
        case .verificationFailed:
            return "Doğrulama başarısız"
        case .unsupportedBoard:
            return "Desteklenmeyen kart"
        }
    }
}

public class STK500v2Protocol {
    
    private let communication: CommunicationProtocol
    private var responseBuffer = Data()
    private var responseContinuation: CheckedContinuation<Data, Error>?
    private var cancellables = Set<AnyCancellable>()
    private let timeout: TimeInterval = 5.0
    
    private enum Command: UInt8 {
        case signOn = 0x01
        case setParameter = 0x02
        case getParameter = 0x03
        case loadAddress = 0x06
        case programPage = 0x13
        case readPage = 0x14
        case programFlash = 0x13
        case readFlash = 0x14
        case universal = 0x56
        case enterProgMode = 0x10
        case leaveProgMode = 0x11
    }
    
    private enum Parameter: UInt8 {
        case hwVer = 0x90
        case swMajor = 0x91
        case swMinor = 0x92
        case vtarget = 0x94
        case vadjust = 0x95
    }
    
    private enum Status: UInt8 {
        case cmdOk = 0x00
        case cmdFailed = 0x80
        case cmdUnknown = 0xC9
        case cmdIllegalParameter = 0xCA
    }
    
    private let messageStart: UInt8 = 0x1B
    private let token: UInt8 = 0x0E
    private var sequenceNumber: UInt8 = 0
    
    public init(communication: CommunicationProtocol) {
        self.communication = communication
        setupDataReceiver()
    }
    
    private func setupDataReceiver() {
        communication.dataReceived
            .sink { [weak self] data in
                self?.handleReceivedData(data)
            }
            .store(in: &cancellables)
    }
    
    private func handleReceivedData(_ data: Data) {
        responseBuffer.append(data)
        
        if let response = parseResponse() {
            responseContinuation?.resume(returning: response)
            responseContinuation = nil
        }
    }
    
    private func parseResponse() -> Data? {
        guard responseBuffer.count >= 6 else { return nil }
        
        guard responseBuffer[0] == messageStart else {
            responseBuffer.removeFirst()
            return parseResponse()
        }
        
        let messageSize = (UInt16(responseBuffer[2]) << 8) | UInt16(responseBuffer[3])
        let totalSize = 6 + Int(messageSize)
        
        guard responseBuffer.count >= totalSize else { return nil }
        
        let messageData = responseBuffer[5..<(5 + Int(messageSize))]
        let checksum = responseBuffer[totalSize - 1]
        
        var calculatedChecksum: UInt8 = messageStart
        calculatedChecksum ^= sequenceNumber
        calculatedChecksum ^= responseBuffer[2]
        calculatedChecksum ^= responseBuffer[3]
        calculatedChecksum ^= token
        
        for byte in messageData {
            calculatedChecksum ^= byte
        }
        
        responseBuffer.removeFirst(totalSize)
        
        guard calculatedChecksum == checksum else {
            return parseResponse()
        }
        
        return Data(messageData)
    }
    
    private func sendCommand(_ command: Command, data: [UInt8] = []) async throws -> Data {
        sequenceNumber = (sequenceNumber &+ 1) & 0xFF
        
        var message = Data()
        message.append(messageStart)
        message.append(sequenceNumber)
        
        let messageSize = UInt16(data.count + 1)
        message.append(UInt8((messageSize >> 8) & 0xFF))
        message.append(UInt8(messageSize & 0xFF))
        message.append(token)
        message.append(command.rawValue)
        message.append(contentsOf: data)
        
        var checksum: UInt8 = 0
        for byte in message {
            checksum ^= byte
        }
        message.append(checksum)
        
        responseBuffer.removeAll()
        
        return try await withTimeout(timeout) {
            try await withCheckedThrowingContinuation { continuation in
                self.responseContinuation = continuation
                
                Task {
                    do {
                        try await self.communication.send(data: message)
                    } catch {
                        continuation.resume(throwing: error)
                        self.responseContinuation = nil
                    }
                }
            }
        }
    }
    
    public func connect() async throws {
        try await communication.setDTR(false)
        try await Task.sleep(nanoseconds: 50_000_000)
        try await communication.setDTR(true)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        for _ in 0..<3 {
            do {
                let response = try await sendCommand(.signOn)
                guard response.count > 1, response[0] == Status.cmdOk.rawValue else {
                    throw STK500Error.invalidResponse
                }
                return
            } catch {
                try await Task.sleep(nanoseconds: 500_000_000)
            }
        }
        
        throw STK500Error.connectionFailed
    }
    
    public func enterProgrammingMode() async throws {
        let response = try await sendCommand(.enterProgMode)
        guard response.count > 0, response[0] == Status.cmdOk.rawValue else {
            throw STK500Error.programmingFailed("Programlama moduna girilemedi")
        }
    }
    
    public func leaveProgrammingMode() async throws {
        let response = try await sendCommand(.leaveProgMode)
        guard response.count > 0, response[0] == Status.cmdOk.rawValue else {
            throw STK500Error.programmingFailed("Programlama modundan çıkılamadı")
        }
    }
    
    public func loadAddress(_ address: UInt32) async throws {
        let addressBytes: [UInt8] = [
            UInt8((address >> 24) & 0xFF),
            UInt8((address >> 16) & 0xFF),
            UInt8((address >> 8) & 0xFF),
            UInt8(address & 0xFF)
        ]
        
        let response = try await sendCommand(.loadAddress, data: addressBytes)
        guard response.count > 0, response[0] == Status.cmdOk.rawValue else {
            throw STK500Error.programmingFailed("Adres yüklenemedi")
        }
    }
    
    public func programPage(data: [UInt8], memoryType: UInt8 = 0x46) async throws {
        let sizeBytes: [UInt8] = [
            UInt8((data.count >> 8) & 0xFF),
            UInt8(data.count & 0xFF)
        ]
        
        var commandData = sizeBytes + [memoryType] + data
        
        let response = try await sendCommand(.programPage, data: commandData)
        guard response.count > 0, response[0] == Status.cmdOk.rawValue else {
            throw STK500Error.programmingFailed("Sayfa yazılamadı")
        }
    }
    
    public func readPage(size: Int, memoryType: UInt8 = 0x46) async throws -> [UInt8] {
        let sizeBytes: [UInt8] = [
            UInt8((size >> 8) & 0xFF),
            UInt8(size & 0xFF),
            memoryType
        ]
        
        let response = try await sendCommand(.readPage, data: sizeBytes)
        guard response.count > 1, response[0] == Status.cmdOk.rawValue else {
            throw STK500Error.programmingFailed("Sayfa okunamadı")
        }
        
        return Array(response.dropFirst())
    }
    
    public func getParameter(_ parameter: Parameter) async throws -> UInt8 {
        let response = try await sendCommand(.getParameter, data: [parameter.rawValue])
        guard response.count > 1, response[0] == Status.cmdOk.rawValue else {
            throw STK500Error.invalidResponse
        }
        return response[1]
    }
    
    private func withTimeout<T>(_ duration: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                throw STK500Error.timeout
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
