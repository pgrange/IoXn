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
            .step(Op.inc)
        ).to(equal(Processor().with(
            workingStack: [7]
        )))
        
        expect(Processor()
            .push(6)
            .step(Op.inck)
        ).to(equal(Processor().with(
            workingStack: [6, 7]
        )))
        
        expect(Processor()
            .push(6)
            .push(255)
            .step(Op.inc2)
        ).to(equal(Processor().with(
            workingStack: oneShortAsByteArray(1792)
        )))
        
        expect(Processor()
            .push(6)
            .push(255)
            .step(Op.inc2k)
        ).to(equal(Processor().with(
            workingStack: [6, 255] + oneShortAsByteArray(1792)
        )))
    }
    
    @Test func opcodeAdd() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.add)
        ).to(equal(Processor().with(
            workingStack: [3]
        )))
        
        expect(Processor()
            .push(255)
            .push(1)
            .step(Op.add)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeSub() async throws {
        expect(Processor()
            .push(2)
            .push(1)
            .step(Op.sub)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.sub)
        ).to(equal(Processor().with(
            workingStack: [255]
        )))
    }
    
    @Test func opcodeMul() async throws {
        expect(Processor()
            .push(2)
            .push(2)
            .step(Op.mul)
        ).to(equal(Processor().with(
            workingStack: [4]
        )))
        
        expect(Processor()
            .push(130)
            .push(2)
            .step(Op.mul)
        ).to(equal(Processor().with(
            workingStack: [4]
        )))
    }
    
    @Test func opcodeDiv() async throws {
        expect(Processor()
            .push(6)
            .push(2)
            .step(Op.div)
        ).to(equal(Processor().with(
            workingStack: [3]
        )))
        
        expect(Processor()
            .push(255)
            .push(2)
            .step(Op.div)
        ).to(equal(Processor().with(
            workingStack: [127]
        )))
        
        expect(Processor()
            .push(12)
            .push(0)
            .step(Op.div)
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
            .step(Op.pop)
        ).to(equal(Processor().with(
            workingStack: [1, 2]
        )))

        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .step(Op.popk)
        ).to(equal(Processor().with(
            workingStack: [1, 2, 3]
        )))
        
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .step(Op.pop2)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        
        expect(Processor()
            .push(1, .returnStack)
            .push(2, .returnStack)
            .push(3, .returnStack)
            .step(Op.pop2kr)
        ).to(equal(Processor().with(
            returnStack: [1, 2, 3]
        )))

    }
    
    @Test func opcodeNip() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .step(Op.nip)
        ).to(equal(Processor().with(
            workingStack: [1, 3]
        )))
    }
    
    @Test func opcodeSwp() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .push(3)
            .step(Op.swp)
        ).to(equal(Processor().with(
            workingStack: [1, 3, 2]
        )))
    }
    
    @Test func opcodeRot() async throws {
        let result = Processor()
            .push(1)
            .push(2)
            .push(3)
            .step(Op.rot)
        
        expect(result).to(equal(Processor().with(
            workingStack: [2, 3, 1]
        )))
    }
    
    @Test func opcodeDup() async throws {
        let result = Processor()
            .push(1)
            .push(2)
            .step(Op.dup)
        
        expect(result).to(equal(Processor().with(
            workingStack: [1, 2, 2]
        )))
    }
    
    @Test func opcodeOvr() async throws {
        let processor = Processor()
            .push(1)
            .push(2)
            .step(Op.ovr)
        
        expect(processor).to(equal(Processor().with(
            workingStack: [1, 2, 1]
        )))
    }
    
    @Test func opcodeSth() async throws {
        expect(Processor()
            .push(2)
            .step(Op.sth)
        ).to(equal(Processor().with(
            returnStack: [2]
        )))
        
        expect(Processor()
            .push(2, .returnStack)
            .step(Op.sthr)
        ).to(equal(Processor().with(
            workingStack: [2]
        )))
    }
}

