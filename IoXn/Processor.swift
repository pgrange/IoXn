private enum Opcode: UInt8 {
    case brk = 0x00
    case inc = 0x01
    
    case pop = 0x02
    case nip = 0x03
    case swp = 0x04
    case rot = 0x05
    case dup = 0x06
    case ovr = 0x07
    
    case equ = 0x08
    case neq = 0x09
    case gth = 0x0a
    case lth = 0x0b
    
    case jmp = 0x0c
    case jcn = 0x0d
    case jsr = 0x0e
    
    case sth = 0x0f
    
    case ldz  = 0x10
    case stz  = 0x11
    case ldr  = 0x12
    case str  = 0x13
    case lda  = 0x14
    case sta  = 0x15


    case dei  = 0x16
    case deo  = 0x17
    
    case add = 0x18
    case sub = 0x19
    case mul = 0x1a
    case div = 0x1b
    
    case and = 0x1c
    case ora = 0x1d
    case eor = 0x1e
    case sft = 0x1f
    
    case jci = 0x20
    case jmi = 0x40
    case jsi = 0x60
    
    case lit = 0x80
}

enum Stack {
    case workingStack
    case returnStack

    static prefix func !(stack: Stack) -> Stack {
        return (stack == .workingStack) ? .returnStack : .workingStack
    }
}

struct Processor : Equatable {
    let workingStack: [UInt8]
    let returnStack: [UInt8]
    
    private init(
        workingStack: [UInt8],
        returnStack: [UInt8]
    ) {
        self.workingStack = workingStack
        self.returnStack = returnStack
    }
    
    init() {
        self.init(
            workingStack: [],
            returnStack: []
        )
    }
    
    func with(
        workingStack: [UInt8]? = nil,
        returnStack: [UInt8]? = nil
    ) -> Processor {
        return Processor(
            workingStack: workingStack ?? self.workingStack,
            returnStack: returnStack ?? self.returnStack
        )
    }
    
    func push(_ value: UInt8,_ stack: Stack = .workingStack) -> Processor {
        return push([value], stack)
    }
    
