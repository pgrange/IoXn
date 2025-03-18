import Testing
import Nimble
@testable import IoXn

struct IoXnLogicTests {
    @Test func opcodeEqu() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.equ)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.equ)
            .processor
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
    }
    @Test func opcodeNeq() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.neq)
            .processor
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.neq)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    @Test func opcodeGth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.gth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .stepNoMemory(Op.gth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.gth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeLth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.lth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .stepNoMemory(Op.lth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .stepNoMemory(Op.lth)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0]
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
    }
}
