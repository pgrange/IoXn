import Testing
import Nimble
@testable import IoXn

struct IoXnStackTests {
    @Test func opcodePop() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .stepNoMemory(Op.pop)
        ).to(equal(Processor().with(
            workingStack: [1, 2]
        )))

        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .stepNoMemory(Op.popk)
        ).to(equal(Processor().with(
            workingStack: [1, 2, 3]
        )))
        
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .stepNoMemory(Op.pop2)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        
        expect(Processor()
            .push(1, .returnStack)
            .push(2, .returnStack)
            .push(3, .returnStack)
            .stepNoMemory(Op.pop2kr)
        ).to(equal(Processor().with(
            returnStack: [1, 2, 3]
        )))

    }
    
    @Test func opcodeNip() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .stepNoMemory(Op.nip)
        ).to(equal(Processor().with(
            workingStack: [1, 3]
        )))
    }
    
    @Test func opcodeSwp() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .stepNoMemory(Op.swp)
        ).to(equal(Processor().with(
            workingStack: [1, 3, 2]
        )))
    }
    
    @Test func opcodeRot() async throws {
        let result = Processor()
            .push(1)
            .push(2)
            .push(3)
            .stepNoMemory(Op.rot)
        
        expect(result).to(equal(Processor().with(
            workingStack: [2, 3, 1]
        )))
    }
    
    @Test func opcodeDup() async throws {
        let result = Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.dup)
        
        expect(result).to(equal(Processor().with(
            workingStack: [1, 2, 2]
        )))
    }
    
    @Test func opcodeOvr() async throws {
        let processor = Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.ovr)
        
        expect(processor).to(equal(Processor().with(
            workingStack: [1, 2, 1]
        )))
    }
    
    @Test func opcodeSth() async throws {
        expect(Processor()
            .push(2)
            .stepNoMemory(Op.sth)
        ).to(equal(Processor().with(
            returnStack: [2]
        )))
        
        expect(Processor()
            .push(2, .returnStack)
            .stepNoMemory(Op.sthr)
        ).to(equal(Processor().with(
            workingStack: [2]
        )))
    }
}