    func push(_ value: [UInt8], _ stack: Stack = .workingStack) -> Processor {
        return switch stack {
        case .workingStack:
            self.with(
                workingStack: workingStack + value
            )
        case .returnStack:
            self.with(
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
    
    private func step_<N: Operand>(programCounter: UInt16, memory: Memory, devices: Devices, for: N.Type, reverseStack: Bool, keepStack: Bool, opcode: Opcode) -> (Processor, Memory, UpdateProgramCounter) {
        let instruction = Instruction<N>(self, programCounter, memory, devices, reverseStack: reverseStack, keepStack: keepStack)
        switch opcode {
        case .brk:
            return (self, memory, { _ in nil })
            
        case .inc:
            return inc(instruction)
            
        case .pop:
            return popi(instruction)
        case .nip:
            return nip(instruction)
        case .swp:
            return swp(instruction)
        case .rot:
            return rot(instruction)
        case .dup:
            return dup(instruction)
        case .ovr:
            return ovr(instruction)
            
        case .equ:
            return equ(instruction)
        case .neq:
            return neq(instruction)
        case .gth:
            return gth(instruction)
        case .lth:
            return lth(instruction)
        
        case .jmp:
            return jmp(instruction)
        case .jcn:
            return jcn(instruction)
        case .jsr:
            return jsr(instruction)

        case .sth:
            return sth(instruction)
        
        case .ldz:
            return ldz(instruction)
        case .stz:
            return stz(instruction)
        case .ldr:
            return ldr(instruction)
        case .str:
            return str(instruction)
        case .lda:
            return lda(instruction)
        case .sta:
            return sta(instruction)
        
        case .dei:
            return dei(instruction)
        case .deo:
            return deo(instruction)
        
        case .add:
            return add(instruction)
        case .sub:
            return sub(instruction)
        case .mul:
            return mul(instruction)
        case .div:
            return div(instruction)
            
        case .and:
            return and(instruction)
        case .ora:
            return ora(instruction)
        case .eor:
            return eor(instruction)
        case .sft:
            return sft(instruction)
            
        case .lit:
            return lit(instruction)
            
        case .jci, .jmi, .jsi:
            fatalError("Unreachable: \(opcode) is handled by step(CompleteOpcode)")
        }
    }
    
    func step(_ rawOpcode: UInt8,
              withMemory memory: Memory,
              withDevices devices: Devices = Devices(),
              programCounter: UInt16 = 0x100
    ) -> (processor: Processor, memory: Memory, updateProgramCounter: UpdateProgramCounter) {
        let keep = rawOpcode    & 0x80 == 0x00 ? false : true
        let reverse = rawOpcode & 0x40 == 0x00 ? false : true
        let size : any Operand.Type = rawOpcode & 0x20 == 0x00 ? UInt8.self : UInt16.self
        
        switch rawOpcode {
        case Opcode.jci.rawValue:
            return jci(Instruction<UInt8>(self, programCounter, memory, devices))
        case Opcode.jmi.rawValue:
            return jmi(Instruction<UInt8>(self, programCounter, memory, devices))
        case Opcode.jsi.rawValue:
            return jsi(Instruction<UInt16>(self, programCounter, memory, devices))
        case Opcode.lit.rawValue, Opcode.lit.rawValue | 0x20:
            return step_(
                programCounter: programCounter,
                memory: memory,
                devices: devices,
                for: size,
                reverseStack: reverse,
                keepStack: keep,
                opcode: Opcode(rawValue: rawOpcode & 0x9F)!
            )
        default:
            return step_(
                programCounter: programCounter,
                memory: memory,
                devices: devices,
                for: size,
                reverseStack: reverse,
                keepStack: keep,
                opcode: Opcode(rawValue: rawOpcode & 0x1F)!
            )
        }
    }
}

func runDebug(_ processor: Processor, from programCounter: UInt16, withMemory memory: Memory, withDevices devices: Devices)
-> (processor: Processor, memory: Memory) {
    let opCode = memory.read(programCounter, as: UInt8.self)
    let (processor, memory, updateProgramCounter) = processor.step(opCode, withMemory: memory, withDevices: devices, programCounter: programCounter)
    guard let nextProgramCounter = updateProgramCounter(programCounter) else {
        return (processor, memory)
    }
    return runDebug(processor, from: nextProgramCounter, withMemory: memory, withDevices: devices)
}

func run(_ processor: Processor, from programCounter: UInt16, withMemory memory: Memory, withDevices devices: Devices)
-> (processor: Processor, memory: Memory) {
    var processor = processor
    var programCounter = programCounter
    var memory = memory
    var updateProgramCounter: UpdateProgramCounter
    
    while true {
        let opCode = memory.read(programCounter, as: UInt8.self)
        (processor, memory, updateProgramCounter) = processor.step(opCode, withMemory: memory, withDevices: devices, programCounter: programCounter)
        
        guard let nextProgramCounter = updateProgramCounter(programCounter) else {
            return (processor, memory)
        }
        programCounter = nextProgramCounter
    }
}

private struct InstructionState<N: Operand> {
    private let processor: Processor
    let programCounter: UInt16 //TODO make it private and abstract actual pc computation for later
    private let memory: Memory
    private let devices: Devices
    private let reverseStack: Bool
    private let keepStack: Bool
    private let popped: [UInt8]
    private let updateProgramCounter: UpdateProgramCounter
    
    init(
        processor: Processor,
        programCounter: UInt16,
        memory: Memory,
        devices: Devices,
        reverseStack: Bool = false,
        keepStack: Bool = false
    ){
        self.init(
            processor: processor,
            programCounter: programCounter,
            updateProgramCounter: { pc in pc &+ 1 },
            memory: memory,
            devices: devices,
            reverseStack: reverseStack,
            keepStack: keepStack,
            popped: []
        )
    }
    
    private init(
        processor: Processor,
        programCounter: UInt16,
        updateProgramCounter: @escaping UpdateProgramCounter,
        memory: Memory,
        devices: Devices,
        reverseStack: Bool,
        keepStack: Bool,
        popped: [UInt8]
    ) {
        self.processor = processor
        self.programCounter = programCounter
        self.updateProgramCounter = updateProgramCounter
        self.memory = memory
        self.devices = devices
        self.reverseStack = reverseStack
        self.keepStack = keepStack
        self.popped = popped
    }
    
    private func with(
        processor: Processor? = nil,
        updateProgramCounter: UpdateProgramCounter? = nil,
        memory: Memory? = nil,
        popped: [UInt8]? = nil
    ) -> InstructionState {
        InstructionState(
            processor: processor ?? self.processor,
            programCounter: self.programCounter,
            updateProgramCounter: updateProgramCounter ?? self.updateProgramCounter,
            memory: memory ?? self.memory,
            devices: devices,
            reverseStack: reverseStack,
            keepStack: keepStack,
            popped: popped ?? self.popped
        )
    }
    
    func pop(_ stack: Stack = .workingStack) -> (N, InstructionState) {
        pop(stack, as: N.self)
    }
    
    func popByte(_ stack: Stack = .workingStack) -> (N, InstructionState) {
        let (byte, nextState) = pop(stack, as: UInt8.self)
        return (N(byte), nextState) //a byte will always fit in any N
    }
    
    func popShort(_ stack: Stack = .workingStack) -> (UInt16, InstructionState) {
        pop(stack, as: UInt16.self)
    }
    
    private func pop<n: Operand>(_ stack: Stack = .workingStack, as: n.Type) -> (n, InstructionState) {
        let (head, nextProcessor) = processor.pop(n.sizeInBytes, actualStack(stack))
        let value: n = .fromByteArray(head)
        return (
            value,
            self.with(
                processor: nextProcessor,
                popped: popped + head.reversed()
            )
        )
    }
    
    func push(_ value: N, _ stack: Stack = .workingStack) -> InstructionState<N> {
        push(value, stack, as: N.self)
    }

    func pushByte(_ value: UInt8, _ stack: Stack = .workingStack) -> InstructionState<N> {
        push(value, stack, as: UInt8.self)
    }

    func pushShort(_ value: UInt16, _ stack: Stack = .workingStack) -> InstructionState<N> {
        push(value, stack, as: UInt16.self)
    }
    
    private func push<n: Operand>(_ value: n, _ stack: Stack = .workingStack, as: n.Type) -> InstructionState<N> {
        let nextState = restoreStack()
        return nextState.with(
            processor: nextState.processor.push(value.toByteArray(), actualStack(stack))
        )
    }
    
    func writeToMemory(_ params: (address: UInt16, value: N)) -> InstructionState<N> {
        self.with(memory: memory.write(params.address, params.value))
    }
    
    func readFromMemory(_ address: UInt16) -> (N, InstructionState<N>) {
        readFromMemory(address, as: N.self)
    }
    
    func readNextFromMemory() -> (N, InstructionState<N>) {
        readFromMemory(programCounter &+ 1)
    }
    
    func readNextShortFromMemory() -> (UInt16, InstructionState<N>) {
        readFromMemory(programCounter &+ 1, as: UInt16.self)
    }
    
    private func readFromMemory<n: Operand>(_ address: UInt16, as: n.Type) -> (n, InstructionState<N>) {
        (memory.read(address, as: n.self), self)
    }
    
    func writeToDevice(_ params: (address: UInt8, value: N)) -> InstructionState<N> {
        devices.writeToDevice(address: params.address, value: params.value)
        return self
    }
    
    func readFromDevice(_ address: UInt8) -> (N, InstructionState<N>) {
        (devices.readFromDevice(address: address, as: N.self), self)
    }
    
    func jump(to pc: UInt16) -> InstructionState<N> {
        self.with(updateProgramCounter: { _ in pc } )
    }
    
    func terminate() -> (Processor, Memory, UpdateProgramCounter) {
        (restoreStack().processor, memory, updateProgramCounter)
    }
    
    private func restoreStack() -> InstructionState<N> {
        self.with(
            processor: keepStack ? processor.push(popped.reversed(), actualStack(.workingStack)) : processor,
            popped: []
        )
    }
    
    private func actualStack(_ stack: Stack) -> Stack {
        reverseStack ? !stack : stack
    }
}

private struct Instruction<N: Operand> {
    let state: InstructionState<N>
    
    init(_ processor: Processor, _ programCounter: UInt16, _ memory: Memory, _ devices: Devices, reverseStack: Bool = false, keepStack: Bool = false) {
        self.state = InstructionState(
            processor: processor,
            programCounter: programCounter,
            memory: memory,
            devices: devices,
            reverseStack: reverseStack,
            keepStack: keepStack
        )
    }
    
    func pop(_ stack: Stack = .workingStack) -> UnaryOperationInProgress<N> {
        UnaryOperationInProgress(state.pop(stack))
    }
    
    func readNextFromMemory() -> UnaryOperationInProgress<N> {
        UnaryOperationInProgress(state.readNextFromMemory())
    }
    
    func popByte() -> UnaryOperationInProgress<N> {
        UnaryOperationInProgress(state.popByte())
    }
    
    func popShort() -> UnaryShortOperationInProgress<N> {
        UnaryShortOperationInProgress(state.popShort())
    }
    
    func readNextShortFromMemory() -> UnaryShortOperationInProgress<N> {
        UnaryShortOperationInProgress(state.readNextShortFromMemory())
    }
}

private struct UnaryShortOperationInProgress<N: Operand> {
    let a: UInt16
    let state: InstructionState<N>
    
    init(_ params: (a: UInt16, state: InstructionState<N>)) {
        self.a = params.a
        self.state = params.state
    }
    
    func readFromMemory(_ operation: (UInt16) -> UInt16) -> OperationUnaryResult<N> {
        OperationUnaryResult<N>(state.readFromMemory(operation(a)))
    }
    
    func readFromMemory() -> OperationUnaryResult<N> {
        OperationUnaryResult<N>(state.readFromMemory(a))
    }
    
    func pop(_ stack: Stack = .workingStack) -> BinaryShortOperationInProgress<N> {
        BinaryShortOperationInProgress(a, state.pop(stack))
    }
    
    func applyProgramCounter(_ operation: (_ pc: UInt16, _ a: UInt16) -> (UInt16)) -> (Processor, Memory, UpdateProgramCounter) {
        state.jump(to: operation(state.programCounter, a)).terminate()
    }
    
    func applyProgramCounter1(_ operation: (_ pc: UInt16, _ a: UInt16) -> (pc: UInt16, result: N)) -> OperationUnaryResult<N> {
        let (pc, result) = operation(state.programCounter, a)
        return OperationUnaryResult<N>(
            result: result,
            state: state.jump(to: pc)
        )
    }
    
    func applyProgramCounterSave(_ operation: (_ pc: UInt16, _ a: UInt16) -> (pc: UInt16, pcToSave: UInt16)) -> OperationProgramCounterResult<N> {
        let (pc, pcToSave) = operation(state.programCounter, a)
        return OperationProgramCounterResult<N>(
            savedProgramCounter: pcToSave,
            state: state.jump(to: pc)
        )
    }
}

private struct UnaryOperationInProgress<N: Operand> {
    let a: N
    let state: InstructionState<N>
    
    init(_ params: (a: N, state: InstructionState<N>)) {
        self.a = params.a
        self.state = params.state
    }
    
    func pop(stack: Stack = .workingStack) -> BinaryOperationInProgress<N> {
        BinaryOperationInProgress(a, state.pop(stack))
    }
    
    func popByte() -> BinaryOperationInProgress<N> {
        BinaryOperationInProgress(a, state.popByte())
    }
    
    func noop() -> (Processor, Memory, UpdateProgramCounter) {
        return state.terminate()
    }
    
    func applyProgramCounter(_ operation: (_ pc: UInt16, _ a: N) -> UInt16) -> (Processor, Memory, UpdateProgramCounter) {
        state.jump(to: operation(state.programCounter, a)).terminate()
    }
    
    func applyProgramCounter1(_ operation: (_ pc: UInt16, _ a: N) -> (pc: UInt16, result: N)) -> OperationUnaryResult<N> {
        let (pc, result) = operation(state.programCounter, a)
        return OperationUnaryResult<N>(
            result: result,
            state: state.jump(to: pc)
        )
    }

    func applyProgramCounterSave(_ operation: (_ pc: UInt16, _ a: N) -> (pc: UInt16, pcToSave: UInt16)) -> OperationProgramCounterResult<N> {
        let (pc, pcToSave) = operation(state.programCounter, a)
        return OperationProgramCounterResult<N>(
            savedProgramCounter: pcToSave,
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
        OperationBinaryResult(
            results: operation(a),
            state: state
        )
    }
    
    func readFromMemory(_ operation: (N) -> UInt16) -> OperationUnaryResult<N> {
        return OperationUnaryResult<N>(state.readFromMemory(operation(a)))
    }
    
    func readFromMemoryRelative(_ operation: (_ pc: UInt16, _ a: N) -> UInt16) -> OperationUnaryResult<N> {
        return OperationUnaryResult<N>(state.readFromMemory(operation(state.programCounter, a)))
    }
    
    func readFromDevice(_ operation: (N) -> UInt8) -> OperationUnaryResult<N> {
        return OperationUnaryResult<N>(state.readFromDevice(operation(a)))
    }
    
}

private struct BinaryShortOperationInProgress<N: Operand> {
    let a: N
    let b: UInt16
    let state: InstructionState<N>
    
    init(_ b: UInt16, _ params: (a: N, state: InstructionState<N>)) {
        self.a = params.a
        self.b = b
        self.state = params.state
    }
    
    func writeToMemory(_ operation: (_ a: N, _ b: UInt16) -> (address: UInt16, value: N)) -> (Processor, Memory, UpdateProgramCounter) {
        return state.writeToMemory(operation(a, b)).terminate()
    }
    
    func applyProgramCounter(_ operation: (UInt16, N, UInt16) -> UInt16) -> (Processor, Memory, UpdateProgramCounter) {
        state.jump(to: operation(state.programCounter, a, b)).terminate()
    }
}

private struct BinaryOperationInProgress<N: Operand> {
    let a: N
    let b: N
    let state: InstructionState<N>
        
    init(_ b: N, _ params: (a: N, state: InstructionState<N>)) {
        self.a = params.a
        self.b = b
        self.state = params.state
    }
    
    func pop() -> TernaryOperationInProgress<N> {
        return TernaryOperationInProgress(a, b, state.pop())
    }
    
    func writeToMemory(_ operation: (N, N) -> (UInt16, N)) -> (Processor, Memory, UpdateProgramCounter) {
        return state.writeToMemory(operation(a, b)).terminate()
    }
    
    func writeToMemoryRelative(_ operation: (UInt16, N, N) -> (address: UInt16, value: N))
    -> (Processor, Memory, UpdateProgramCounter) {
        return state.writeToMemory(operation(state.programCounter, a, b)).terminate()
    }
    
    func writeToDevice(_ operation: (N, N) -> (UInt8, N)) -> (Processor, Memory, UpdateProgramCounter) {
        return state.writeToDevice(operation(a, b)).terminate()
    }
    
    func applyProgramCounter(_ operation: (UInt16, N, N) -> UInt16) -> (Processor, Memory, UpdateProgramCounter) {
        return state.jump(to: operation(state.programCounter, a, b)).terminate()
    }

    func apply21(_ operation: (N, N) -> N) -> OperationUnaryResult<N> {
        return OperationUnaryResult(
            result: operation(a, b),
            state: state
        )
    }
    
    func apply22(_ operation: (N, N) -> (N, N)) -> OperationBinaryResult<N> {
        OperationBinaryResult(
            results: operation(a, b),
            state: state
        )
    }
    
    func apply23(_ operation: (N, N) -> (N, N, N)) -> OperationTernaryResult<N> {
        OperationTernaryResult(
            results: operation(a, b),
            state: state
        )
    }
}

private struct TernaryOperationInProgress<N: Operand> {
    let a: N
    let b: N
    let c: N
    let state: InstructionState<N>
    
    init(_ b: N, _ c: N, _ params: (a: N, state: InstructionState<N>)) {
        self.a = params.a
        self.b = b
        self.c = c
        self.state = params.state
    }
    
    func apply33(_ operation: (N, N, N) -> (N, N, N)) -> OperationTernaryResult<N> {
        return OperationTernaryResult(
            results: operation(a, b, c),
            state: state
        )
    }
}

private struct OperationProgramCounterResult<N: Operand> {
    let savedProgramCounter: UInt16
    let state: InstructionState<N>
    
    func push(_ stack: Stack = .workingStack) -> (Processor, Memory, UpdateProgramCounter) {
        return state.pushShort(savedProgramCounter, stack).terminate()
    }
}

private struct OperationUnaryResult<N: Operand> {
    let result: N
    let state: InstructionState<N>
    
    init(result: N, state: InstructionState<N>) {
        self.result = result
        self.state = state
    }
    
    init(_ params: (result: N, state: InstructionState<N>)) {
        self.result = params.result
        self.state = params.state
    }
    
    func push(_ stack: Stack = .workingStack) -> (Processor, Memory, UpdateProgramCounter) {
        return state.push(result, stack).terminate()
    }

    func pushByte(_ stack: Stack = .workingStack) -> (Processor, Memory, UpdateProgramCounter) {
        let toPush = result.toByteArray().last!
        return state.pushByte(toPush, stack).terminate()
    }

}

private struct OperationBinaryResult<N: Operand> {
    let b: OperationUnaryResult<N>
    
    init(results: (a: N, b: N), state: InstructionState<N>) {
        self.b = OperationUnaryResult(
            result: results.b,
            state: state.push(results.a)
        )
    }
    
    func push() -> OperationUnaryResult<N> {
        b
    }
}

private struct OperationTernaryResult<N: Operand> {
    let b_and_c: OperationBinaryResult<N>
        
    init(results: (a: N, b: N, c: N), state: InstructionState<N>) {
        self.b_and_c = OperationBinaryResult(
            results: (results.b, results.c),
            state: state.push(results.a)
        )
    }
    
    func push() -> OperationBinaryResult<N> {
        b_and_c
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
        twoBytesAsOneShort(byteArray[0], byteArray[1])
    }
    
    static var sizeInBytes: Int {
        2
    }
    
    func toByteArray() -> [UInt8] {
        oneShortAsByteArray(self)
    }
}

typealias UpdateProgramCounter = (UInt16) -> UInt16?

func oneShortAsByteArray(_ value: UInt16) -> [UInt8] {
    let highByte: UInt8 = UInt8((value & 0xFF00) >> 8)
    let lowByte: UInt8 = UInt8(value & 0x00FF)
    return [highByte, lowByte]
}

func oneShortAsTwoBytes(_ value: UInt16) -> (UInt8, UInt8) {
    let highByte: UInt8 = UInt8((value & 0xFF00) >> 8)
    let lowByte: UInt8 = UInt8(value & 0x00FF)
    return (highByte, lowByte)
}

func twoBytesAsOneShort(_ highByte: UInt8, _ lowByte: UInt8) -> UInt16 {
    return UInt16(highByte) << 8 | UInt16(lowByte)
}

private func inc<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    let one: N = .fromByteArray([UInt8](repeating: 0, count: N.sizeInBytes - 1) + [1])
    return instruction.pop().apply11({ a in a &+ one}).push()
}

private func popi<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().noop()
}

private func nip<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21({ a, b in b }).push()
}

private func swp<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply22({ a, b in (b, a)}).push().push()
}

