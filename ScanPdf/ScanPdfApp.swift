//
//  ScanPdfApp.swift
//  ScanPdf
//
//  Created by zhu youfeng on 2021/8/28.
//

import SwiftUI

@main
struct ScanPdfApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(scannedCode: "http://einvoice.jsczt.cn/d/473011a4267d027dc72")
//            QRCodeScannerView()
        }
    }
}
