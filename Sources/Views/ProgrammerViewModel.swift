import Foundation
import SwiftUI
import Combine

@MainActor
public class ProgrammerViewModel: ObservableObject {
    
    @Published public var selectedBoardType: ArduinoBoardType = .mega2560
    @Published public var selectedHexFile: HexFile?
    @Published public var isConnected: Bool = false
    @Published public var status: ProgrammingStatus = .idle
    @Published public var progress: Double = 0.0
    
    private var programmer: ArduinoProgrammer?
    private var communication: CommunicationProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func connectBluetooth() async {
        do {
            let bluetoothComm = BluetoothCommunication()
            communication = bluetoothComm
            
            let programmer = ArduinoProgrammer(communication: bluetoothComm)
            self.programmer = programmer
            
            setupProgrammerObservers(programmer)
            
            status = .connecting
            try await bluetoothComm.connect()
            
            isConnected = true
            status = .connected
            
        } catch {
            status = .failed(error: error.localizedDescription)
            isConnected = false
        }
    }
    
    public func disconnect() async {
        guard let programmer = programmer else { return }
        
        await programmer.disconnect()
        
        self.programmer = nil
        self.communication = nil
        isConnected = false
        status = .idle
        progress = 0.0
    }
    
    public func uploadFirmware() async throws {
        guard let programmer = programmer,
              let hexFile = selectedHexFile else {
            throw ProgrammerError.notReady
        }
        
        let board = ArduinoBoard(
            name: selectedBoardType.rawValue,
            type: selectedBoardType,
            isConnected: true
        )
        
        try await programmer.uploadFirmware(hexFile: hexFile, board: board)
    }
    
    private func setupProgrammerObservers(_ programmer: ArduinoProgrammer) {
        programmer.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
                self?.status = newStatus
            }
            .store(in: &cancellables)
        
        programmer.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newProgress in
                self?.progress = newProgress
            }
            .store(in: &cancellables)
    }
}

public enum ProgrammerError: Error, LocalizedError {
    case notReady
    case noHexFile
    case notConnected
    
    public var errorDescription: String? {
        switch self {
        case .notReady:
            return "Programlayıcı hazır değil"
        case .noHexFile:
            return "Hex dosyası seçilmedi"
        case .notConnected:
            return "Bağlantı kurulmadı"
        }
    }
}
