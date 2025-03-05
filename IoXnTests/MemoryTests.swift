import Testing
import Nimble
@testable import IoXn

struct IoXnMemoryTests {
    @Test func opcodeLdz() async throws {
        let initialMemory = Memory()
            .write(2, 250)
            .write(3, 12)
        
        expect(Processor().with(memory: initialMemory)
            .push(2)
            .step(Op.ldz)
        ).to(equal(Processor().with(
            workingStack: [250],
            memory: initialMemory
        )))

        expect(Processor().with(memory: initialMemory)
            .push(2).push(2)
            .step(Op.ldz2)
        ).to(equal(Processor().with(
            workingStack: [2, 250, 12],
            memory: initialMemory
        )))

    }
    
    @Test func opcodeStz() async throws {
        expect(Processor()
            .push(2)
            .push(250)
            .step(Op.stz)
        ).to(equal(Processor().with(
            memory: Memory().write(250, 2)
        )))
        
        expect(Processor()
            .push(2)
            .push(3)
            .push(250)
            .step(Op.stz2)
        ).to(equal(Processor().with(
            memory: Memory()
                .write(250, 2)
                .write(251, 3)
        )))

    }
    
    @Test func opcodeLdr() async throws {
        let initialMemory = Memory()
            .write(350, 250)
            .write(351, 12)
        
        expect(Processor().with(programCounter: 340, memory: initialMemory)
            .push(10)
            .step(Op.ldr)
        ).to(equal(Processor().with(
            programCounter: 340,
            workingStack: [250],
            memory: initialMemory
        )))

        expect(Processor().with(programCounter: 340, memory: initialMemory)
            .push(10)
            .step(Op.ldr2)
        ).to(equal(Processor().with(
            programCounter: 340,
            workingStack: [250, 12],
            memory: initialMemory
        )))
    }
    
    @Test func opcodeStr() async throws {
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(10)
            .step(Op.str)
        ).to(equal(Processor().with(
            programCounter: 340,
            memory: Memory().write(350, 2)
        )))
        
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(3)
            .push(10)
            .step(Op.str2)
        ).to(equal(Processor().with(
            programCounter: 340,
            memory: Memory()
                .write(350, 2)
                .write(351, 3)
        )))

    }
    
    @Test func opcodeLda() async throws {
        let initialMemory = Memory()
            .write(350, 250)
        
        expect(Processor().with(memory: initialMemory)
            .push(0x01)
            .push(0x5e)
            .step(Op.lda)
        ).to(equal(Processor().with(
            workingStack: [250],
            memory: initialMemory
        )))
    }
    
    @Test func opcodeSta() async throws {
        expect(Processor()
            .push(2)
            .push(0x01)
            .push(0x5e)
            .step(Op.sta)
        ).to(equal(Processor().with(
            memory: Memory().write(350, 2)
        )))
        
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(3)
            .push(10)
            .step(Op.str2)
        ).to(equal(Processor().with(
            programCounter: 340,
            memory: Memory()
                .write(350, 2)
                .write(351, 3)
        )))
    }
    
    @Test func opcodeLit() async throws {
        let memory = Memory()
            .write(12044, 12)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .step(Op.lit)
        ).to(equal(Processor().with(
            programCounter: 12045,
            workingStack: [12],
            memory: memory
        )))
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .step(Op.lit2)
        ).to(equal(Processor().with(
            programCounter: 12046,
            workingStack: [12, 125],
            memory: memory
        )))
    }
}
