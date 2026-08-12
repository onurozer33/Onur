import XCTest
@testable import ArduinoProgrammer

final class HexFileParserTests: XCTestCase {
    
    var parser: HexFileParser!
    
    override func setUp() {
        super.setUp()
        parser = HexFileParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func testParseSimpleHexFile() throws {
        let hexContent = """
        :10000000C0E0D0E0A8C0A7C0A6C0A5C0A4C0A3C009
        :10001000A2C0A1C0A0C09FC09EC09DC09CC09BC088
        :00000001FF
        """
        
        let data = hexContent.data(using: .utf8)!
        let memory = try parser.parse(data: data)
        
        XCTAssertFalse(memory.isEmpty)
        XCTAssertNotNil(memory[0])
    }
    
    func testParseInvalidHexFile() {
        let invalidHex = "This is not a hex file"
        let data = invalidHex.data(using: .utf8)!
        
        XCTAssertThrowsError(try parser.parse(data: data)) { error in
            XCTAssertTrue(error is HexFileParserError)
        }
    }
    
    func testConvertToPages() throws {
        let hexContent = """
        :10000000C0E0D0E0A8C0A7C0A6C0A5C0A4C0A3C009
        :00000001FF
        """
        
        let data = hexContent.data(using: .utf8)!
        let memory = try parser.parse(data: data)
        let pages = parser.convertToPages(memory: memory, pageSize: 128)
        
        XCTAssertFalse(pages.isEmpty)
        XCTAssertEqual(pages[0].count, 128)
    }
    
    func testHexStringExtension() {
        XCTAssertEqual("FF".hexadecimal, [0xFF])
        XCTAssertEqual("00".hexadecimal, [0x00])
        XCTAssertEqual("0102".hexadecimal, [0x01, 0x02])
        XCTAssertNil("GG".hexadecimal)
        XCTAssertNil("F".hexadecimal)
    }
}
