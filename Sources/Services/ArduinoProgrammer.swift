import Foundation
import Combine

public class ArduinoProgrammer: ObservableObject {
    
    @Published public var status: ProgrammingStatus = .idle
    @Published public var progress: Double = 0.0
    
    private let communication: CommunicationProtocol
    private let protocol: STK500v2Protocol
    private let hexParser: HexFileParser
    
    public init(communication: CommunicationProtocol) {
        self.communication = communication
        self.protocol = STK500v2Protocol(communication: communication)
        self.hexParser = HexFileParser()
    }
    
    @MainActor
    public func uploadFirmware(hexFile: HexFile, board: ArduinoBoard) async throws {
        do {
            status = .connecting
            progress = 0.0
            
            try await communication.connect()
            status = .connected
            
            try await protocol.connect()
            
            status = .verifying
            let memory = try hexParser.parse(data: hexFile.data)
            let pages = hexParser.convertToPages(memory: memory, pageSize: board.type.pageSize)
            
            guard !pages.isEmpty else {
                throw STK500Error.programmingFailed("Hex dosyası boş")
            }
            
            try await protocol.enterProgrammingMode()
            
            status = .programming(progress: 0.0)
            
            for (index, page) in pages.enumerated() {
                let address = UInt32(index * board.type.pageSize)
                
                try await protocol.loadAddress(address)
                try await protocol.programPage(data: page)
                
                let pageProgress = Double(index + 1) / Double(pages.count)
                progress = pageProgress
                status = .programming(progress: pageProgress)
                
                try await Task.sleep(nanoseconds: 10_000_000)
            }
            
            status = .verifyingFlash(progress: 0.0)
            
            for (index, page) in pages.enumerated() {
                let address = UInt32(index * board.type.pageSize)
                
                try await protocol.loadAddress(address)
                let readData = try await protocol.readPage(size: page.count)
                
                guard readData == page else {
                    throw STK500Error.verificationFailed
                }
                
                let verifyProgress = Double(index + 1) / Double(pages.count)
                progress = verifyProgress
                status = .verifyingFlash(progress: verifyProgress)
                
                try await Task.sleep(nanoseconds: 10_000_000)
            }
            
            try await protocol.leaveProgrammingMode()
            
            status = .completed
            progress = 1.0
            
        } catch {
            status = .failed(error: error.localizedDescription)
            throw error
        }
    }
    
    @MainActor
    public func reset() {
        status = .idle
        progress = 0.0
    }
    
    public func disconnect() async {
        await communication.disconnect()
        await MainActor.run {
            status = .idle
            progress = 0.0
        }
    }
}
