import Testing
import Nimble
@testable import IoXn

/**
 Instruction set uxn https://wiki.xxiivv.com/site/uxntal_reference.html
 Varvara specification https://wiki.xxiivv.com/site/varvara.html?utm_source=chatgpt.com
 Implementation guide https://github.com/DeltaF1/uxn-impl-guide?utm_source=chatgpt.com
 */

struct IoXnTests {
    
    @Test func opcodeAdd() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .opcode(.add)
        ).to(equal(Processor().with(
            workingStack: [3]
        )))
        
        expect(Processor()
            .push(255)
            .push(1)
            .opcode(.add)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeSub() async throws {
        expect(Processor()
            .push(2)
            .push(1)
            .opcode(.sub)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        
        expect(Processor()
            .push(1)
            .push(2)
            .opcode(.sub)
        ).to(equal(Processor().with(
            workingStack: [255]
        )))
    }
    
    @Test func opcodeMul() async throws {
        expect(Processor()
            .push(2)
            .push(2)
            .opcode(.mul)
        ).to(equal(Processor().with(
            workingStack: [4]
        )))
        
        expect(Processor()
            .push(130)
            .push(2)
            .opcode(.mul)
        ).to(equal(Processor().with(
            workingStack: [4]
        )))
    }
    
    @Test func opcodeDiv() async throws {
        expect(Processor()
            .push(6)
            .push(2)
            .opcode(.div)
        ).to(equal(Processor().with(
            workingStack: [3]
        )))
            
        expect(Processor()
            .push(255)
            .push(2)
            .opcode(.div)
        ).to(equal(Processor().with(
            workingStack: [127]
        )))
        
        expect(Processor()
            .push(12)
            .push(0)
            .opcode(.div)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeRot() async throws {
        let result = Processor()
            .push(1)
            .push(2)
            .push(3)
            .opcode(.rot)
        
        expect(result).to(equal(Processor().with(
            workingStack: [2, 3, 1]
        )))
    }
    
    @Test func opcodeDup() async throws {
        let result = Processor()
            .push(1)
            .push(2)
            .opcode(.dup)
        
        expect(result).to(equal(Processor().with(
            workingStack: [1, 2, 2]
        )))
    }

    @Test func opcodeOvr() async throws {
        let processor = Processor()
            .push(1)
            .push(2)
            .opcode(.ovr)
        
        expect(processor).to(equal(Processor().with(
            workingStack: [1, 2, 1]
        )))
    }
    
    @Test func opcodeSth() async throws {
        let processor = Processor()
            .push(2)
            .opcode(.sth)
        
        expect(processor).to(equal(Processor().with(
            returnStack: [2]
        )))
    }
    
    @Test func opcodeLdz() async throws {
        let initialMemory = Memory().write(UInt8(2), 250)
        
        let processor = Processor().with(memory: initialMemory)
            .push(2)
            .opcode(.ldz)
        
        expect(processor).to(equal(Processor().with(
            memory: initialMemory,
            workingStack: [250]
        )))
    }
    
    @Test func opcodeStz() async throws {
        let processor = Processor()
            .push(2)
            .push(250)
            .opcode(.stz)
        
        expect(processor).to(equal(Processor().with(
            memory: Memory().write(UInt8(250), 2)
        )))
    }
}

enum Opcode {
    case add
    case sub
    case mul
    case div
    case rot
    case dup
    case ovr
    case sth
    case ldz
    case stz
}

enum Stack {
    case workingStack
    case returnStack
}

struct Memory : Equatable {
    let data: [UInt16: UInt8]
    
    init(data: [UInt16 : UInt8]) {
        self.data = data
    }
    
    init() {
        self.data = [UInt16:UInt8]()
    }
    
    func read(_ address: UInt16) -> UInt8 {
        return data[address] ?? 0
    }
    
    func read(_ address: UInt8) -> UInt8 {
        return self.read(UInt16(address))
    }
    
    
    func write(_ address: UInt16, _ value: UInt8) -> Memory {
        var data = self.data
        data[address] = value
        return Memory(data: data)
    }
    
    func write(_ address: UInt8, _ value: UInt8) -> Memory {
        return self.write(UInt16(address), value)
    }
    
    static func == (lhs: Memory, rhs: Memory) -> Bool {
        lhs.data == rhs.data
    }
}

struct Processor : Equatable {
    let memory: Memory
    let workingStack: [UInt8]
    let returnStack: [UInt8]
    
    private init(memory: Memory = Memory(), workingStack: [UInt8] = [], returnStack: [UInt8] = []) {
        self.memory = memory
        self.workingStack = workingStack
        self.returnStack = returnStack
    }
    
    init() {
        self.init(memory: Memory())
    }
    
    func with(memory: Memory? = nil, workingStack: [UInt8]? = nil, returnStack: [UInt8]? = nil) -> Processor {
        return Processor(
            memory: memory ?? self.memory,
            workingStack: workingStack ?? self.workingStack,
            returnStack: returnStack ?? self.returnStack
        )
    }
    
    func push(_ value: UInt8) -> Processor {
        return self.with(
            workingStack: workingStack + [value]
        )
    }
    
    func pop() -> UnaryOperationInProgress {
        let a = workingStack.last!
        return UnaryOperationInProgress(
            a: a,
            processor: self.with(
                workingStack: workingStack.dropLast()
            )
        )
    }
    
    func peek() -> UnaryOperationInProgress {
        let a = workingStack.last!
        return UnaryOperationInProgress(
            a: a,
            processor: self
        )
    }
    
    func opcode(_ opcode: Opcode) -> Processor {
        switch opcode {
        case .add:
            return self.pop().pop().apply21(&+).push()
        case .sub:
            return self.pop().pop().apply21(&-).push()
        case .mul:
            return self.pop().pop().apply21(&*).push()
        case .div:
            return self.pop().pop().apply21(
                { a, b in b == 0 ? 0 : a / b}
            ).push()
        case .rot:
            return self.pop().pop().pop().apply33({
                a, b, c in (b, c, a)
            }).push().push().push()
        case .dup:
            return self.peek().apply11( { a in a } ).push()
        case .ovr:
            return self.pop().pop().apply23( { a, b in (a, b, a) } ).push().push().push()
        case .sth:
            return self.pop().apply11( { a in a } ).push(.returnStack)
        case .ldz:
            return self.pop().apply11( { a in self.memory.read(a) } ).push()
        case .stz:
            return self
                .pop().pop()
                .apply( { op in
                    op.processor.with(memory: op.processor.memory.write(op.b, op.a))
                } )
        }
    }
}

struct UnaryOperationInProgress {
    let a: UInt8
    let processor: Processor
    
    func pop() -> BinaryOperationInProgress {
        let b = processor.workingStack.last!
        return BinaryOperationInProgress(
            a: b,
            b: a,
            processor: processor.with(
                workingStack: processor.workingStack.dropLast()
            )
        )
    }
    
    func apply11(_ operation: (UInt8) -> UInt8) -> OperationUnaryResult {
        return OperationUnaryResult(
            result: operation(a),
            processor: processor
        )
    }

}

struct BinaryOperationInProgress {
    let a: UInt8
    let b: UInt8
    let processor: Processor
    
    func apply(_ operation: (BinaryOperationInProgress) -> Processor) -> Processor {
        return operation(self)
    }
    
    func apply21(_ operation: (UInt8, UInt8) -> UInt8) -> OperationUnaryResult {
        return OperationUnaryResult(
            result: operation(a, b),
            processor: processor
        )
    }
    
    func apply23(_ operation: (UInt8, UInt8) -> (UInt8, UInt8, UInt8)) -> OperationTernaryResult {
        let (a, b, c) = operation(a, b)
        return OperationTernaryResult(
            resultA: a,
            resultB: b,
            resultC: c,
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
    
    func pop() -> TernaryOperationInProgress {
        let c = processor.workingStack.last!
        return TernaryOperationInProgress(
            a: c,
            b: a,
            c: b,
            processor: processor.with(
                workingStack: processor.workingStack.dropLast()
            )
        )
    }
}

struct TernaryOperationInProgress {
    let a: UInt8
    let b: UInt8
    let c: UInt8
    let processor: Processor
    
    func apply33(_ operation: (UInt8, UInt8, UInt8) -> (UInt8, UInt8, UInt8)) -> OperationTernaryResult {
        let (resultA, resultB, resultC) = operation(a, b, c)
        return OperationTernaryResult(
            resultA: resultA,
            resultB: resultB,
            resultC: resultC,
            processor: processor
        )
    }
}

struct OperationUnaryResult {
    let result: UInt8
    let processor: Processor
    
    func push(_ stack: Stack = .workingStack) -> Processor {
        switch stack {
        case .workingStack:
            return processor.with(
                workingStack: processor.workingStack + [result]
            )
        case .returnStack:
            return processor.with(
                returnStack: processor.returnStack + [result]
            )
        }
    }
}

struct OperationTernaryResult {
    let resultA: UInt8
    let resultB: UInt8
    let resultC: UInt8
    let processor: Processor
    
    func push() -> OperationBinaryResult {
        return OperationBinaryResult(
            resultA: resultB,
            resultB: resultC,
            processor: processor.with (
                workingStack: processor.workingStack + [resultA]
            )
        )
    }
}

struct OperationBinaryResult {
    let resultA: UInt8
    let resultB: UInt8
    let processor: Processor
    
    func push() -> OperationUnaryResult {
        return OperationUnaryResult(
            result: resultB,
            processor: processor.with (
                workingStack: processor.workingStack + [resultA]
            )
        )
    }
}
