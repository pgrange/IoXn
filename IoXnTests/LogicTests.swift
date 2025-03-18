import Testing
import Nimble
@testable import IoXn

struct IoXnLogicTests {
    @Test func opcodeEqu() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x12)
            .stepNoMemory(Op.equ)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.equk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x00]
        )))
        
        expect(Processor()
            .push(0xab)
            .push(0xcd)
            .push(0xef)
            .push(0x01)
            .stepNoMemory(Op.equ2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00]
        )))
        
        expect(Processor()
            .push(0xab)
            .push(0xcd)
            .push(0xab)
            .push(0xcd)
            .stepNoMemory(Op.equ2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0xab, 0xcd, 0xab, 0xcd, 0x01]
        )))
    }
    @Test func opcodeNeq() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x12)
            .stepNoMemory(Op.neq)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.neqk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x01]
        )))
        
        expect(Processor()
            .push(0xab)
            .push(0xcd)
            .push(0xef)
            .push(0x01)
            .stepNoMemory(Op.neq2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01]
        )))
        
        expect(Processor()
            .push(0xab)
            .push(0xcd)
            .push(0xab)
            .push(0xcd)
            .stepNoMemory(Op.neq2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0xab, 0xcd, 0xab, 0xcd, 0x00]
        )))
    }
    @Test func opcodeGth() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.gth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00]
        )))
        
        expect(Processor()
            .push(0x34)
            .push(0x12)
            .stepNoMemory(Op.gth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01]
        )))
        
        expect(Processor()
            .push(0x34)
            .push(0x56)
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.gth2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x34)
            .push(0x56)
            .stepNoMemory(Op.gth2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x34, 0x56, 0x00]
        )))
    }
    
    @Test func opcodeLth() async throws {
        expect(Processor()
            .push(0x01)
            .push(0x01)
            .stepNoMemory(Op.lth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00]
        )))
        
        expect(Processor()
            .push(0x01)
            .push(0x00)
            .stepNoMemory(Op.lthk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01, 0x00, 0x00]
        )))
        
        expect(Processor()
            .push(0x00)
            .push(0x01)
            .push(0x00)
            .push(0x00)
            .stepNoMemory(Op.lth2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00]
        )))
        
        expect(Processor()
            .push(0x00)
            .push(0x01)
            .push(0x00)
            .push(0x00)
            .stepNoMemory(Op.lth2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00, 0x01, 0x00, 0x00, 0x00]
        )))
    }

    @Test func opcodeAnd() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xF2)
            .stepNoMemory(Op.and)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x02]
        )))
    }
    
    @Test func opcodeOra() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .stepNoMemory(Op.ora)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0xDF]
        )))
    }

    @Test func opcodeEor() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .stepNoMemory(Op.eor)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0xDD]
        )))
    }
    
    @Test func opcodeSft() async throws {
        expect(Processor()
            .push(0x34)
            .push(0x10)
            .stepNoMemory(Op.sft)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x68]
        )))
        expect(Processor()
            .push(0x34)
            .push(0x01)
            .stepNoMemory(Op.sft)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x1a]
        )))
        expect(Processor()
            .push(0x34)
            .push(0x33)
            .stepNoMemory(Op.sftk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x34, 0x33, 0x30]
        )))
        expect(Processor()
            .push(0x12)
            .push(0x48)
            .push(0x34)
            .stepNoMemory(Op.sftk2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x48, 0x34, 0x09, 0x20]
        )))
    }
}
