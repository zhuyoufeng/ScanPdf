//
//  PdfConverter.swift
//  ScanPdf
//
//  Created by zhu youfeng on 2021/8/28.
//

import UIKit
import MobileCoreServices

struct ImageFileType {
    var uti: CFString
    var fileExtention: String

    // This list can include anything returned by CGImageDestinationCopyTypeIdentifiers()
    // I'm including only the popular formats here
    static let bmp = ImageFileType(uti: kUTTypeBMP, fileExtention: "bmp")
    static let gif = ImageFileType(uti: kUTTypeGIF, fileExtention: "gif")
    static let jpg = ImageFileType(uti: kUTTypeJPEG, fileExtention: "jpg")
    static let png = ImageFileType(uti: kUTTypePNG, fileExtention: "png")
    static let tiff = ImageFileType(uti: kUTTypeTIFF, fileExtention: "tiff")
}

func convertPDF(at sourceURL: URL, to destinationURL: URL, fileType: ImageFileType, dpi: CGFloat = 200) throws -> [URL] {
    let pdfDocument = CGPDFDocument(sourceURL as CFURL)!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue

    var urls = [URL](repeating: URL(fileURLWithPath : "/"), count: pdfDocument.numberOfPages)
    DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
        // Page number starts at 1, not 0
        let pdfPage = pdfDocument.page(at: i + 1)!
        
        let mediaBoxRect = pdfPage.getBoxRect(.mediaBox)
        let scale = dpi / 72.0
        let width = Int(mediaBoxRect.width * scale)
        let height = Int(mediaBoxRect.height * scale)

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
        context.interpolationQuality = .high
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.scaleBy(x: scale, y: scale)
        context.drawPDFPage(pdfPage)

        let image = context.makeImage()!
        let imageName = sourceURL.deletingPathExtension().lastPathComponent
        let imageURL = destinationURL.appendingPathComponent("\(imageName)-Page\(i+1).\(fileType.fileExtention)")

        let imageDestination = CGImageDestinationCreateWithURL(imageURL as CFURL, fileType.uti, 1, nil)!
        CGImageDestinationAddImage(imageDestination, image, nil)
        CGImageDestinationFinalize(imageDestination)

        urls[i] = imageURL
    }
    return urls
}


func drawPDFfromURL(url: URL) -> UIImage? {
    guard let document = CGPDFDocument(url as CFURL) else { return nil }
    guard let page = document.page(at: 1) else { return nil }

    let pageRect = page.getBoxRect(.mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let img = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(pageRect)

        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

        ctx.cgContext.drawPDFPage(page)
    }

    return img
}

func convertPDF2(at sourceURL: URL, to destinationURL: URL, fileType: ImageFileType, dpi: CGFloat = 200) throws -> [UIImage] {
    let pdfDocument = CGPDFDocument(sourceURL as CFURL)!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue

    var urls = [URL](repeating: URL(fileURLWithPath : "/"), count: pdfDocument.numberOfPages)
    var images = [UIImage]()
    DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
        
        // Page number starts at 1, not 0
        let pdfPage = pdfDocument.page(at: i + 1)!
        var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
        pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)

        print("\(pageRect.width) by \(pageRect.height)")

        UIGraphicsBeginImageContext(pageRect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()


        images.append(pdfImage)
    }
    return images
}
