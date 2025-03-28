import Foundation
struct Memory : Equatable {
    let data: [UInt16: UInt8]
    
    private init(data: [UInt16 : UInt8]) {
        self.data = data
    }
    
    init(initializedWith rom: Data = Data()) {
        var data = [UInt16: UInt8]()
        
        for (index, byte) in rom.enumerated() {
            data[UInt16(index + 0x100)] = byte
        }
        
        self.data = data
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
    
    func write(_ address: UInt16, _ values: Data) -> Memory {
        var data = self.data
        
        for (index, byte) in values.enumerated() {
            data[UInt16(index) + address] = byte
        }
        
        return Memory(data: data)
    }
    
    static func == (lhs: Memory, rhs: Memory) -> Bool {
        lhs.data == rhs.data
    }
}
