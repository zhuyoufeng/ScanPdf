//
//  ContentView.swift
//  ScanPdf
//
//  Created by zhu youfeng on 2021/8/28.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    
    @State var scannedCode: String
    @State var alertPresented: Bool = false
    
    var body: some View {
        VStack {
            Text("Pictures")
                .font(.title)
            Button("Convert") {
                convert(url: self.scannedCode)
            }
            .alert(isPresented: $alertPresented) {
                Alert(title: Text("成功"))
            }
            
        }
    }
    
    func convert(url scannedUrl: String) {
        print(scannedUrl)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask, options: .removePreviousFile)
        AF.download(scannedUrl, to: destination).response { response in
            if response.error == nil {
                print(response.fileURL?.path as Any)
                
                let cachesDir = getCachePath()
                print(cachesDir)
                let destinationURL = URL(fileURLWithPath: cachesDir)
                do {
                    let result = try convertPDF(at: response.fileURL!, to: destinationURL, fileType: .jpg, dpi: 300)
                    print(result)

                    let imageSaver = ImageSaver()
                    result.forEach { imageUrl in
                        imageSaver.writeToPhotoAlbum(image: UIImage(contentsOfFile: imageUrl.path)!)
                    }
                    self.alertPresented = true
                    
                    
//                        let result = try convertPDF2(at: response.fileURL!, to: destinationURL, fileType: .jpg, dpi: 200)
//                        print(result)
//
//                        let imageSaver = ImageSaver()
//                        result.forEach { imageUrl in
//                            imageSaver.writeToPhotoAlbum(image: imageUrl)
//                        }
//                        self.alertPresented = true
                } catch {
                    print(error)
                }
            }
        }
    }

    func getCachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths[0]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(scannedCode: "test")
    }
}


class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
