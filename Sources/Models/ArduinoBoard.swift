import Foundation

public enum ArduinoBoardType: String, CaseIterable, Identifiable {
    case mega2560 = "Arduino Mega 2560"
    case mega1280 = "Arduino Mega 1280"
    case uno = "Arduino Uno"
    case nano = "Arduino Nano"
    
    public var id: String { rawValue }
    
    public var chipset: String {
        switch self {
        case .mega2560, .mega1280:
            return "ATmega2560"
        case .uno, .nano:
            return "ATmega328P"
        }
    }
    
    public var baudRate: Int {
        switch self {
        case .mega2560, .mega1280:
            return 115200
        case .uno, .nano:
            return 57600
        }
    }
    
    public var flashSize: Int {
        switch self {
        case .mega2560:
            return 256 * 1024
        case .mega1280:
            return 128 * 1024
        case .uno, .nano:
            return 32 * 1024
        }
    }
    
    public var pageSize: Int {
        switch self {
        case .mega2560, .mega1280:
            return 256
        case .uno, .nano:
            return 128
        }
    }
}

public struct ArduinoBoard: Identifiable {
    public let id: UUID
    public let name: String
    public let type: ArduinoBoardType
    public var isConnected: Bool
    
    public init(id: UUID = UUID(), name: String, type: ArduinoBoardType, isConnected: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.isConnected = isConnected
    }
}
