import Foundation

public enum HexFileParserError: Error, LocalizedError {
    case invalidFormat
    case invalidChecksum
    case invalidRecordType
    case fileTooLarge
    
    public var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Geçersiz hex dosya formatı"
        case .invalidChecksum:
            return "Checksum hatası"
        case .invalidRecordType:
            return "Bilinmeyen kayıt tipi"
        case .fileTooLarge:
            return "Dosya çok büyük"
        }
    }
}

public class HexFileParser {
    
    public init() {}
    
    public func parse(data: Data) throws -> [UInt32: [UInt8]] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw HexFileParserError.invalidFormat
        }
        
        var memory: [UInt32: [UInt8]] = [:]
        var extendedAddress: UInt32 = 0
        
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                continue
            }
            
            guard trimmedLine.hasPrefix(":") else {
                throw HexFileParserError.invalidFormat
            }
            
            let hexString = String(trimmedLine.dropFirst())
            guard let recordData = hexString.hexadecimal else {
                throw HexFileParserError.invalidFormat
            }
            
            guard recordData.count >= 5 else {
                throw HexFileParserError.invalidFormat
            }
            
            let byteCount = recordData[0]
            let address = UInt16(recordData[1]) << 8 | UInt16(recordData[2])
            let recordTypeValue = recordData[3]
            let checksum = recordData[recordData.count - 1]
            
            let calculatedChecksum = recordData.dropLast().reduce(UInt8(0)) { ($0 &+ $1) & 0xFF }
            guard calculatedChecksum == 0 else {
                throw HexFileParserError.invalidChecksum
            }
            
            guard let recordType = HexRecordType(rawValue: recordTypeValue) else {
                throw HexFileParserError.invalidRecordType
            }
            
            let dataBytes = Array(recordData[4..<(4 + Int(byteCount))])
            
            switch recordType {
            case .data:
                let fullAddress = extendedAddress + UInt32(address)
                for (index, byte) in dataBytes.enumerated() {
                    let addr = fullAddress + UInt32(index)
                    if memory[addr] == nil {
                        memory[addr] = []
                    }
                    memory[addr]?.append(byte)
                }
                
            case .endOfFile:
                break
                
            case .extendedLinearAddress:
                guard dataBytes.count == 2 else {
                    throw HexFileParserError.invalidFormat
                }
                extendedAddress = (UInt32(dataBytes[0]) << 24) | (UInt32(dataBytes[1]) << 16)
                
            case .extendedSegmentAddress:
                guard dataBytes.count == 2 else {
                    throw HexFileParserError.invalidFormat
                }
                extendedAddress = ((UInt32(dataBytes[0]) << 8) | UInt32(dataBytes[1])) << 4
                
            case .startLinearAddress, .startSegmentAddress:
                break
            }
        }
        
        return memory
    }
    
    public func convertToPages(memory: [UInt32: [UInt8]], pageSize: Int) -> [[UInt8]] {
        guard !memory.isEmpty else { return [] }
        
        let sortedAddresses = memory.keys.sorted()
        guard let minAddress = sortedAddresses.first,
              let maxAddress = sortedAddresses.last else {
            return []
        }
        
        var pages: [[UInt8]] = []
        var currentPage: [UInt8] = []
        var currentPageStartAddress = (minAddress / UInt32(pageSize)) * UInt32(pageSize)
        
        for address in stride(from: minAddress, through: maxAddress, by: 1) {
            let pageAddress = (address / UInt32(pageSize)) * UInt32(pageSize)
            
            if pageAddress != currentPageStartAddress {
                while currentPage.count < pageSize {
                    currentPage.append(0xFF)
                }
                pages.append(currentPage)
                currentPage = []
                currentPageStartAddress = pageAddress
            }
            
            if let bytes = memory[address] {
                currentPage.append(contentsOf: bytes)
            } else {
                currentPage.append(0xFF)
            }
        }
        
        if !currentPage.isEmpty {
            while currentPage.count < pageSize {
                currentPage.append(0xFF)
            }
            pages.append(currentPage)
        }
        
        return pages
    }
}

extension String {
    var hexadecimal: [UInt8]? {
        var data = [UInt8]()
        var hex = self
        
        if hex.count % 2 != 0 {
            return nil
        }
        
        while !hex.isEmpty {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let substring = hex[..<subIndex]
            hex = String(hex[subIndex...])
            
            guard let byte = UInt8(substring, radix: 16) else {
                return nil
            }
            data.append(byte)
        }
        
        return data
    }
}
