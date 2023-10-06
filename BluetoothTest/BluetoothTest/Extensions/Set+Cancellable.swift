//
//  Set+Cancellable.swift
//  BluetoothTest
//
//  Created by Yuriy on 05.10.2023.
//

import Combine

extension Set where Element: Cancellable {

    func cancel() {
        forEach { $0.cancel() }
    }
}
