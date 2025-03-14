import Testing
import Nimble
@testable import IoXn

struct IoXnMemoryTests {
    @Test func opcodeLdz() async throws {
        let initialMemory = Memory()
            .write(2, 250)
            .write(3, 12)
        
        expect(Processor()
            .push(2)
            .step(Op.ldz, withMemory: initialMemory)
            .processor
        ).to(equal(Processor().with(
            workingStack: [250]
        )))

        expect(Processor()
            .push(2).push(2)
            .step(Op.ldz2, withMemory: initialMemory)
            .processor
        ).to(equal(Processor().with(
            workingStack: [2, 250, 12]
        )))

    }
    
    @Test func opcodeStz() async throws {
        expect(Processor()
            .push(2)
            .push(250)
            .step(Op.stz, withMemory: Memory())
            .memory
        ).to(equal(Memory().write(250, 2)))
        
        expect(Processor()
            .push(2)
            .push(3)
            .push(250)
            .step(Op.stz2, withMemory: Memory())
            .memory
        ).to(equal(Memory()
                .write(250, 2)
                .write(251, 3)
        ))

    }
    
    @Test func opcodeLdr() async throws {
        let initialMemory = Memory()
            .write(350, 250)
            .write(351, 12)
        
        expect(Processor().with(programCounter: 340)
            .push(10)
            .step(Op.ldr, withMemory: initialMemory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 340,
            workingStack: [250]
        )))

        expect(Processor().with(programCounter: 340)
            .push(10)
            .step(Op.ldr2, withMemory: initialMemory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 340,
            workingStack: [250, 12]
        )))
    }
    
    @Test func opcodeStr() async throws {
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(10)
            .step(Op.str, withMemory: Memory())
            .memory
        ).to(equal(Memory().write(350, 2)))
        
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(3)
            .push(10)
            .step(Op.str2, withMemory: Memory())
            .memory
        ).to(equal(Memory()
                .write(350, 2)
                .write(351, 3)
        ))

    }
    
    @Test func opcodeLda() async throws {
        let initialMemory = Memory()
            .write(350, 250)
        
        expect(Processor().with()
            .push(0x01)
            .push(0x5e)
            .step(Op.lda, withMemory: initialMemory)
            .processor
        ).to(equal(Processor().with(
            workingStack: [250]
        )))
    }
    
    @Test func opcodeSta() async throws {
        expect(Processor()
            .push(2)
            .push(0x01)
            .push(0x5e)
            .step(Op.sta, withMemory: Memory())
            .memory
        ).to(equal(Memory().write(350, 2)))
        
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(3)
            .push(10)
            .step(Op.str2, withMemory: Memory())
            .memory
        ).to(equal(Memory()
                .write(350, 2)
                .write(351, 3)
        ))
    }
    
    @Test func opcodeLit() async throws {
        let memory = Memory()
            .write(12044, 12)
            .write(12045, 125)
        
        expect(Processor()
            .with(programCounter: 12043)
            .step(Op.lit, withMemory: memory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 12045,
            workingStack: [12]
        )))
        
        expect(Processor()
            .with(programCounter: 12043)
            .step(Op.lit2, withMemory: memory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 12046,
            workingStack: [12, 125]
        )))
    }
}