private func add<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21(&+).push()
}

private func sub<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21(&-).push()
}

private func mul<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21(&*).push()
}

private func div<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21({ a, b in b == 0 ? 0 : a / b}).push()
}

private func and<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21(&).push()
}

private func ora<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21(|).push()
}

private func eor<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.pop().pop().apply21(^).push()
}

private func sft<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.popByte().pop().apply21({
        a, b in
        let shiftRight = b & 0x0F
        let shiftLeft = b >> 4
        return (a >> shiftRight) << shiftLeft
    }).push()
}

private func rot<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop().pop().pop()
        .apply33({ a, b, c in (b, c, a) })
        .push().push().push()
}

private func dup<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop().apply12( { a in (a, a) } ).push().push()
}

private func ovr<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop().pop().apply23( { a, b in (a, b, a) } ).push().push().push()
}

private func equ<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    compare(instruction, ==)
}

private func neq<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    compare(instruction, !=)
}

private func gth<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    compare(instruction, >)
}

private func lth<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    compare(instruction, <)
}

private func compare<N: Operand>(_ instruction: Instruction<N>, _ comparison: (N, N) -> Bool) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop().pop().apply21( { a, b in comparison(a, b) ? 1 : 0 } ).pushByte()
}


private func sth<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop().apply11( { a in a } ).push(.returnStack)
}

