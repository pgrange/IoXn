import Testing
import Nimble
@testable import IoXn

struct ProcessorTests {
    @Test func AddProgram() async throws {
        let initialMemory = Memory()
            .write(0x100, Op.lit)
            .write(0x101, 0x01)
            .write(0x102, Op.lit)
            .write(0x103, 0x02)
            .write(0x104, Op.add)
            .write(0x105, Op.brk)
            
        expect(run(Processor(), from: 0x100, withMemory: initialMemory)
            .processor
        ).to(equal(Processor().with(
            workingStack: [0x03]
        )))
    }
}