struct IoXnLogicTests {
    @Test func opcodeEqu() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.equ)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.equ)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
    }
    @Test func opcodeNeq() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.neq)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.neq)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    @Test func opcodeGth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .step(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.gth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }
    
    @Test func opcodeLth() async throws {
        expect(Processor()
            .push(1)
            .push(2)
            .step(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [1]
        )))
        expect(Processor()
            .push(2)
            .push(1)
            .step(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
        expect(Processor()
            .push(1)
            .push(1)
            .step(Op.lth)
        ).to(equal(Processor().with(
            workingStack: [0]
        )))
    }

    @Test func opcodeAnd() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xF2)
            .step(Op.and)
        ).to(equal(Processor().with(
            workingStack: [0x02]
        )))
    }
    
    @Test func opcodeOra() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .step(Op.ora)
        ).to(equal(Processor().with(
            workingStack: [0xDF]
        )))
    }

    @Test func opcodeEor() async throws {
        expect(Processor()
            .push(0x0F)
            .push(0xD2)
            .step(Op.eor)
        ).to(equal(Processor().with(
            workingStack: [0xDD]
        )))
    }
    
    @Test func opcodeSft() async throws {
        expect(Processor()
            .push(0x34)
            .push(0x10)
            .step(Op.sft)
        ).to(equal(Processor().with(
            workingStack: [0x68]
        )))
    }
    
    // TODO https://wiki.xxiivv.com/site/uxntal_reference.html#sft
}

struct IoXnMemoryTests {
    @Test func opcodeLdz() async throws {
        let initialMemory = Memory()
            .write(2, 250)
            .write(3, 12)
        
        expect(Processor().with(memory: initialMemory)
            .push(2)
            .step(Op.ldz)
        ).to(equal(Processor().with(
            workingStack: [250],
            memory: initialMemory
        )))

        expect(Processor().with(memory: initialMemory)
            .push(0).push(2)
            .step(Op.ldz2)
        ).to(equal(Processor().with(
            workingStack: [250, 12],
            memory: initialMemory
        )))

    }
    
    @Test func opcodeStz() async throws {
        expect(Processor()
            .push(2)
            .push(250)
            .step(Op.stz)
        ).to(equal(Processor().with(
            memory: Memory().write(250, 2)
        )))
        
        expect(Processor()
            .push(2)
            .push(3)
            .push(250)
            .step(Op.stz2)
        ).to(equal(Processor().with(
            memory: Memory()
                .write(250, 2)
                .write(251, 3)
        )))

    }
    
    @Test func opcodeLdr() async throws {
        let initialMemory = Memory()
            .write(350, 250)
            .write(351, 12)
        
        expect(Processor().with(programCounter: 340, memory: initialMemory)
            .push(10)
            .step(Op.ldr)
        ).to(equal(Processor().with(
            programCounter: 340,
            workingStack: [250],
            memory: initialMemory
        )))

        expect(Processor().with(programCounter: 340, memory: initialMemory)
            .push(10)
            .step(Op.ldr2)
        ).to(equal(Processor().with(
            programCounter: 340,
            workingStack: [250, 12],
            memory: initialMemory
        )))
    }
    
    @Test func opcodeStr() async throws {
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(10)
            .step(Op.str)
        ).to(equal(Processor().with(
            programCounter: 340,
            memory: Memory().write(350, 2)
        )))
        
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(3)
            .push(10)
            .step(Op.str2)
        ).to(equal(Processor().with(
            programCounter: 340,
            memory: Memory()
                .write(350, 2)
                .write(351, 3)
        )))

    }
    
    @Test func opcodeLda() async throws {
        let initialMemory = Memory()
            .write(350, 250)
        
        expect(Processor().with(memory: initialMemory)
            .push(0x01)
            .push(0x5e)
            .step(Op.lda)
        ).to(equal(Processor().with(
            workingStack: [250],
            memory: initialMemory
        )))
    }
    
    @Test func opcodeSta() async throws {
        expect(Processor()
            .push(2)
            .push(0x01)
            .push(0x5e)
            .step(Op.sta)
        ).to(equal(Processor().with(
            memory: Memory().write(350, 2)
        )))
        
        expect(Processor().with(programCounter: 340)
            .push(2)
            .push(3)
            .push(10)
            .step(Op.str2)
        ).to(equal(Processor().with(
            programCounter: 340,
            memory: Memory()
                .write(350, 2)
                .write(351, 3)
        )))
    }
    
    @Test func opcodeLit() async throws {
        let memory = Memory()
            .write(12044, 12)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .step(Op.lit)
        ).to(equal(Processor().with(
            programCounter: 12045,
            workingStack: [12],
            memory: memory
        )))
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .step(Op.lit2)
        ).to(equal(Processor().with(
            programCounter: 12046,
            workingStack: [12, 125],
            memory: memory
        )))
    }
}

