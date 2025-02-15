import Testing
import Nimble
@testable import IoXn

struct IoXnTests {

    @Test func opcodeAdd() async throws {
        let processor = Processor().push(1).push(2).opcode(.add)
        
        expect(processor.workingStack[0]).to(equal(3))
    }
    
    @Test func opcodeSub() async throws {
        let processor = Processor().push(2).push(1).opcode(.sub)
        
        expect(processor.workingStack[0]).to(equal(1))
    }
    
    @Test func opcodeMul() async throws {
        let processor = Processor().push(2).push(2).opcode(.mul)
        
        expect(processor.workingStack[0]).to(equal(4))
    }
    
    @Test func opcodeDiv() async throws {
        let processor = Processor().push(2).push(2).opcode(.div)
        
        expect(processor.workingStack[0]).to(equal(1))
    }
}

enum Opcode {
    case add
    case sub
    case mul
    case div
}

struct Processor {
    let workingStack: [UInt8]
    let returnStack: [UInt8]
    
    init(workingStack: [UInt8] = [], returnStack: [UInt8] = []) {
        self.workingStack = workingStack
        self.returnStack = returnStack
    }
    
    func push(_ value: UInt8) -> Processor {
        return Processor(
            workingStack: workingStack + [value],
            returnStack: returnStack
        )
    }
    
    func pop() -> UnaryOperationInProgress {
        let a = workingStack.last!
        return UnaryOperationInProgress(
            a: a,
            processor: Processor(
                workingStack: workingStack.dropLast(),
                returnStack: returnStack
            )
        )
    }
    
    func opcode(_ opcode: Opcode) -> Processor {
        switch opcode {
        case .add:
            return self.pop().pop().apply(+).push()
        case .sub:
            return self.pop().pop().swap().apply(-).push()
        case .mul:
            return self.pop().pop().apply(*).push()
        case .div:
            return self.pop().pop().apply(/).push()
        }
    }
}

struct UnaryOperationInProgress {
    let a: UInt8
    let processor: Processor
    
    func pop() -> BinaryOperationInProgress {
        let b = processor.workingStack.last!
        return BinaryOperationInProgress(
            a: a,
            b: b,
            processor: Processor(
                workingStack: processor.workingStack.dropLast(),
                returnStack: processor.returnStack
            )
        )
    }
}

struct BinaryOperationInProgress {
    let a: UInt8
    let b: UInt8
    let processor: Processor
    
    func apply(_ operation: (UInt8, UInt8) -> UInt8) -> OperationResult {
        return OperationResult(
            result: operation(a, b),
            processor: processor
        )
    }
    
    func swap() -> BinaryOperationInProgress {
        return BinaryOperationInProgress(
            a: b,
            b: a,
            processor: processor
        )
    }
}

struct OperationResult {
    let result: UInt8
    let processor: Processor
    
    func push() -> Processor {
        return Processor(
            workingStack: processor.workingStack + [result],
            returnStack: processor.returnStack
        )
    }
}
