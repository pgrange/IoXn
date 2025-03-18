import Foundation

struct IoXn {
    var processor: Processor
    var memory: Memory
    let devices: Devices
    
    init(_ devices: Devices, rom: Data) {
        self.processor = Processor()
        self.memory = Memory(initializedWith: rom)
        self.devices = devices
    }
    
    mutating func start() {
        (processor, memory) = run(processor, from: 0x100, withMemory: memory, withDevices: devices)
    }
    
    mutating func startDebug() {
        (processor, memory) = runDebug(processor, from: 0x100, withMemory: memory, withDevices: devices)
    }
}
