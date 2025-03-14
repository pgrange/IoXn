import Testing
import Nimble
@testable import IoXn

struct IoXnProgramCounterTests {
    @Test func opcodeJmp() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(2)
            .stepNoMemory(Op.jmp)
        ).to(equal(Processor().with(
            programCounter: 12045
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(0 &- 2)
            .stepNoMemory(Op.jmp)
        ).to(equal(Processor().with(
            programCounter: 12041
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(oneShortAsByteArray(12050))
            .stepNoMemory(Op.jmp2)
        ).to(equal(Processor().with(
            programCounter: 12050
        )))
    }
    @Test func opcodeJcn() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(2)
            .stepNoMemory(Op.jcn)
        ).to(equal(Processor().with(
            programCounter: 12045
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(0 &- 2)
            .stepNoMemory(Op.jcn)
        ).to(equal(Processor().with(
            programCounter: 12041
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(0)
            .push(2)
            .stepNoMemory(Op.jcn)
        ).to(equal(Processor().with(
            programCounter: 12043)))

        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(oneShortAsByteArray(12050))
            .stepNoMemory(Op.jcn2)
        ).to(equal(Processor().with(
            programCounter: 12050
        )))
    }
    
    @Test func opcodeJsr() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .stepNoMemory(Op.jsr)
        ).to(equal(Processor().with(
            programCounter: 12048,
            returnStack: oneShortAsByteArray(12044)
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(oneShortAsByteArray(12055))
            .stepNoMemory(Op.jsr2)
        ).to(equal(Processor().with(
            programCounter: 12055,
            returnStack: oneShortAsByteArray(12044)
        )))
    }
    
    @Test func opcodeJci() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043)
            .push(0)
            .step(Op.jci, withMemory: memory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 12046
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(1)
            .step(Op.jci, withMemory: memory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 12168
        )))
    }
    
    @Test func opcodeJmi() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043)
            .step(Op.jmi, withMemory: memory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 12168
        )))
    }
    
    @Test func opcodeJsi() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043)
            .step(Op.jsi, withMemory: memory)
            .processor
        ).to(equal(Processor().with(
            programCounter: 12168,
            returnStack: [0x2F, 0x0E] //12046
        )))
    }
}
