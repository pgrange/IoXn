import Testing
import Nimble
@testable import IoXn

struct IoXnArithmeticTests {
    @Test func opcodeInc() async throws {
        expect(Processor()
            .push(6)
            .stepNoMemory(Op.inc)
        ).to(equal(Processor().with(
            workingStack: [7]
        )))
        
        expect(Processor()
            .push(6)
            .stepNoMemory(Op.inck)
        ).to(equal(Processor().with(
            workingStack: [6, 7]
        )))
        
        expect(Processor()
            .push(6)
            .push(255)
            .stepNoMemory(Op.inc2)
        ).to(equal(Processor().with(
            workingStack: oneShortAsByteArray(1792)
        )))
        
        expect(Processor()
            .push(6)
            .push(255)
            .stepNoMemory(Op.inc2k)
        ).to(equal(Processor().with(
            workingStack: [6, 255] + oneShortAsByteArray(1792)
        )))
    }
    
    @Test func opcodeAdd() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.add)
        ).to(equal(Processor().with(
            workingStack: [3]
        )))
        
        expect(Processor()
            .push(255)
            .push(1)
            .stepNoMemory(Op.add)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeSub() async throws {
        expect(Processor()
            .push(2)
            .push(1)
            .stepNoMemory(Op.sub)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        
        expect(Processor()
            .push(1)
            .push(2)
            .stepNoMemory(Op.sub)
        ).to(equal(Processor().with(
            workingStack: [255]
        )))
    }
    
    @Test func opcodeMul() async throws {
        expect(Processor()
            .push(2)
            .push(2)
            .stepNoMemory(Op.mul)
        ).to(equal(Processor().with(
            workingStack: [4]
        )))
        
        expect(Processor()
            .push(130)
            .push(2)
            .stepNoMemory(Op.mul)
        ).to(equal(Processor().with(
            workingStack: [4]
        )))
    }
    
    @Test func opcodeDiv() async throws {
        expect(Processor()
            .push(6)
            .push(2)
            .stepNoMemory(Op.div)
        ).to(equal(Processor().with(
            workingStack: [3]
        )))
        
        expect(Processor()
            .push(255)
            .push(2)
            .stepNoMemory(Op.div)
        ).to(equal(Processor().with(
            workingStack: [127]
        )))
        
        expect(Processor()
            .push(12)
            .push(0)
            .stepNoMemory(Op.div)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
}
