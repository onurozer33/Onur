import Foundation
import CoreBluetooth
import Combine

public class BluetoothCommunication: NSObject, CommunicationProtocol {
    
    public var isConnected: Bool {
        return peripheral?.state == .connected
    }
    
    public let dataReceived = PassthroughSubject<Data, Never>()
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    
    private let serviceUUID = CBUUID(string: "FFE0")
    private let txCharacteristicUUID = CBUUID(string: "FFE1")
    private let rxCharacteristicUUID = CBUUID(string: "FFE1")
    
    private var scanContinuation: CheckedContinuation<CBPeripheral, Error>?
    private var connectContinuation: CheckedContinuation<Void, Error>?
    private var discoverContinuation: CheckedContinuation<Void, Error>?
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func connect() async throws {
        guard centralManager.state == .poweredOn else {
            throw BluetoothError.bluetoothNotAvailable
        }
        
        let peripheral = try await scanForPeripheral()
        self.peripheral = peripheral
        
        try await connectToPeripheral(peripheral)
        try await discoverServices(peripheral)
    }
    
    private func scanForPeripheral() async throws -> CBPeripheral {
        return try await withCheckedThrowingContinuation { continuation in
            self.scanContinuation = continuation
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            
            Task {
                try await Task.sleep(nanoseconds: 10_000_000_000)
                if self.scanContinuation != nil {
                    self.scanContinuation?.resume(throwing: BluetoothError.deviceNotFound)
                    self.scanContinuation = nil
                    self.centralManager.stopScan()
                }
            }
        }
    }
    
    private func connectToPeripheral(_ peripheral: CBPeripheral) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.connectContinuation = continuation
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    private func discoverServices(_ peripheral: CBPeripheral) async throws {
        peripheral.delegate = self
        
        try await withCheckedThrowingContinuation { continuation in
            self.discoverContinuation = continuation
            peripheral.discoverServices([serviceUUID])
        }
    }
    
    public func disconnect() async {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        self.peripheral = nil
        self.txCharacteristic = nil
        self.rxCharacteristic = nil
    }
    
    public func send(data: Data) async throws {
        guard let peripheral = peripheral, let txCharacteristic = txCharacteristic else {
            throw BluetoothError.notConnected
        }
        
        let chunkSize = 20
        for i in stride(from: 0, to: data.count, by: chunkSize) {
            let end = min(i + chunkSize, data.count)
            let chunk = data[i..<end]
            peripheral.writeValue(chunk, for: txCharacteristic, type: .withResponse)
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }
    
    public func setDTR(_ enabled: Bool) async throws {
    }
    
    public func setRTS(_ enabled: Bool) async throws {
    }
}

extension BluetoothCommunication: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            scanContinuation?.resume(throwing: BluetoothError.bluetoothNotAvailable)
            scanContinuation = nil
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let continuation = scanContinuation {
            centralManager.stopScan()
            continuation.resume(returning: peripheral)
            scanContinuation = nil
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectContinuation?.resume(returning: ())
        connectContinuation = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectContinuation?.resume(throwing: error ?? BluetoothError.connectionFailed)
        connectContinuation = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
}

extension BluetoothCommunication: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            discoverContinuation?.resume(throwing: error)
            discoverContinuation = nil
            return
        }
        
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            discoverContinuation?.resume(throwing: BluetoothError.serviceNotFound)
            discoverContinuation = nil
            return
        }
        
        peripheral.discoverCharacteristics([txCharacteristicUUID, rxCharacteristicUUID], for: service)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            discoverContinuation?.resume(throwing: error)
            discoverContinuation = nil
            return
        }
        
        guard let characteristics = service.characteristics else {
            discoverContinuation?.resume(throwing: BluetoothError.characteristicNotFound)
            discoverContinuation = nil
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == txCharacteristicUUID {
                txCharacteristic = characteristic
            }
            if characteristic.uuid == rxCharacteristicUUID {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        if txCharacteristic != nil && rxCharacteristic != nil {
            discoverContinuation?.resume(returning: ())
            discoverContinuation = nil
        } else {
            discoverContinuation?.resume(throwing: BluetoothError.characteristicNotFound)
            discoverContinuation = nil
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Veri okuma hatası: \(error)")
            return
        }
        
        if let data = characteristic.value, !data.isEmpty {
            dataReceived.send(data)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Veri yazma hatası: \(error)")
        }
    }
}

public enum BluetoothError: Error, LocalizedError {
    case bluetoothNotAvailable
    case deviceNotFound
    case notConnected
    case connectionFailed
    case serviceNotFound
    case characteristicNotFound
    
    public var errorDescription: String? {
        switch self {
        case .bluetoothNotAvailable:
            return "Bluetooth kullanılamıyor"
        case .deviceNotFound:
            return "Cihaz bulunamadı"
        case .notConnected:
            return "Bağlı değil"
        case .connectionFailed:
            return "Bağlantı başarısız"
        case .serviceNotFound:
            return "Servis bulunamadı"
        case .characteristicNotFound:
            return "Characteristic bulunamadı"
        }
    }
}
