import Testing
import Nimble
@testable import IoXn

struct DeviceTests {
    @Test func opcodeDeo() throws {
        let fakeSystem = RecordDevice()
        let fakeMouse  = RecordDevice()
        let devices = Devices()
            .register(index: .system, device: fakeSystem)
            .register(index: .mouse, device: fakeMouse)
        
        _ = Processor()
            .push(0x12)
            .push(0x02)
            .step(Op.deo, withMemory: Memory(), withDevices: devices)
            .processor
            .push(0x21)
            .push(0x93)
            .step(Op.deo, withMemory: Memory(), withDevices: devices)
        
        expect(fakeSystem.read(at: 0x02, as: UInt8.self)).to(equal(0x12))
        expect(fakeMouse.read(at: 0x03, as: UInt8.self)).to(equal(0x21))
    }
    
    @Test func opcodeDeo2() throws {
        let fakeConsole = RecordDevice()
        let devices = Devices()
            .register(index: .console, device: fakeConsole)
        
        _ = Processor()
            .push(0x12)
            .push(0x21)
            .push(0x10)
            .step(Op.deo2, withMemory: Memory(), withDevices: devices)
           
        expect(fakeConsole.read(at: 0x00, as: UInt8.self)).to(equal(0x12))
        expect(fakeConsole.read(at: 0x01, as: UInt8.self)).to(equal(0x21))
    }
    
    @Test func opcodeDei() throws {
        let fakeConsole = RecordDevice()
        fakeConsole.write(UInt8(0x21), at: 0x02)
        let devices = Devices()
            .register(index: .console, device: fakeConsole)
        
        expect(Processor()
            .push(0x12)
            .step(Op.dei, withMemory: Memory(), withDevices: devices)
            .processor
        ).to(equal(Processor().with(workingStack: [0x21])))
    }
    
    @Test func opcodeDei2() throws {
        let fakeConsole = RecordDevice()
        fakeConsole.write(UInt8(0x21), at: 0x00)
        fakeConsole.write(UInt8(0x22), at: 0x01)
        let devices = Devices()
            .register(index: .console, device: fakeConsole)
        
        expect(Processor()
            .push(0x10)
            .step(Op.dei2, withMemory: Memory(), withDevices: devices)
            .processor
        ).to(equal(Processor().with(workingStack: [0x21, 0x22])))
    }
}

class RecordDevice : Device {
    var recorded: [UInt8: UInt8] = [:]
    
    override func write<N: Operand>(_ value: N, at: UInt8) {
        if (N.sizeInBytes == 1) {
            recorded[at] = UInt8(value)
        } else {
            let (high, low) = oneShortAsTwoBytes(UInt16(value))
            recorded[at] = high
            recorded[at &+ 1] = low
        }
    }
    override func read<N: Operand>(at: UInt8, as type: N.Type) -> N {
        if N.sizeInBytes == 1 {
            return N(recorded[at] ?? 0)
        } else {
            let high = recorded[at] ?? 0
            let low = recorded[at &+ 1] ?? 0
            return N(twoBytesAsOneShort(high, low))
        }
    }
}
