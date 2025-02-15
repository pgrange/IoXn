import Testing
import Nimble
@testable import IoXn

struct IoXnTests {

    @Test func opcodeAdd() async throws {
        expect(
            Processor().push(1).push(2).opcode(.add).pop().a
        ).to(equal(3))
        expect(
            Processor().push(255).push(1).opcode(.add).pop().a
        ).to(equal(0))
    }
    
    @Test func opcodeSub() async throws {
        expect(
            Processor().push(2).push(1).opcode(.sub).pop().a
        ).to(equal(1))
        expect(
            Processor().push(1).push(2).opcode(.sub).pop().a
        ).to(equal(255))
    }
    
    @Test func opcodeMul() async throws {
        expect(
            Processor().push(2).push(2).opcode(.mul).pop().a
        ).to(equal(4))
        expect(
            Processor().push(130).push(2).opcode(.mul).pop().a
        ).to(equal(4))
    }
    
    @Test func opcodeDiv() async throws {
        expect(
            Processor().push(6).push(2).opcode(.div).pop().a
        ).to(equal(3))
        expect(
            Processor().push(255).push(2).opcode(.div).pop().a
        ).to(equal(127))
        expect(
            Processor().push(12).push(0).opcode(.div).pop().a
        ).to(equal(0))
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
            return self.pop().pop().apply(&+).push()
        case .sub:
            return self.pop().pop().swap().apply(&-).push()
        case .mul:
            return self.pop().pop().apply(&*).push()
        case .div:
            return self.pop().pop().swap().apply(
                { a, b in b == 0 ? 0 : a / b}
            ).push()
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
