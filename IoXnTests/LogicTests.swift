import Testing
import Nimble
@testable import IoXn

struct IoXnLogicTests {
    @Test func opcodeEqu() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.equ)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.equ)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
    }
    @Test func opcodeNeq() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.neq)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.neq)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    @Test func opcodeGth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .stepNoMemory(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeLth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .stepNoMemory(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }

    @Test func opcodeAnd() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xF2)
            .stepNoMemory(Op.and)
        ).to(equal(Processor().with(
            workingStack: [0x02]
        )))
    }
    
    @Test func opcodeOra() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .stepNoMemory(Op.ora)
        ).to(equal(Processor().with(
            workingStack: [0xDF]
        )))
    }

    @Test func opcodeEor() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .stepNoMemory(Op.eor)
        ).to(equal(Processor().with(
            workingStack: [0xDD]
        )))
    }
    
    @Test func opcodeSft() async throws {
        expect(Processor()
            .push(0x34)
            .push(0x10)
            .stepNoMemory(Op.sft)
        ).to(equal(Processor().with(
            workingStack: [0x68]
        )))
    }
}
