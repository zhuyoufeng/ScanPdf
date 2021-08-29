//
//  QRCodeScannerView.swift
//  ScanPdf
//
//  Created by zhu youfeng on 2021/8/28.
//

import SwiftUI
import CodeScanner

struct QRCodeScannerView: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if self.scannedCode != nil {
                    NavigationLink("Next page", destination: ContentView(scannedCode: scannedCode!), isActive: .constant(true)).hidden()
                }
                Button("Scan Code") {
                    self.isPresentingScanner = true
                }
                .sheet(isPresented: $isPresentingScanner) {
                    self.scannerSheet
                }
                Text("Scan a QR code to begin")
            }

        }
    }

    var scannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code
                    self.isPresentingScanner = false
                }
            }
        )
    }
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView()
    }
}
