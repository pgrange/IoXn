import Testing
import Nimble
@testable import IoXn

struct IoXnStackTests {
    @Test func opcodePop() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.pop)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12]
        )))

        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.pop2)
            .processor
        ).to(equal(Processor().with(
            workingStack: []
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.pop2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34]
        )))
        
        expect(Processor()
            .push(1, .returnStack)
            .push(2, .returnStack)
            .push(3, .returnStack)
            .stepNoMemory(Op.pop2kr)
            .processor
        ).to(equal(Processor().with(
            returnStack: [1, 2, 3]
        )))

    }
    
    @Test func opcodeNip() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.nip)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x34]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x56)
            .push(0x78)
            .stepNoMemory(Op.nip2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x56, 0x78]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x56)
            .push(0x78)
            .stepNoMemory(Op.nip2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x56, 0x78, 0x56, 0x78]
        )))
    }
    
    @Test func opcodeSwp() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.swp)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x34, 0x12]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.swpk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x34, 0x12]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x56)
            .push(0x78)
            .stepNoMemory(Op.swp2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x56, 0x78, 0x12, 0x34]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x56)
            .push(0x78)
            .stepNoMemory(Op.swp2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x56, 0x78, 0x56, 0x78, 0x12, 0x34]
        )))
    }
    
    @Test func opcodeRot() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x56)
            .stepNoMemory(Op.rot)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x34, 0x56, 0x12]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .push(0x56)
            .stepNoMemory(Op.rotk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x56, 0x34, 0x56, 0x12]
        )))
        
        expect(Processor()
            .push(0x12).push(0x34)
            .push(0x56).push(0x78)
            .push(0x9a).push(0xbc)
            .stepNoMemory(Op.rot2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x56, 0x78, 0x9a, 0xbc, 0x12, 0x34]
        )))
        
        expect(Processor()
            .push(0x12).push(0x34)
            .push(0x56).push(0x78)
            .push(0x9a).push(0xbc)
            .stepNoMemory(Op.rot2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0x56, 0x78, 0x9a, 0xbc, 0x12, 0x34]
        )))
    }
    
    @Test func opcodeDup() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.dup)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x34]
        )))
        
        expect(Processor()
            .push(0x12)
            .stepNoMemory(Op.dupk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x12, 0x12]
        )))
        
        expect(Processor()
            .push(0x12).push(0x34)
            .stepNoMemory(Op.dup2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x12, 0x34]
        )))
    }
    
    @Test func opcodeOvr() async throws {
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.ovr)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x12]
        )))
        
        expect(Processor()
            .push(0x12)
            .push(0x34)
            .stepNoMemory(Op.ovrk)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x12, 0x34, 0x12]
        )))
        
        expect(Processor()
            .push(0x12).push(0x34)
            .push(0x56).push(0x78)
            .stepNoMemory(Op.ovr2)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x56, 0x78, 0x12, 0x34]
        )))
        
        expect(Processor()
            .push(0x12).push(0x34)
            .push(0x56).push(0x78)
            .stepNoMemory(Op.ovr2k)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x12, 0x34, 0x56, 0x78, 0x12, 0x34, 0x56, 0x78, 0x12, 0x34]
        )))
    }
    
    @Test func opcodeSth() async throws {
        expect(Processor()
            .push(0x12)
            .stepNoMemory(Op.sth)
            .processor
        ).to(equal(Processor().with(
            returnStack: [0x12]
        )))
        
        expect(Processor()
            .push(0x34, .returnStack)
            .stepNoMemory(Op.sthr)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x34]
        )))
    }
}
