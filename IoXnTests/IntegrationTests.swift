import Testing
import Foundation
import Nimble
@testable import IoXn

struct BinaryWriter: TextOutputStream {
    var data = Data()
    
    mutating func write(_ string: String) {
        data.append(contentsOf: string.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
    }
}

struct IntegrationTests {
    @Test func opcodeEqu() async throws {
        class TestBundleClass {}
        let testBundle = Bundle(for: TestBundleClass.self)
        
        let fileURL = testBundle.url(forResource: "arithmetic", withExtension: "rom", subdirectory: "integration_tests")
        let arithmeticRom = try Data(contentsOf: fileURL!)
        
        var out = BinaryWriter()
        let console = Console(out: &out)
        let devices = Devices().register(index: .console, device: console)
        var machine = IoXn(devices, rom: arithmeticRom)
        machine.start()
        
        print(out.data)
    }
}