private func ldz<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .popByte().readFromMemory( { a in UInt16(a) } ).push()
}

private func stz<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .popByte().pop()
        .writeToMemory({ a, b in (UInt16(b), a) })
}

private func ldr<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .popByte().readFromMemoryRelative( { pc, a in pc &+ UInt16(a) &+ 1} ).push()
}

private func str<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .popByte().pop()
        .writeToMemoryRelative({ pc, a, b in (address: pc &+ 1 &+ UInt16(b), value: a) })
}

private func lda<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .popShort().readFromMemory().push()
}

private func sta<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .popShort().pop()
        .writeToMemory({ a, b in (address: b, value: a) })
}

private func deo<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.popByte().pop().writeToDevice({ a, b in (UInt8(b), a)})
}

private func dei<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction.popByte().readFromDevice({ a in UInt8(a) }).push()
}

private func jmp<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop()
        .applyProgramCounter( {
            pc, a in N.sizeInBytes == 1 ? jump(pc: pc, offset: UInt8(a)) : UInt16(a)
        } )
}

private func jcn<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop().popByte()
        .applyProgramCounter( { pc, a, b in
            if a != 0 {
                N.sizeInBytes == 1 ? jump(pc: pc, offset: UInt8(b)) : UInt16(b)
            } else {
                pc &+ 1
            }
        })
}

