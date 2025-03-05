import Testing
import Nimble
@testable import IoXn

/**
 Instruction set uxn https://wiki.xxiivv.com/site/uxntal_reference.html
 Varvara specification https://wiki.xxiivv.com/site/varvara.html
 Implementation guide https://github.com/DeltaF1/uxn-impl-guide
 */

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

