import Testing
import Nimble
@testable import IoXn

/**
 Instruction set uxn https://wiki.xxiivv.com/site/uxntal_reference.html
 Varvara specification https://wiki.xxiivv.com/site/varvara.html
 Implementation guide https://github.com/DeltaF1/uxn-impl-guide
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
    
    @Test func opcodePop() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .opcode(.pop)
        ).to(equal(Processor().with(
            workingStack: [1, 2]
        )))

        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .opcode(.popk)
        ).to(equal(Processor().with(
            workingStack: [1, 2, 3]
        )))
        
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .opcode(.pop2)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        
        expect(Processor()
            .push(1, .returnStack)
            .push(2, .returnStack)
            .push(3, .returnStack)
            .opcode(.pop2kr)
        ).to(equal(Processor().with(
            returnStack: [1, 2, 3]
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
        expect(Processor()
            .push(2)
            .opcode(.sth)
        ).to(equal(Processor().with(
            returnStack: [2]
        )))
        
        expect(Processor()
            .push(2, .returnStack)
            .opcode(.sthr)
        ).to(equal(Processor().with(
            workingStack: [2]
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
    case inc2
    case incr
    case inc2r
    case inck
    case inc2k
    case inckr
    case inc2kr
    case pop
    case popk
    case pop2
    case pop2kr
    
    case add
    case sub
    case mul
    case div
    case rot
    case dup
    case ovr
    case sth
    case sthr
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

    static prefix func !(stack: Stack) -> Stack {
        return (stack == .workingStack) ? .returnStack : .workingStack
    }
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
    
    func push(_ value: UInt8,_ stack: Stack = .workingStack) -> Processor {
        return push([value], stack)
    }
    
    func push(_ value: [UInt8], _ stack: Stack = .workingStack) -> Processor {
        switch stack {
        case .workingStack:
            return self.with(
                workingStack: workingStack + value
            )
        case .returnStack:
            return self.with(
                returnStack: returnStack + value
            )
        }
    }
    
    func pop(_ size: Int = 1, _ stack: Stack = .workingStack) -> ([UInt8], Self) {
        return switch stack {
        case .workingStack: (
            workingStack.suffix(size),
            self.with(workingStack: workingStack.dropLast(size))
        )
        case .returnStack: (
            returnStack.suffix(size),
            self.with(returnStack: returnStack.dropLast(size))
        )
        }
    }
    
    private func inc<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        let inc: N = .fromByteArray([UInt8](repeating: 0, count: N.sizeInBytes - 1) + [1])
        return instruction.pop().apply11({ a in a &+ inc}).push()
    }
    
    private func pop<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().drop()
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
    
    private func sth<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().apply11( { a in a } ).push(.returnStack)
    }

    private func ldz<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .pop().apply11( { a in memory.read(UInt16(a), as: N.self) } ).push()
    }

    private func stz<N: Operand>(_ mark: N.Type) -> Processor {
        return Instruction<N>(self)
            .popByte().pop()
            .writeToMemory({ a, b in (UInt16(b), a) })
    }
    
    func opcode(_ opcode: Opcode) -> Processor {
        switch opcode {
        case .inc:
            return inc(Instruction<UInt8>(self))
        case .incr:
            return inc(Instruction<UInt8>(self, reverseStack: true))
        case .inc2:
            return inc(Instruction<UInt16>(self))
        case .inc2r:
            return inc(Instruction<UInt16>(self, reverseStack: true))
        case .inck:
            return inc(Instruction<UInt8>(self, keepStack: true))
        case .inckr:
            return inc(Instruction<UInt8>(self, reverseStack: true, keepStack: true))
        case .inc2k:
            return inc(Instruction<UInt16>(self, keepStack: true))
        case .inc2kr:
            return inc(Instruction<UInt16>(self, reverseStack: true, keepStack: true))
        case .pop:
            return pop(Instruction<UInt8>(self))
        case .popk:
            return pop(Instruction<UInt8>(self, keepStack: true))
        case .pop2:
            return pop(Instruction<UInt16>(self))
        case .pop2kr:
            return pop(Instruction<UInt16>(self, reverseStack: true, keepStack: true))
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
            return sth(Instruction<UInt8>(self))
        case .sthr:
            return sth(Instruction<UInt8>(self, reverseStack: true))
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
                .applyProgramCounter( { pc, a in jump(pc: pc, offset: a) } )
        case .jcn:
            return Instruction<UInt8>(self)
                .pop().pop()
                .applyProgramCounter( { pc, a, b in a != 0
                    ? jump(pc: pc, offset: b)
                    : pc
                })
        case .jsr:
            return Instruction<UInt16>(self)
                .popByte()
                .applyProgramCounter11( { pc, a in (jump(pc: pc, offset: UInt8(a)), pc) })
                .push(.returnStack)
        }
    }
    private func jump(pc: UInt16, offset: UInt8) -> UInt16 {
        let offsetAsUInt16: UInt16 = offset < 128
        ? UInt16(offset)
        : UInt16(offset) | 0xFF00
        
        return pc &+ offsetAsUInt16
    }
}

struct InstructionState<N: Operand> {
    private let processor: Processor
    private let reverseStack: Bool
    private let keepStack: Bool
    private let popped: [UInt8]
    
    var programCounter: UInt16 { processor.programCounter }
    
    init(processor: Processor, reverseStack: Bool = false, keepStack: Bool = false) {
        self.init(processor: processor, reverseStack: reverseStack, keepStack: keepStack, popped: [])
    }
    
    private init(processor: Processor, reverseStack: Bool, keepStack: Bool, popped: [UInt8]) {
        self.processor = processor
        self.reverseStack = reverseStack
        self.keepStack = keepStack
        self.popped = popped
    }
    
    private func with(
        processor: Processor? = nil,
        popped: [UInt8]? = nil
    ) -> InstructionState {
        return InstructionState(
            processor: processor ?? self.processor,
            reverseStack: reverseStack,
            keepStack: keepStack,
            popped: popped ?? self.popped
        )
    }
    
    func pop(_ stack: Stack = .workingStack) -> (N, InstructionState) {
        let (head, nextProcessor) = processor.pop(N.sizeInBytes, realStack(stack))
        let value: N = .fromByteArray(head)
        return (
            value,
            with(
                processor: nextProcessor,
                popped: popped + head.reversed()
            )
        )
    }
    
    func popByte(_ stack: Stack = .workingStack) -> (UInt8, InstructionState) {
        let (head, nextProcessor) = processor.pop(1, realStack(stack))
        let value: UInt8 = .fromByteArray(head)
        return (value, with(processor: nextProcessor, popped: popped + head))
    }
    
    func push(_ value: N, _ stack: Stack = .workingStack) -> InstructionState<N> {
        let nextProcessor = keepStack ? processor.push(popped.reversed(), realStack(stack)) : processor
        return with(
            processor: nextProcessor.push(value.toByteArray(), realStack(stack)),
            popped: []
        )
    }
    
    func writeToMemory(_ address: UInt16, _ value: N) -> InstructionState<N> {
        return with(processor: processor.with(memory: processor.memory.write(address, value, as: N.self)))
    }
    
    func jump(to pc: UInt16) -> InstructionState<N> {
        return with(processor: processor.with(programCounter: pc))
    }
    
    func terminate() -> Processor {
        return  keepStack ? processor.push(popped.reversed(), realStack(.workingStack)) : processor
    }
    
    private func realStack(_ stack: Stack) -> Stack {
        reverseStack ? !stack : stack
    }
}

struct Instruction<N: Operand> {
    let state: InstructionState<N>
    
    init(_ processor: Processor, reverseStack: Bool = false, keepStack: Bool = false) {
        self.state = InstructionState(processor: processor, reverseStack: reverseStack, keepStack: keepStack)
    }
    
    func pop(_ stack: Stack = .workingStack) -> UnaryOperationInProgress<N> {
        let (a, nextState) = state.pop(stack)
        return UnaryOperationInProgress(
            a: a,
            state: nextState
        )
    }
    
    func popByte() -> UnaryOperationInProgress<N> {
        let (a, nextState) = state.popByte()
        return UnaryOperationInProgress(
            a: N(a),
            state: nextState
        )
    }
}

struct UnaryOperationInProgress<N: Operand> {
    let a: N
    let state: InstructionState<N>
    
    func pop(stack: Stack = .workingStack) -> BinaryOperationInProgress<N> {
        let (b, nextState) = state.pop(stack)
        return BinaryOperationInProgress(
            a: b,
            b: a,
            state: nextState
        )
    }
    
    func drop() -> Processor {
        return state.terminate()
    }
    
    func applyProgramCounter(_ operation: (UInt16, N) -> UInt16) -> Processor {
        state.jump(to: operation(state.programCounter, a)).terminate()
    }

    func applyProgramCounter11(_ operation: (UInt16, N) -> (UInt16, N)) -> OperationUnaryResult<N> {
        let (pc, result) = operation(state.programCounter, a)
        return OperationUnaryResult<N>(
            result: N(result),
            state: state.jump(to: pc)
        )
    }
    
    func apply11(_ operation: (N) -> N) -> OperationUnaryResult<N> {
        return OperationUnaryResult<N>(
            result: operation(a),
            state: state
        )
    }

    func apply12(_ operation: (N) -> (N, N)) -> OperationBinaryResult<N> {
        let (resultA, resultB) = operation(a)
        return OperationBinaryResult(
            resultA: resultA,
            resultB: resultB,
            state: state
        )
    }
}

struct BinaryOperationInProgress<N: Operand> {
    let a: N
    let b: N
    let state: InstructionState<N>
    
    func pop() -> TernaryOperationInProgress<N> {
        let (c, nextState) = state.pop()
        return TernaryOperationInProgress(
            a: c,
            b: a,
            c: b,
            state: nextState
        )
    }
    
    func writeToMemory(_ operation: (N, N) -> (UInt16, N)) -> Processor {
        let (address, value) = operation(a, b)
        return state.writeToMemory(address, value).terminate()
//        return state.processor.with(memory: state.processor.memory.write(address, value, as: N.self))
    }
    
    func applyProgramCounter(_ operation: (UInt16, N, N) -> UInt16) -> Processor {
        return state.jump(to: operation(state.programCounter, a, b)).terminate()
    }

    func apply21(_ operation: (N, N) -> N) -> OperationUnaryResult<N> {
        return OperationUnaryResult(
            result: operation(a, b),
            state: state
        )
    }
    
    func apply23(_ operation: (N, N) -> (N, N, N)) -> OperationTernaryResult<N> {
        let (a, b, c) = operation(a, b)
        return OperationTernaryResult(
            resultA: a,
            resultB: b,
            resultC: c,
            state: state
        )
    }
}

struct TernaryOperationInProgress<N: Operand> {
    let a: N
    let b: N
    let c: N
    let state: InstructionState<N>
    
    func apply33(_ operation: (N, N, N) -> (N, N, N)) -> OperationTernaryResult<N> {
        let (resultA, resultB, resultC) = operation(a, b, c)
        return OperationTernaryResult(
            resultA: resultA,
            resultB: resultB,
            resultC: resultC,
            state: state
        )
    }
}

struct OperationUnaryResult<N: Operand> {
    let result: N
    let state: InstructionState<N>
    
    func push(_ stack: Stack = .workingStack) -> Processor {
        return state.push(result, stack).terminate()
    }
}

struct OperationBinaryResult<N: Operand> {
    let resultA: N
    let resultB: N
    let state: InstructionState<N>
    
    func push() -> OperationUnaryResult<N> {
        return OperationUnaryResult(
            result: resultB,
            state: state.push(resultA)
        )
    }
}

struct OperationTernaryResult<N: Operand> {
    let resultA: N
    let resultB: N
    let resultC: N
    let state: InstructionState<N>
    
    func push() -> OperationBinaryResult<N> {
        return OperationBinaryResult(
            resultA: resultB,
            resultB: resultC,
            state: state.push(resultA)
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
