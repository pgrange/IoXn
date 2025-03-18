import Testing
import Nimble
@testable import IoXn

/**
 Instruction set uxn https://wiki.xxiivv.com/site/uxntal_reference.html
 Varvara specification https://wiki.xxiivv.com/site/varvara.html
 Implementation guide https://github.com/DeltaF1/uxn-impl-guide
 */

extension Processor {
    func stepNoMemory(_ rawOpcode: UInt8, programCounter: UInt16 = 0x100)
    -> (processor: Processor, memory: Memory, updateProgramCounter: UpdateProgramCounter) {
        step(rawOpcode, withMemory: Memory(), programCounter: programCounter)
    }
}

struct Op {
    static let brk: UInt8    = 0x00
    
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
    static let pop2k: UInt8  = 0xa2
    static let pop2kr: UInt8 = 0xe2

    static let nip: UInt8   = 0x03
    static let nip2: UInt8  = 0x23
    static let nip2k: UInt8 = 0xa3
    
    static let swp: UInt8   = 0x04
    static let swp2: UInt8  = 0x24
    static let swpk: UInt8  = 0x84
    static let swp2k: UInt8 = 0xa4
    
    static let rot: UInt8   = 0x05
    static let rot2: UInt8  = 0x25
    static let rotk: UInt8  = 0x85
    static let rot2k: UInt8 = 0xa5
    
    static let dup: UInt8  = 0x06
    static let dup2: UInt8 = 0x26
    static let dupk: UInt8 = 0x86
    
    static let ovr: UInt8   = 0x07
    static let ovr2: UInt8  = 0x27
    static let ovrk: UInt8  = 0x87
    static let ovr2k: UInt8 = 0xa7
    
    static let equ: UInt8 = 0x08
    static let equ2: UInt8 = 0x28
    static let equk: UInt8 = 0x88
    static let equ2k: UInt8 = 0xa8
    static let neq: UInt8 = 0x09
    static let neq2: UInt8 = 0x29
    static let neqk: UInt8 = 0x89
    static let neq2k: UInt8 = 0xa9
    static let gth: UInt8 = 0x0a
    static let gth2: UInt8 = 0x2a
    static let gth2k: UInt8 = 0xaa
    static let lth: UInt8 = 0x0b
    static let lth2: UInt8 = 0x2b
    static let lthk: UInt8 = 0x8b
    static let lth2k: UInt8 = 0xab
    
    static let add: UInt8 = 0x18
    static let add2: UInt8 = 0x38
    static let addk: UInt8 = 0x98
    static let sub: UInt8 = 0x19
    static let mul: UInt8 = 0x1a
    static let div: UInt8 = 0x1b
    static let div2: UInt8 = 0x3b
    static let divk: UInt8 = 0x9b

    static let and: UInt8 = 0x1c
    static let ora: UInt8 = 0x1d
    static let eor: UInt8 = 0x1e
    static let sft: UInt8 = 0x1f
    static let sftk: UInt8 = 0x9f
    static let sftk2: UInt8 = 0xbf

    static let sth: UInt8 = 0x0f
    static let sthr: UInt8 = 0x4f

    static let ldz: UInt8  = 0x10
    static let stz: UInt8  = 0x11
    static let ldr: UInt8  = 0x12
    static let str: UInt8  = 0x13
    static let lda: UInt8  = 0x14
    static let sta: UInt8  = 0x15
    static let dei: UInt8  = 0x16
    static let deo: UInt8  = 0x17

    static let jci: UInt8  = 0x20
    static let jmi: UInt8  = 0x40
    static let jsi: UInt8  = 0x60
    static let lit: UInt8  = 0x80
    static let lit2: UInt8 = 0xa0

    static let ldz2: UInt8 = 0x30
    static let stz2: UInt8 = 0x31
    static let ldr2: UInt8 = 0x32
    static let str2: UInt8 = 0x33
    
    static let dei2: UInt8  = 0x36
    static let deo2: UInt8 = 0x37
    
    static let jmp: UInt8 = 0x0c
    static let jcn: UInt8 = 0x0d
    static let jsr: UInt8 = 0x0e
    static let jmp2: UInt8 = 0x2c
    static let jcn2: UInt8 = 0x2d
    static let jsr2: UInt8 = 0x2e
    static let jmp2r: UInt8 = 0x6c
}

