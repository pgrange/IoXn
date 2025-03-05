import Testing
import Nimble
@testable import IoXn

struct IoXnLogicTests {
    @Test func opcodeEqu() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.equ)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.equ)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
    }
    @Test func opcodeNeq() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.neq)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.neq)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    @Test func opcodeGth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .step(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeLth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .step(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }

    @Test func opcodeAnd() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xF2)
            .step(Op.and)
        ).to(equal(Processor().with(
            workingStack: [0x02]
        )))
    }
    
    @Test func opcodeOra() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .step(Op.ora)
        ).to(equal(Processor().with(
            workingStack: [0xDF]
        )))
    }

    @Test func opcodeEor() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .step(Op.eor)
        ).to(equal(Processor().with(
            workingStack: [0xDD]
        )))
    }
    
    @Test func opcodeSft() async throws {
        expect(Processor()
            .push(0x34)
            .push(0x10)
            .step(Op.sft)
        ).to(equal(Processor().with(
            workingStack: [0x68]
        )))
    }
}