struct IoXnProgramCounterTests {
    @Test func opcodeJmp() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(2)
            .step(Op.jmp)
        ).to(equal(Processor().with(
            programCounter: 12045
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(0 &- 2)
            .step(Op.jmp)
        ).to(equal(Processor().with(
            programCounter: 12041
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(oneShortAsByteArray(12050))
            .step(Op.jmp2)
        ).to(equal(Processor().with(
            programCounter: 12050
        )))
    }
    @Test func opcodeJcn() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(2)
            .step(Op.jcn)
        ).to(equal(Processor().with(
            programCounter: 12045
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(0 &- 2)
            .step(Op.jcn)
        ).to(equal(Processor().with(
            programCounter: 12041
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(0)
            .push(2)
            .step(Op.jcn).programCounter
        ).to(equal(12043))

        expect(Processor().with(programCounter: 12043)
            .push(5)
            .push(oneShortAsByteArray(12050))
            .step(Op.jcn2)
        ).to(equal(Processor().with(
            programCounter: 12050
        )))
    }
    
    @Test func opcodeJsr() async throws {
        expect(Processor().with(programCounter: 12043)
            .push(5)
            .step(Op.jsr)
        ).to(equal(Processor().with(
            programCounter: 12048,
            returnStack: oneShortAsByteArray(12043)
        )))
        
        expect(Processor().with(programCounter: 12043)
            .push(oneShortAsByteArray(12055))
            .step(Op.jsr2)
        ).to(equal(Processor().with(
            programCounter: 12055,
            returnStack: oneShortAsByteArray(12043)
        )))
    }
    
    @Test func opcodeJci() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .push(0)
            .step(Op.jci)
        ).to(equal(Processor().with(
            programCounter: 12045,
            memory: memory
        )))
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .push(1)
            .step(Op.jci)
        ).to(equal(Processor().with(
            programCounter: 12168,
            memory: memory
        )))
    }
    
    @Test func opcodeJmi() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .step(Op.jmi)
        ).to(equal(Processor().with(
            programCounter: 12168,
            memory: memory
        )))
    }
    
    @Test func opcodeJsi() async throws {
        let memory = Memory()
            .write(12044, 0)
            .write(12045, 125)
        
        expect(Processor().with(programCounter: 12043, memory: memory)
            .step(Op.jsi)
        ).to(equal(Processor().with(
            programCounter: 12168,
            returnStack: [0x2F, 0x0D], //12045
            memory: memory
        )))
    }
}

struct Op {
    static let inc: UInt8    = 0x01
    static let inc2: UInt8   = 0x21
    static let incr: UInt8   = 0x41
    static let inc2r: UInt8  = 0x61
    static let inck: UInt8   = 0x81
    static let inc2k: UInt8  = 0xa1
    static let inckr: UInt8  = 0xc1
    static let inc2kr: UInt8 = 0xe1

    static let pop: UInt8    = 0x02
    static let pop2: UInt8   = 0x22
    static let popk: UInt8   = 0x82
    static let pop2kr: UInt8 = 0xe2

    static let nip: UInt8 = 0x03
    static let swp: UInt8 = 0x04
    static let rot: UInt8 = 0x05
    static let dup: UInt8 = 0x06
    static let ovr: UInt8 = 0x07
    static let equ: UInt8 = 0x08
    static let neq: UInt8 = 0x09
    static let gth: UInt8 = 0x0a
    static let lth: UInt8 = 0x0b

