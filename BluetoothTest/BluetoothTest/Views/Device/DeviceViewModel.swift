//
//  DeviceViewModel.swift
//  BluetoothTest
//
//  Created by Yuriy on 05.10.2023.
//

import CoreBluetooth
import Combine

final class DeviceViewModel: ObservableObject {

    @Published var isReady = false
//    @Published var state: StripeState = .init()

    private enum Constants {
        static let readServiceUUID: CBUUID = .init(string: "FFD0")
        static let writeServiceUUID: CBUUID = .init(string: "FFD5")
        static let serviceUUIDs: [CBUUID] = [readServiceUUID, writeServiceUUID]
        static let readCharacteristicUUID: CBUUID = .init(string: "FFD4")
        static let writeCharacteristicUUID: CBUUID = .init(string: "FFD9")
    }

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    private let peripheral: CBPeripheral
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?

    //MARK: - Lifecycle

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    deinit {
        cancellables.cancel()
    }

    func connect() {
        manager.servicesSubject
            .map { $0.filter { Constants.serviceUUIDs.contains($0.uuid) } }
            .sink { [weak self] services in
                services.forEach { service in
                    self?.peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            .store(in: &cancellables)

        manager.characteristicsSubject
            .filter { $0.0.uuid == Constants.readServiceUUID }
            .compactMap { $0.1.first(where: \.uuid == Constants.readCharacteristicUUID) }
            .sink { [weak self] characteristic in
                self?.readCharacteristic = characteristic
            }
            .store(in: &cancellables)

        manager.characteristicsSubject
            .filter { $0.0.uuid == Constants.writeServiceUUID }
            .compactMap { $0.1.first(where: \.uuid == Constants.writeCharacteristicUUID) }
            .sink { [weak self] characteristic in
                self?.writeCharacteristic = characteristic
            }
            .store(in: &cancellables)

        manager.connect(peripheral)
    }

    private func write(_ data: Data) {
        guard let characteristic = writeCharacteristic else {
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value?) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}
