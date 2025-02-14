//
//  IoXnTests.swift
//  IoXnTests
//
//  Created by pascal on 14/02/2025.
//

import Testing
import Nimble
@testable import IoXn

struct IoXnTests {

    @Test func example() async throws {
        let (workingStack, _) = step(
            workingStack: [1, 2],
            returnStack: [],
            opcode: "ADD"
        )
        expect(workingStack[0]).to(equal(3))
    }
}

func step(
    workingStack: [UInt8],
    returnStack: [UInt8],
    opcode: String
) -> ([UInt8], [UInt8]) {
    
    let result = workingStack.suffix(2).reduce(0, +)
    return (workingStack.dropLast(2) + [UInt8(result)], returnStack)
}
