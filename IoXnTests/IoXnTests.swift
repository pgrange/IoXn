import Testing
import Nimble
@testable import IoXn

/**
 Instruction set uxn https://wiki.xxiivv.com/site/uxntal_reference.html
 Varvara specification https://wiki.xxiivv.com/site/varvara.html?utm_source=chatgpt.com
 Implementation guide https://github.com/DeltaF1/uxn-impl-guide?utm_source=chatgpt.com
 */

struct IoXnArithemticTests {
    
    @Test func opcodeInc() async throws {
        expect(Processor()
            .push(6)
            .opcode(.inc)
        ).to(equal(Processor().with(
            workingStack: [7]
        )))
        
        expect(Processor()
            .push(6)
            .opcode(.inck)
        ).to(equal(Processor().with(
            workingStack: [6, 7]
        )))
        
        expect(Processor()
            .push(6)
            .push(255)
            .opcode(.inc2)
        ).to(equal(Processor().with(
            workingStack: oneWordAsByteArray(1792)
        )))
        
        expect(Processor()
            .push(6)
            .push(255)
            .opcode(.inc2k)
        ).to(equal(Processor().with(
            workingStack: [6, 255] + oneWordAsByteArray(1792)
        )))
    }
    
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
}

struct IoXnStackTests {
    
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
}

struct IoXnMemoryTests {
    @Test func opcodeLdz() async throws {
        let initialMemory = Memory()
            .write(UInt8(2), 250)
            .write(UInt8(3), 12)
        
        expect(Processor().with(memory: initialMemory)
            .push(2)
            .opcode(.ldz)
        ).to(equal(Processor().with(
            workingStack: [250],
            memory: initialMemory
        )))

        expect(Processor().with(memory: initialMemory)
            .push(0).push(2)
            .opcode(.ldz2)
        ).to(equal(Processor().with(
            workingStack: [250, 12],
            memory: initialMemory
        )))

    }
    
    @Test func opcodeStz() async throws {
        expect(Processor()
            .push(2)
            .push(250)
            .opcode(.stz)
        ).to(equal(Processor().with(
            memory: Memory().write(UInt8(250), 2)
        )))
        
        expect(Processor()
            .push(2)
            .push(3)
            .push(250)
            .opcode(.stz2)
        ).to(equal(Processor().with(
            memory: Memory()
                .write(UInt8(250), 2)
                .write(UInt8(251), 3)
        )))

    }
}

struct IoXnProgramCounterTests {
    @Test func opcodeJmp() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(2)
            .opcode(.jmp)
       ).to(equal(Processor().with(
            programCounter: 12045
       )))
        
        expect(Processor().with(programCounter: 12043)
            .push(0 &- 2)
            .opcode(.jmp)
       ).to(equal(Processor().with(
            programCounter: 12041
        )))
    }
    @Test func opcodeJcn() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(2)
            .opcode(.jcn)
        ).to(equal(Processor().with(
            programCounter: 12045
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(0)
            .push(2)
            .opcode(.jcn).programCounter
        ).to(equal(12043))
    }
    
    @Test func opcodeJsr() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .opcode(.jsr)
        ).to(equal(Processor().with(
            programCounter: 12048,
            returnStack: oneWordAsByteArray(12043)
        )))
    }
}

func oneWordAsByteArray(_ value: UInt16) -> [UInt8] {
    let highByte: UInt8 = UInt8((value & 0xFF00) >> 8)
    let lowByte: UInt8 = UInt8(value & 0x00FF)
    return [highByte, lowByte]
}

func oneWordAsTwoBytes(_ value: UInt16) -> (UInt8, UInt8) {
    let highByte: UInt8 = UInt8((value & 0xFF00) >> 8)
    let lowByte: UInt8 = UInt8(value & 0x00FF)
    return (highByte, lowByte)
}

func twoBytesAsOneWord(_ highByte: UInt8, _ lowByte: UInt8) -> UInt16 {
    return UInt16(highByte) << 8 | UInt16(lowByte)
}

enum Opcode {
    case inc
    case inck
    case inc2
    case inc2k
    case add
    case sub
    case mul
    case div
    case rot
    case dup
    case ovr
    case sth
    case ldz
    case ldz2
    case stz
    case stz2
    case jmp
    case jcn
    case jsr
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
    
    func read<N: Operand>(_ address: UInt16, as type: N.Type) -> N {
        if N.sizeInBytes == 1 {
            return N(data[address] ?? 0)
        } else {
            let high = data[address] ?? 0
            let low = data[address &+ 1] ?? 0
            return N(twoBytesAsOneWord(high, low))
        }
    }
    
