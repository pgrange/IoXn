struct Devices {
    let devices: [DeviceIndex: Device]
    
    private init(_ devices: [DeviceIndex: Device]) {
        self.devices = devices
    }
    
    init() {
        var devices : [DeviceIndex: Device] = [:]
        for index in DeviceIndex.allCases {
            devices[index] = Device()
        }
        self.devices = devices
    }
    
    func register(index: DeviceIndex, device: Device) -> Devices {
        var devices = self.devices
        devices[index] = device
        return Devices(devices)
    }
    
    func writeToDevice<N: Operand>(address: UInt8, value: N) {
        let device = DeviceIndex(rawValue: address & 0xf0)!
        let port   = address & 0x0f
        devices[device]!.write(value, at: port)
    }
    
    func readFromDevice<N: Operand>(address: UInt8, as: N.Type) -> N {
        let device = DeviceIndex(rawValue: address & 0xf0)!
        let port   = address & 0x0f
        return devices[device]!.read(at: port, as: N.self)
    }
}

enum DeviceIndex: UInt8, CaseIterable {
    case system     = 0x00
    case console    = 0x10
    case screen     = 0x20
    case audio0     = 0x30
    case audio1     = 0x40
    case audio2     = 0x50
    case audio3     = 0x60
    case seven      = 0x70
    case controller = 0x80
    case mouse      = 0x90
    case file0      = 0xa0
    case file1      = 0xb0
    case datetime   = 0xc0
    case reserved0  = 0xd0
    case reserved1  = 0xe0
    case fifteen    = 0xf0
}

class Device {
    func write<N: Operand>(_ value: N, at: UInt8) {
    }
    
    func read<N: Operand>(at: UInt8, as type: N.Type) -> N {
        return N(0)
    }
}

class Console<Out: TextOutputStream> : Device{
    var out: Out
    
    init(out: Out) {
        self.out = out
    }
    
    override func write<N>(_ value: N, at: UInt8) where N : Operand {
        if at == 0x08 {
            let asciiString = String(decoding: value.toByteArray(), as: UTF8.self)
            print(asciiString, terminator: "", to: &out)
        }
    }
}
