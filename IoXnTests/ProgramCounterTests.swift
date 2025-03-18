import Testing
import Nimble
@testable import IoXn

struct IoXnProgramCounterTests {
    @Test func opcodeJmp() async throws {
        expect(Processor()
            .push(2)
            .stepNoMemory(Op.jmp, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12045))
        
        expect(Processor()
            .push(0 &- 2)
            .stepNoMemory(Op.jmp, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12041))
        
        expect(Processor()
            .push(oneShortAsByteArray(12050))
            .stepNoMemory(Op.jmp2, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12050))
    }
    @Test func opcodeJcn() async throws {
        expect(Processor()
            .push(5)
            .push(2)
            .stepNoMemory(Op.jcn, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12045))
        
        expect(Processor()
            .push(5)
            .push(0 &- 2)
            .stepNoMemory(Op.jcn, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12041))
        
        expect(Processor()
            .push(0)
            .push(2)
            .stepNoMemory(Op.jcn, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12043))

        expect(Processor()
            .push(5)
            .push(oneShortAsByteArray(12050))
            .stepNoMemory(Op.jcn2, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12050))
    }
    
    @Test func opcodeJsr() async throws {
        let (processor, _, updateProgramCounter) = Processor()
            .push(5)
            .stepNoMemory(Op.jsr, programCounter: 12043)
        
        expect(updateProgramCounter(12043)).to(equal(12048))
        expect(processor).to(equal(Processor().with(returnStack: oneShortAsByteArray(12044))))
    }
    
    @Test func opcodeJsr2() async throws {
        let (processor, _, updateProgramCounter) = Processor()
            .push(oneShortAsByteArray(12055))
            .stepNoMemory(Op.jsr2, programCounter: 12043)
        
        expect(updateProgramCounter(12043)).to(equal(12055))
        expect(processor).to(equal(Processor().with(returnStack: oneShortAsByteArray(12044))))
    }
    
    @Test func opcodeJci() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor()
            .push(0)
            .step(Op.jci, withMemory: memory, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12046))
        
        expect(Processor()
            .push(1)
            .step(Op.jci, withMemory: memory, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12168))
    }
    
    @Test func opcodeJmi() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor()
            .step(Op.jmi, withMemory: memory, programCounter: 12043)
            .updateProgramCounter(12043)
        ).to(equal(12168))
    }
    
    @Test func opcodeJsi() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        let (processor, _, updateProgramCounter) = Processor()
            .step(Op.jsi, withMemory: memory, programCounter: 12043)
        expect(processor).to(equal(Processor().with(
            returnStack: [0x2F, 0x0E] //12046
        )))
        expect(updateProgramCounter(12043)).to(equal(12168))
    }
}