    func write<N: Operand>(_ address: UInt16, _ value: N, as type: N.Type) -> Memory {
        var data = self.data
        if (N.sizeInBytes == 1) {
            data[address] = UInt8(value)
        } else {
            let (high, low) = oneWordAsTwoBytes(UInt16(value))
            data[address] = high
            data[address &+ 1] = low
        }
        return Memory(data: data)
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
    let programCounter: UInt16
    
    private init(
        memory: Memory = Memory(),
        workingStack: [UInt8] = [],
        returnStack: [UInt8] = [],
        programCounter: UInt16 = 0x100
    ) {
        self.memory = memory
        self.workingStack = workingStack
        self.returnStack = returnStack
        self.programCounter = programCounter
    }
    
    init() {
        self.init(memory: Memory())
    }
    
    func with(
        programCounter: UInt16? = nil,
        workingStack: [UInt8]? = nil,
        returnStack: [UInt8]? = nil,
        memory: Memory? = nil
    ) -> Processor {
        return Processor(
            memory: memory ?? self.memory,
            workingStack: workingStack ?? self.workingStack,
            returnStack: returnStack ?? self.returnStack,
            programCounter: programCounter ?? self.programCounter
        )
    }
    
    func push(_ value: UInt8) -> Processor {
        return self.with(
            workingStack: workingStack + [value]
        )
    }
    
    private func inc<N: Operand>(_ mark: N.Type) -> Processor {
        let inc: N = .fromByteArray([UInt8](repeating: 0, count: N.sizeInBytes - 1) + [1])
        return Instruction<N>(self).pop().apply11({ a in a &+ inc}).push()
    }
    
    private func inck<N: Operand>(_ mark: N.Type) -> Processor {
        let inc: N = .fromByteArray([UInt8](repeating: 0, count: N.sizeInBytes - 1) + [1])
        return Instruction<N>(self).pop().apply12({ a in (a, a &+ inc) }).push().push()
    }
    
    private func add<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self).pop().pop().apply21(&+).push()
    }
    
    private func sub<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self).pop().pop().apply21(&-).push()
    }

    private func mul<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self).pop().pop().apply21(&*).push()
    }

    private func div<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self).pop().pop().apply21({ a, b in b == 0 ? 0 : a / b}).push()
    }

    private func rot<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .pop().pop().pop()
            .apply33({ a, b, c in (b, c, a) })
            .push().push().push()
    }
    
    private func dup<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .pop().apply12( { a in (a, a) } ).push().push()
    }

    private func ovr<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .pop().pop().apply23( { a, b in (a, b, a) } ).push().push().push()
    }
    
    private func sth<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .pop().apply11( { a in a } ).push(.returnStack)
    }

    private func ldz<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .pop().apply11( { a in memory.read(UInt16(a), as: N.self) } ).push()
    }

    private func stz<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .popByte().pop()
            .apply( { op in
                op.processor.with(memory: op.processor.memory.write(UInt16(op.b), op.a, as: N.self))
            } )
    }
    
    func opcode(_ opcode: Opcode) -> Processor {
        switch opcode {
        case .inc:
            return inc(UInt8.self)
        case .inc2:
            return inc(UInt16.self)
        case .inck:
            return inck(UInt8.self)
        case .inc2k:
            return inck(UInt16.self)
        case .add:
            return add(UInt8.self)
        case .sub:
            return sub(UInt8.self)
        case .mul:
            return mul(UInt8.self)
        case .div:
            return div(UInt8.self)
        case .rot:
            return rot(UInt8.self)
        case .dup:
            return dup(UInt8.self)
        case .ovr:
            return ovr(UInt8.self)
        case .sth:
            return sth(UInt8.self)
        case .ldz:
            return ldz(UInt8.self)
        case .ldz2:
            return ldz(UInt16.self)
        case .stz:
            return stz(UInt8.self)
        case .stz2:
            return stz(UInt16.self)
        case .jmp:
            return Instruction<UInt8>(self)
                .pop()
                .apply( { op in jump(op.processor, offset: op.a) } )
        case .jcn:
            return Instruction<UInt8>(self)
                .pop().pop()
                .apply( { op in op.a != 0
                    ? jump(op.processor, offset: op.b)
                    : op.processor
                })
        case .jsr:
            return Instruction<UInt8>(self)
                .pop().apply( { op in
                jump(op.processor, offset: op.a)
                    .with(returnStack: returnStack + oneWordAsByteArray(op.processor.programCounter))
            } )
        }
    }
    private func jump(_ processor: Processor, offset: UInt8) -> Processor {
        let offsetAsUInt16: UInt16 = offset < 128
        ? UInt16(offset)
        : UInt16(offset) | 0xFF00
        
        return processor.with(programCounter: programCounter &+ offsetAsUInt16)
    }
}

struct Instruction<n: Operand> {
    let processor: Processor
    
    init(_ processor: Processor) {
        self.processor = processor
    }
    
    func pop() -> UnaryOperationInProgress<n> {
        let size = n.sizeInBytes
        let suffix: [UInt8] = processor.workingStack.suffix(size)
        let a: n = .fromByteArray(suffix)
        return UnaryOperationInProgress(
            a: a,
            processor: processor.with(
                workingStack: processor.workingStack.dropLast(size)
            )
        )
    }
    