    static let add: UInt8 = 0x18
    static let sub: UInt8 = 0x19
    static let mul: UInt8 = 0x1a
    static let div: UInt8 = 0x1b

    static let and: UInt8 = 0x1c
    static let ora: UInt8 = 0x1d
    static let eor: UInt8 = 0x1e
    static let sft: UInt8 = 0x1f

    static let sth: UInt8 = 0x0f
    static let sthr: UInt8 = 0x4f

    static let ldz: UInt8  = 0x10
    static let stz: UInt8  = 0x11
    static let ldr: UInt8  = 0x12
    static let str: UInt8  = 0x13
    static let lda: UInt8  = 0x14
    static let sta: UInt8  = 0x15

    static let jci: UInt8  = 0x20
    static let jmi: UInt8  = 0x40
    static let jsi: UInt8  = 0x60
    static let lit: UInt8  = 0x80
    static let lit2: UInt8 = 0xa0

    static let ldz2: UInt8 = 0x30
    static let stz2: UInt8 = 0x31
    static let ldr2: UInt8 = 0x32
    static let str2: UInt8 = 0x33

    static let jmp: UInt8 = 0x0c
    static let jcn: UInt8 = 0x0d
    static let jsr: UInt8 = 0x0e
    static let jmp2: UInt8 = 0x2c
    static let jcn2: UInt8 = 0x2d
    static let jsr2: UInt8 = 0x2e
}

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

enum Opcode: UInt8 {
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
    
