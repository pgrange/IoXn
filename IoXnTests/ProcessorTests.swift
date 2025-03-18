import Testing
import Foundation
import Nimble
@testable import IoXn

struct ProcessorTests {
    @Test func AddProgram() async throws {
        let program: [UInt8] = [
            Op.lit, 0x01,
            Op.lit, 0x02,
            Op.add,
            Op.brk,
        ]
        let initialMemory = Memory(initializedWith: Data(program))
            
        expect(run(Processor(), from: 0x100, withMemory: initialMemory, withDevices: Devices())
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x03]
        )))
    }
    
    @Test func ArithmeticProgram() async throws {
        let printByteAddr: UInt16 = 0x200
        let hexAddr: UInt16 = 0x250
        
        let out: [UInt8] = [Op.lit2] + printByteAddr.toByteArray() + [Op.jsr2]
        let out2: [UInt8] = [Op.sth] + out + [Op.sthr] + out
        
        let consoleWrite: UInt8 = 0x18
        
        let hexDelta1: UInt8 = UInt8(hexAddr - printByteAddr) - 12
        let hexDelta2: UInt8 = UInt8(hexAddr - printByteAddr) - 18
        let printByte: [UInt8] = [
            Op.lit, 0x20, Op.lit, consoleWrite, Op.deo,
            Op.dup, Op.lit, 0x04, Op.sft,
            Op.lit, hexDelta1, Op.jsr,
            Op.lit, 0x0f, Op.and,
            Op.lit, hexDelta2, Op.jmp,
        ]
        let notAlphaDelta: UInt8 = 3
        let hex: [UInt8] = [
            Op.lit, 0x30, Op.add,
            Op.dup, Op.lit, 0x3a, Op.lth,
            Op.lit, notAlphaDelta, Op.jcn,
            Op.lit, 0x27, Op.add,
            Op.lit, consoleWrite, Op.deo,
            Op.jmp2r
        ]
        
        var main: [UInt8] = [ Op.lit, 0x2b ] + out
        main += [ Op.lit2, 0x00, 0x00, Op.lit2, 0x00, 0x00, Op.add2 ] + out2
        main += [ Op.lit2, 0xff, 0xff, Op.lit2, 0x00, 0x00, Op.add2 ] + out2
        
        
        let initalMemory = Memory()
            .write(0x100, Data(main))
            .write(printByteAddr, Data(printByte))
            .write(hexAddr, Data(hex))
                            
        let (processor, _) = run(
            Processor(),
            from: 0x100,
            withMemory: initalMemory,
            withDevices: Devices()
        )
        
        expect(processor).to(equal(Processor()))
    }
}
