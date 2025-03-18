import Testing
import Foundation
import Nimble
@testable import IoXn

class BinaryWriter: TextOutputStream {
    var text = String()
    
    func write(_ string: String) {
        text.append(string)
    }
}

struct IntegrationTests {
    @Test func arithmetic() async throws {
        try testRom("arithmetic", expected: " 2b 00 00 ff ff 00 00 00 00 ff fe ff fd ff 00 00 fe fd 2d 64 f7 9b 09 ff ff ff fe 00 02 00 00 ff ff ff fe 02 00 ff 2a 00 d9 89 20 00 fe 2f 26 7c 5e 00 ff ff 00 00 ff ff ff 3e ff 7f 01 00 00 00 00 ff ff 7f ff 3f ff 01 ff 00 ff 00 7f 00 3f 00 03 00 01 fe 80 00 00 00 00 ff fe ff fc ff 80 ff 00 fe 00 fc 00 c0 00 80 00 7e 80 fe 00 00 ff fe 7f fe ff fc 01 80 ff 00 fe 00 00 fc c0 00")
    }
    
    @Test func jump() throws {
        try testRom("jumps", expected: " 01 ab cc bb aa 13 ab 73 75 62 61 cd 01 73 75 62 72 23")
    }
    
    @Test func literals() throws {
        try testRom("literals", expected: " 00 01 01 01 12 34 12 34 ff ff 41 21 0d")
    }
    
    @Test func memory() throws {
        try testRom("memory", expected: " 00 00 00 45 45 67 67 89 76 76 54 ab ab cd 32 32 10 13 13 37")
    }
    
    @Test func stack() throws {
        try testRom("stack", expected: " 48 ff 01 ff ee aa 55 56 03 04 03 aa aa 55 55 aa aa 50 ff 13 37 4e cd 78 9a 52 12 34 56 bc 78 9a f0 12 de 53 ab cd 13 37 4e 53 34 12 a5 5a 83 83 44")
    }
    
    private func testRom(_ rom: String, expected: String) throws {
        class TestBundleClass {}
        let testBundle = Bundle(for: TestBundleClass.self)
        
        let fileURL = testBundle.url(forResource: rom, withExtension: "rom", subdirectory: "integration_tests")
        let arithmeticRom = try Data(contentsOf: fileURL!)
        
        let out = BinaryWriter()
        let console = Console(out: out)
        let devices = Devices().register(index: .console, device: console)
        var machine = IoXn(devices, rom: arithmeticRom)
        machine.start()
        
        expect(out.text).to(equal(expected))
    }
}