    // TODO
    // https://wiki.xxiivv.com/site/uxntal_reference.html#dei
    // https://wiki.xxiivv.com/site/uxntal_reference.html#deo
    
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
            return N(twoBytesAsOneShort(high, low))
        }
    }
    
    func write<N: Operand>(_ address: UInt16, _ value: N) -> Memory {
        var data = self.data
        if (N.sizeInBytes == 1) {
            data[address] = UInt8(value)
        } else {
            let (high, low) = oneShortAsTwoBytes(UInt16(value))
            data[address] = high
            data[address &+ 1] = low
        }
        return Memory(data: data)
    }
    
    func write(_ address: UInt16, _ value: Int) -> Memory {
        //sugar method for when calling with literal
        return self.write(address, UInt8(value))
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
    
    private func inc<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        let inc: N = .fromByteArray([UInt8](repeating: 0, count: N.sizeInBytes - 1) + [1])
        return instruction.pop().apply11({ a in a &+ inc}).push()
    }
    
    private func pop<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().noop().drop()
    }
    
    private func nip<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().noop().drop().push()
    }

    private func swp<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply22({ a, b in (b, a)}).push().push()
    }

    private func add<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21(&+).push()
    }
    
    private func sub<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21(&-).push()
    }

    private func mul<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21(&*).push()
    }

    private func div<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21({ a, b in b == 0 ? 0 : a / b}).push()
    }
    
    private func and<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21(&).push()
    }

    private func ora<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21(|).push()
    }

    private func eor<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21(^).push()
    }

    private func sft<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction.pop().pop().apply21({
            a, b in
            let shiftRight = b & 0x0F
            let shiftLeft = b >> 4
            return (a >> shiftRight) << shiftLeft
        }).push()
    }

    private func rot<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().pop().pop()
            .apply33({ a, b, c in (b, c, a) })
            .push().push().push()
    }
    
    private func dup<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().apply12( { a in (a, a) } ).push().push()
    }

    private func ovr<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().pop().apply23( { a, b in (a, b, a) } ).push().push().push()
    }

    private func equ<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().pop().apply21( { a, b in a == b ? 1 : 0 } ).push()
    }
    
    private func neq<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().pop().apply21( { a, b in a == b ? 0 : 1 } ).push()
    }
    
    private func gth<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().pop().apply21( { a, b in a > b ? 1 : 0 } ).push()
    }
    
    private func lth<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().pop().apply21( { a, b in a < b ? 1 : 0 } ).push()
    }
    
    private func sth<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().apply11( { a in a } ).push(.returnStack)
    }

    private func ldz<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().readFromMemory( { a in UInt16(a) } ).push()
    }

    private func stz<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .popByte().pop()
            .writeToMemory({ a, b in (UInt16(b), a) })
    }
    
    private func ldr<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .popByte().readFromMemory( { a in programCounter &+ UInt16(a) } ).push()
    }

    private func str<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .popByte().pop()
            .writeToMemory({ a, b in (programCounter + UInt16(b), a) })
    }
    
    private func lda<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .popShort().readFromMemory({ a in a }).push()
    }
    
    private func sta<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .popShort().pop()
            .writeToMemory({ a, b in (b, a) })
    }
    
    private func jmp<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop()
            .applyProgramCounter( {
                pc, a in N.sizeInBytes == 1 ? jump(pc: pc, offset: UInt8(a)) : UInt16(a)
            } )
    }
    
    private func jcn<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop().popByte()
            .applyProgramCounter( { pc, a, b in
                if a != 0 {
                    N.sizeInBytes == 1 ? jump(pc: pc, offset: UInt8(b)) : UInt16(b)
                } else {
                    pc
                }
            })
    }
    
    private func jsr<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        return instruction
            .pop()
            .applyProgramCounterSave({ pc, a in N.sizeInBytes == 1 ? jump(pc: pc, offset: UInt8(a)) : UInt16(a) })
            .push(.returnStack)
    }
    
    private func jci(_ instruction: Instruction<UInt8>) -> Processor {
        //TODO do not access programCounter directly from here
        return instruction
            .readShortFromMemory(programCounter + 1)
            .pop()
            .applyProgramCounter({
                pc, a, b in
                if a == 0 { pc &+ 2 }
                else { jump(pc: pc, offset: b) }
            })
    }
    
    private func jmi(_ instruction: Instruction<UInt8>) -> Processor {
        //TODO do not access programCounter directly from here
        return instruction
            .readShortFromMemory(programCounter + 1)
            .applyProgramCounter({
                pc, a in
                if a == 0 { pc &+ 2 }
                else { jump(pc: pc, offset: a) }
            })
    }
    
    private func jsi(_ instruction: Instruction<UInt16>) -> Processor {
        //TODO do not access programCounter directly from here
        return instruction
            .readShortFromMemory(programCounter + 1)
            .applyProgramCounter1({
                pc, a in
                (jump(pc: pc, offset: a), pc &+ 2)
            })
            .push(.returnStack)
    }
    
    private func lit<N: Operand>(_ instruction: Instruction<N>) -> Processor {
        //TODO do not access programCounter directly from here
        return instruction
            .readFromMemory(programCounter + 1)
            .applyProgramCounter1({ pc, a in (pc &+ 1 &+ UInt16(N.sizeInBytes), a) })
            .push()
    }
    
    private func jump(pc: UInt16, offset: UInt8) -> UInt16 {
        return jump(
            pc: pc,
            offset: offset < 128 ? UInt16(offset) : UInt16(offset) | 0xFF00)
    }
    
    private func jump(pc: UInt16, offset: UInt16) -> UInt16 {
        return pc &+ offset
    }
    
    func step<N: Operand>(for: N.Type, reverseStack: Bool, keepStack: Bool, opcode: Opcode) -> Processor {
        let instruction = Instruction<N>(self, reverseStack: reverseStack, keepStack: keepStack)
        switch opcode {
        case .inc:
            return inc(instruction)
            
        case .pop:
            return pop(instruction)
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
    
    func step(_ rawOpcode: UInt8) -> Processor {
        let keep = rawOpcode    & 0x80 == 0x00 ? false : true
        let reverse = rawOpcode & 0x40 == 0x00 ? false : true
        let size : any Operand.Type = rawOpcode & 0x20 == 0x00 ? UInt8.self : UInt16.self
        
        switch rawOpcode {
        case Opcode.jci.rawValue:
            return jci(Instruction<UInt8>(self))
        case Opcode.jmi.rawValue:
            return jmi(Instruction<UInt8>(self))
        case Opcode.jsi.rawValue:
            return jsi(Instruction<UInt16>(self))
        case Opcode.lit.rawValue, Opcode.lit.rawValue | 0x20:
            return step(
                for: size,
                reverseStack: reverse,
                keepStack: keep,
                opcode: Opcode(rawValue: rawOpcode & 0x9F)!
            )
        default:
            return step(
                for: size,
                reverseStack: reverse,
                keepStack: keep,
                opcode: Opcode(rawValue: rawOpcode & 0x1F)!
            )
        }
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
    
    func popShort(_ stack: Stack = .workingStack) -> (UInt16, InstructionState) {
        let (head, nextProcessor) = processor.pop(2, realStack(stack))
        let value: UInt16 = .fromByteArray(head)
        return (value, with(processor: nextProcessor, popped: popped + head))
    }
    
    func push(_ value: N, _ stack: Stack = .workingStack) -> InstructionState<N> {
        let nextProcessor = keepStack ? processor.push(popped.reversed(), realStack(stack)) : processor
        return with(
            processor: nextProcessor.push(value.toByteArray(), realStack(stack)),
            popped: []
        )
    }

    func pushShort(_ value: UInt16, _ stack: Stack = .workingStack) -> InstructionState<N> {
        let nextProcessor = keepStack ? processor.push(popped.reversed(), realStack(stack)) : processor
        return with(
            processor: nextProcessor.push(value.toByteArray(), realStack(stack)),
            popped: []
        )
    }
    
    func writeToMemory(_ address: UInt16, _ value: N) -> InstructionState<N> {
        return with(processor: processor.with(memory: processor.memory.write(address, value)))
    }
    
    func readFromMemory(_ address: UInt16) -> N {
        return processor.memory.read(address, as: N.self)
    }
    
    func readShortFromMemory(_ address: UInt16) -> UInt16 {
        return processor.memory.read(address, as: UInt16.self)
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
    
    func popShort() -> UnaryShortOperationInProgress<N> {
        let (a, nextState) = state.popShort()
        return UnaryShortOperationInProgress(
            a: a,
            state: nextState
        )
    }
    
    func readShortFromMemory(_ address: UInt16) -> UnaryShortOperationInProgress<N> {
        let value = state.readShortFromMemory(address)
        return UnaryShortOperationInProgress(
            a: value,
            state: state
        )
    }
    
    func readFromMemory(_ address: UInt16) -> UnaryOperationInProgress<N> {
        let value = state.readFromMemory(address)
        return UnaryOperationInProgress(
            a: value,
            state: state
        )
    }
}

struct UnaryByteOperationInProgress<N: Operand> {
    let a: UInt8
    let state: InstructionState<N>
    
    func pop(_ stack: Stack = .workingStack) -> BinaryByteOperationInProgress<N> {
        let (b, nextState) = state.pop(stack)
        return BinaryByteOperationInProgress(
            a: b,
            b: a,
            state: nextState
        )
    }
    
    func applyProgramCounter(_ operation: (UInt16, UInt8) -> UInt16) -> Processor {
        state.jump(to: operation(state.programCounter, a)).terminate()
    }
}

struct UnaryShortOperationInProgress<N: Operand> {
    let a: UInt16
    let state: InstructionState<N>
    
    func readFromMemory(_ operation: (UInt16) -> UInt16) -> OperationUnaryResult<N> {
        let value = state.readFromMemory(operation(a))
        return OperationUnaryResult<N>(
            result: value,
            state: state
        )
    }
    
    func pop(_ stack: Stack = .workingStack) -> BinaryShortOperationInProgress<N> {
        let (b, nextState) = state.pop(stack)
        return BinaryShortOperationInProgress(
            a: b,
            b: a,
            state: nextState
        )
    }
    
    func applyProgramCounter(_ operation: (UInt16, UInt16) -> (UInt16)) -> Processor {
        state.jump(to: operation(state.programCounter, a)).terminate()
    }
    
    func applyProgramCounter1(_ operation: (UInt16, UInt16) -> (UInt16, N)) -> OperationUnaryResult<N> {
        let (pc, result) = operation(state.programCounter, a)
        return OperationUnaryResult<N>(
            result: result,
            state: state.jump(to: pc)
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
    
    func popByte() -> BinaryOperationInProgress<N> {
        let (b, nextState) = state.popByte()
        return BinaryOperationInProgress(
            a: N(b),
            b: a,
            state: nextState
        )
    }
    
    func noop() -> OperationUnaryResult<N> {
        return OperationUnaryResult<N>(
            result: a,
            state: state
        )
    }
    
    func applyProgramCounter(_ operation: (UInt16, N) -> UInt16) -> Processor {
        state.jump(to: operation(state.programCounter, a)).terminate()
    }
    
    func applyProgramCounter1(_ operation: (UInt16, N) -> (UInt16, N)) -> OperationUnaryResult<N> {
        let (pc, result) = operation(state.programCounter, a)
        return OperationUnaryResult<N>(
            result: result,
            state: state.jump(to: pc)
        )
    }

    func applyProgramCounterSave(_ operation: (UInt16, N) -> UInt16) -> OperationProgramCounterResult<N> {
        let pc = operation(state.programCounter, a)
        return OperationProgramCounterResult<N>(
            savedProgramCounter: state.programCounter,
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
    
    func readFromMemory(_ operation: (N) -> UInt16) -> OperationUnaryResult<N> {
        let value = state.readFromMemory(operation(a))
        return OperationUnaryResult<N>(
            result: value,
            state: state
        )
    }
}

struct BinaryShortOperationInProgress<N: Operand> {
    let a: N
    let b: UInt16
    let state: InstructionState<N>
    
    func writeToMemory(_ operation: (N, UInt16) -> (UInt16, N)) -> Processor {
        let (address, value) = operation(a, b)
        return state.writeToMemory(address, value).terminate()
    }
    
    func applyProgramCounter(_ operation: (UInt16, N, UInt16) -> UInt16) -> Processor {
        state.jump(to: operation(state.programCounter, a, b)).terminate()
    }
}

struct BinaryByteOperationInProgress<N: Operand> {
    let a: N
    let b: UInt8
    let state: InstructionState<N>
    
    func applyProgramCounter(_ operation: (UInt16, N, UInt8) -> UInt16) -> Processor {
        state.jump(to: operation(state.programCounter, a, b)).terminate()
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
    }
    
    func applyProgramCounter(_ operation: (UInt16, N, N) -> UInt16) -> Processor {
        return state.jump(to: operation(state.programCounter, a, b)).terminate()
    }
    
    func noop() -> OperationBinaryResult<N> {
        return OperationBinaryResult(resultA: a, resultB: b, state: state)
    }

    func apply21(_ operation: (N, N) -> N) -> OperationUnaryResult<N> {
        return OperationUnaryResult(
            result: operation(a, b),
            state: state
        )
    }
    
    func apply22(_ operation: (N, N) -> (N, N)) -> OperationBinaryResult<N> {
        let (resultA, resultB) = operation(a, b)
        return OperationBinaryResult(
            resultA: resultA,
            resultB: resultB,
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
    
    func drop() -> Processor {
        return state.terminate()
    }
}

struct OperationProgramCounterResult<N: Operand> {
    let savedProgramCounter: UInt16
    let state: InstructionState<N>
    
    func push(_ stack: Stack = .workingStack) -> Processor {
        return state.pushShort(savedProgramCounter, stack).terminate()
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
    
    func drop() -> OperationUnaryResult<N> {
        return OperationUnaryResult(
            result: resultB,
            state: state
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
        twoBytesAsOneShort(byteArray[0], byteArray[1])
    }
    
    static var sizeInBytes: Int {
        2
    }
    
    func toByteArray() -> [UInt8] {
        oneShortAsByteArray(self)
    }
}
