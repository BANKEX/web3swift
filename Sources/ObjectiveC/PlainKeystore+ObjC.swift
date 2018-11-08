//
//  PlainKeystore+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(PlainKeystore)
public final class _ObjCPlainKeystore: NSObject {
    private(set) var keystore: PlainKeystore?

    init(privateKey: String) {
        keystore = try? PlainKeystore(privateKey: privateKey)
    }

    init(privateKey: Data) {
        keystore = try? PlainKeystore(privateKey: privateKey)
    }

    init(privateKey: NSData) {
        keystore = try? PlainKeystore(privateKey: privateKey as Data)
    }

    init(keystore: PlainKeystore) {
        self.keystore = keystore
    }
}
