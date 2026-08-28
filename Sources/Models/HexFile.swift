import Foundation

public struct HexFile: Identifiable {
    public let id: UUID
    public let name: String
    public let url: URL
    public let data: Data
    public var parsedData: [UInt32: [UInt8]]?
    
    public init(id: UUID = UUID(), name: String, url: URL, data: Data) {
        self.id = id
        self.name = name
        self.url = url
        self.data = data
    }
}

public enum HexRecordType: UInt8 {
    case data = 0x00
    case endOfFile = 0x01
    case extendedSegmentAddress = 0x02
    case startSegmentAddress = 0x03
    case extendedLinearAddress = 0x04
    case startLinearAddress = 0x05
}

public struct HexRecord {
    public let byteCount: UInt8
    public let address: UInt16
    public let recordType: HexRecordType
    public let data: [UInt8]
    public let checksum: UInt8
    
    public init(byteCount: UInt8, address: UInt16, recordType: HexRecordType, data: [UInt8], checksum: UInt8) {
        self.byteCount = byteCount
        self.address = address
        self.recordType = recordType
        self.data = data
        self.checksum = checksum
    }
}