private func jsr<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .pop()
        .applyProgramCounterSave({ pc, a in (N.sizeInBytes == 1 ? jump(pc: pc, offset: UInt8(a)) : UInt16(a), pc &+ 1) })
        .push(.returnStack)
}

private func jci(_ instruction: Instruction<UInt8>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .readNextShortFromMemory()
        .pop()
        .applyProgramCounter({
            pc, a, b in
            if a == 0 { pc &+ 3 }
            else { jump(pc: pc, offset: b) }
        })
}

private func jmi(_ instruction: Instruction<UInt8>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .readNextShortFromMemory()
        .applyProgramCounter({
            pc, a in
            if a == 0 { pc &+ 2 }
            else { jump(pc: pc, offset: a) }
        })
}

private func jsi(_ instruction: Instruction<UInt16>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .readNextShortFromMemory()
        .applyProgramCounterSave({
            pc, a in
            (jump(pc: pc, offset: a), pc &+ 3)
        })
        .push(.returnStack)
}

private func lit<N: Operand>(_ instruction: Instruction<N>) -> (Processor, Memory, UpdateProgramCounter) {
    return instruction
        .readNextFromMemory()
        .applyProgramCounter1({ pc, a in (pc &+ 1 &+ UInt16(N.sizeInBytes), a) })
        .push()
}

private func jump(pc: UInt16, offset: UInt8) -> UInt16 {
    return jump(
        pc: pc,
        offset: offset < 128 ? UInt16(offset) : UInt16(offset) | 0xFF00)
}

private func jump(pc: UInt16, offset: UInt16) -> UInt16 {
    return pc &+ 1 &+ offset
}
