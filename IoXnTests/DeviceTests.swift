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
        
        expect(fakeSystem.written(at: 0x02)).to(equal(0x12))
        expect(fakeMouse.written(at: 0x03)).to(equal(0x21))
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
           
        expect(fakeConsole.written(at: 0x00)).to(equal(0x12))
        expect(fakeConsole.written(at: 0x01)).to(equal(0x21))
    }
    
//    @Test func opcodeDei() throws {
//        let fakeConsole = RecordDevice()
//        let devices = Devices()
//            .register(index: .console, device: fakeConsole)
//        
//        expect(Processor()
//            .push(0x12)
//            .step(Op.dei, withMemory: Memory(), withDevices: devices)
//            .processor
//        ).to(equal(Processor().with(workingStack: [0x21])))
//    }
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
    func written(at: UInt8) -> UInt8 {
        return recorded[at] ?? 0x00
    }
}