    func popByte() -> UnaryOperationInProgress<n> {
        let a: n = n(processor.workingStack.last!)
        return UnaryOperationInProgress(
            a: a,
            processor: processor.with(
                workingStack: processor.workingStack.dropLast()
            )
        )
    }

}

struct UnaryOperationInProgress<n: Operand> {
    let a: n
    let processor: Processor
    
    func pop() -> BinaryOperationInProgress<n> {
        let size = n.sizeInBytes
        let suffix: [UInt8] = processor.workingStack.suffix(size)
        let b: n = .fromByteArray(suffix)
        return BinaryOperationInProgress(
            a: b,
            b: a,
            processor: processor.with(
                workingStack: processor.workingStack.dropLast(size)
            )
        )
    }
    
    func apply(_ operation: (UnaryOperationInProgress<n>) -> Processor) -> Processor {
        return operation(self)
    }
    
    func apply11(_ operation: (n) -> n) -> OperationUnaryResult<n> {
        return OperationUnaryResult<n>(
            result: operation(a),
            processor: processor
        )
    }

    func apply12(_ operation: (n) -> (n, n)) -> OperationBinaryResult<n> {
        let (resultA, resultB) = operation(a)
        return OperationBinaryResult(
            resultA: resultA,
            resultB: resultB,
            processor: processor
        )
    }
}

struct BinaryOperationInProgress<N: Operand> {
    let a: N
    let b: N
    let processor: Processor
    
    func pop() -> TernaryOperationInProgress<N> {
        let size = N.sizeInBytes
        let suffix: [UInt8] = processor.workingStack.suffix(size)
        let c: N = .fromByteArray(suffix)
        return TernaryOperationInProgress(
            a: c,
            b: a,
            c: b,
            processor: processor.with(
                workingStack: processor.workingStack.dropLast(size)
            )
        )
    }
    
    func apply(_ operation: (BinaryOperationInProgress<N>) -> Processor) -> Processor {
        return operation(self)
    }

    func apply21(_ operation: (N, N) -> N) -> OperationUnaryResult<N> {
        return OperationUnaryResult(
            result: operation(a, b),
            processor: processor
        )
    }
    
    func apply23(_ operation: (N, N) -> (N, N, N)) -> OperationTernaryResult<N> {
        let (a, b, c) = operation(a, b)
        return OperationTernaryResult(
            resultA: a,
            resultB: b,
            resultC: c,
            processor: processor
        )
    }
}

struct TernaryOperationInProgress<N: Operand> {
    let a: N
    let b: N
    let c: N
    let processor: Processor
    
    func apply33(_ operation: (N, N, N) -> (N, N, N)) -> OperationTernaryResult<N> {
        let (resultA, resultB, resultC) = operation(a, b, c)
        return OperationTernaryResult(
            resultA: resultA,
            resultB: resultB,
            resultC: resultC,
            processor: processor
        )
    }
}

struct OperationUnaryResult<n: Operand> {
    let result: n
    let processor: Processor
    
    func push(_ stack: Stack = .workingStack) -> Processor {
        switch stack {
        case .workingStack:
            return processor.with(
                workingStack: processor.workingStack + result.toByteArray()
            )
        case .returnStack:
            return processor.with(
                returnStack: processor.returnStack + result.toByteArray()
            )
        }
    }
}

struct OperationBinaryResult<n: Operand> {
    let resultA: n
    let resultB: n
    let processor: Processor
    
    func push() -> OperationUnaryResult<n> {
        return OperationUnaryResult(
            result: resultB,
            processor: processor.with(
                workingStack: processor.workingStack + resultA.toByteArray()
            )
        )
    }
}

struct OperationTernaryResult<N: Operand> {
    let resultA: N
    let resultB: N
    let resultC: N
    let processor: Processor
    
    func push() -> OperationBinaryResult<N> {
        return OperationBinaryResult(
            resultA: resultB,
            resultB: resultC,
            processor: processor.with (
                workingStack: processor.workingStack + resultA.toByteArray()
            )
        )
    }
}

protocol Operand: FixedWidthInteger {
    func toByteArray() -> [UInt8]
    static func fromByteArray(_ byteArray: [UInt8]) -> Self
    static var sizeInBytes: Int { get }
}
        
extension UInt8: Operand {
    static func fromByteArray(_ byteArray: [UInt8]) -> UInt8 {
        byteArray[0]
    }
    
    static var sizeInBytes: Int {
        1
    }
    
    func toByteArray() -> [UInt8] {
        [self]
    }
}

extension UInt16: Operand {
    static func fromByteArray(_ byteArray: [UInt8]) -> UInt16 {
        twoBytesAsOneWord(byteArray[0], byteArray[1])
    }
    
    static var sizeInBytes: Int {
        2
    }
    
    func toByteArray() -> [UInt8] {
        oneWordAsByteArray(self)
    }
}
