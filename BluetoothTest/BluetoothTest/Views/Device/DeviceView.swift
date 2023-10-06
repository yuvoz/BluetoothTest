//
//  DeviceView.swift
//  BluetoothTest
//
//  Created by Yuriy on 05.10.2023.
//

import SwiftUI
import CoreBluetooth

struct DeviceView: View {
    
    @StateObject private var viewModel: DeviceViewModel
    @State private var modeSelectionIsPresented = false
    @State private var didAppear = false

    //MARK: - Lifecycle
    
    init(peripheral: CBPeripheral) {
        let viewModel = DeviceViewModel(peripheral: peripheral)
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        content()
            .onAppear {
                guard didAppear == false else {
                    return
                }
                didAppear = true
                viewModel.connect()
            }
    }

    //MARK: - Private
    
    @ViewBuilder
    private func content() -> some View {
        if viewModel.isReady {
            List {

            }
        }
        else {
            Text("Connecting...")
        }
    }
}
