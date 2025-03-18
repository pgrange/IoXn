import Testing
import Nimble
@testable import IoXn

struct IoXnArithmeticTests {
    @Test func opcodeInc() async throws {
        expect(Processor()
            .push(0x01)
            .stepNoMemory(Op.inc)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x02]
        )))
        
        expect(Processor()
            .push(0x01)
            .stepNoMemory(Op.inck)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01, 0x02]
        )))
        
        expect(Processor()
            .push(0x00)
            .push(0x01)
            .stepNoMemory(Op.inc2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00, 0x02]
        )))
        
        expect(Processor()
            .push(0x00)
            .push(0x01)
            .stepNoMemory(Op.inc2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00, 0x01, 0x00, 0x02]
        )))
    }
    
    @Test func opcodeAdd() async throws {
        expect(Processor()
            .push(0x1a)
            .push(0x2e)
            .stepNoMemory(Op.add)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x48]
        )))
        
        expect(Processor()
            .push(0xff)
            .push(0x01)
            .stepNoMemory(Op.add)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00]
        )))
        
        expect(Processor()
            .push(0x02)
            .push(0x5d)
            .stepNoMemory(Op.addk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x02, 0x05d, 0x5f]
        )))
        
        expect(Processor()
            .push(0x00)
            .push(0x01)
            .push(0x00)
            .push(0x02)
            .stepNoMemory(Op.add2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00, 0x03]
        )))
        
        expect(Processor()
            .push(0xff)
            .push(0xff)
            .push(0x00)
            .push(0x00)
            .stepNoMemory(Op.add2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0xff, 0xff]
        )))
    }
    
    @Test func opcodeSub() async throws {
        expect(Processor()
            .push(0x02)
            .push(0x01)
            .stepNoMemory(Op.sub)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x01]
        )))
        
        expect(Processor()
            .push(0x01)
            .push(0x02)
            .stepNoMemory(Op.sub)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0xff]
        )))
    }
    
    @Test func opcodeMul() async throws {
        expect(Processor()
            .push(0x02)
            .push(0x02)
            .stepNoMemory(Op.mul)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x04]
        )))
        
        expect(Processor()
            .push(0x82)
            .push(0x02)
            .stepNoMemory(Op.mul)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x04]
        )))
    }
    
    @Test func opcodeDiv() async throws {
        expect(Processor()
            .push(0x10)
            .push(0x02)
            .stepNoMemory(Op.div)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x08]
        )))
        
        expect(Processor()
            .push(0x10)
            .push(0x03)
            .stepNoMemory(Op.divk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x10, 0x03, 0x05]
        )))
        
        expect(Processor()
            .push(0x00)
            .push(0x10)
            .push(0x00)
            .push(0x00)
            .stepNoMemory(Op.div2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x00, 0x00]
        )))
    }
}
