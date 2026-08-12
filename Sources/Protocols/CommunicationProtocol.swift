import Foundation
import Combine

public protocol CommunicationProtocol {
    var isConnected: Bool { get }
    var dataReceived: PassthroughSubject<Data, Never> { get }
    
    func connect() async throws
    func disconnect() async
    func send(data: Data) async throws
    func setDTR(_ enabled: Bool) async throws
    func setRTS(_ enabled: Bool) async throws
}
