/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Contains the object recognition view controller for the Breakfast Finder.
 */

import UIKit
import AVFoundation
import Vision

class VisionObjectRecognitionViewController: ViewControllerBack {
    
    private var detectionOverlay: CALayer! = nil
    private let model = try! VNCoreMLModel(for: CNNEmotions().model)
    // Vision parts
    private var requests = [VNRequest]()
    private var myROI:CGRect=CGRect()
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        //        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
        //            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        //        }
        do {
            //            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            //            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
            //                DispatchQueue.main.async(execute: {
            //                    // perform all the UI updates on the main queue
            //                    if let results = request.results {
            //                        self.drawVisionRequestResults(results)
            //                    }
            //                })
            //            })
            //            self.requests = [objectRecognition]
            
            
            
            //=========== face detection ==========================/
            lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler:  { (request, error) in
                //guard let firstResult = (request.results as? [VNClassificationObservation])?.first else { return }
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.addFaceROI(results)
                    }
                })
            })

            //=========== emotion recognition =====================/
            let objectRecognition = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                //guard let firstResult = (request.results as? [VNClassificationObservation])?.first else { return }
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                    
                })
            })
            self.requests = [faceDetectionRequest,objectRecognition]
            
            
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    
    //    fileprivate func handleDetectedFaces(request: VNRequest?, error: Error?) {
    //        if let nsError = error as NSError? {
    //            print("Face Detection Error", nsError)
    //            return
    //        }
    //        // Perform drawing on the main thread.
    //        DispatchQueue.main.async {
    //            guard let drawLayer = self.pathLayer,
    //                let results = request?.results as? [VNFaceObservation] else {
    //                    return
    //            }
    //            self.draw(faces: results, onImageWithBounds: drawLayer.bounds)
    //            drawLayer.setNeedsDisplay()
    //        }
    //    }
    
    
    func addFaceROI(_ results: [Any]) {
        
        var bestConfidence :Float=0
        var bestBox : CGRect? = CGRect()
        for face in results where face is VNFaceObservation {
            guard let target = face as? VNFaceObservation else {
                continue
            }
            if (target.confidence.isLess(than:  bestConfidence)==false){
                bestConfidence = target.confidence
                bestBox = target.boundingBox
            }
            
        }
        if( bestConfidence>0.8 ){
            // let topLabelObservation = "test label ...."
            
            //            let objectBounds = VNImageRectForNormalizedRect(  bestBox! , Int(bufferSize.width), Int(bufferSize.height))
            //            let shapeLayer = self.createRoundedRectLayerWithBounds2(objectBounds)
            //            detectionOverlay.addSublayer(shapeLayer)
            
            myROI = bestBox ?? CGRect();
        }
        
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        
//                print("--------------------")
//                print(results)
//                print("--------------------")
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        
        
        // ========== emotion recognition ===========
        guard let firstResult = (results as? [VNClassificationObservation])?.first else { return }
        if firstResult.confidence > 0.5 {
            // Select only the label with the highest confidence.
            // let topLabelObservation = "test label ...."
           
            let objectBounds = VNImageRectForNormalizedRect(  myROI , Int(bufferSize.width), Int(bufferSize.height))
            let shapeLayer = self.createRoundedRectLayerWithBounds2(objectBounds)
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: firstResult.identifier,
                                                            confidence: firstResult.confidence)
            //shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        // ==========================================
        
        
        
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print( "=================capture ouput===============" )
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
               
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        
        //=====
        var ename = ""
        switch identifier {
        case "Angry":
            ename = "生氣 Angry"
            break
        case "Happy":
            ename = "開心 Happy"
            break
        case "Fear":
            ename = "害怕 Fear"
            break
        case "Sad":
            ename = "難過 Sad"
            break
        case "Surprise":
            ename = "驚訝 Surprised"
            break
        case "Disgust":
            ename = "厭惡 Disgust"
            break
        default:
            //ename = firstResult.identifier
            print(identifier)
            ename = ""
            break
        }
        
        
        //=====
        
        
        
        
        
        
        let formattedString = NSMutableAttributedString(string: String(format: " \(ename) "))
        let largeFont = UIFont(name: "Helvetica", size: 30.0)!
        let textWidth = 220.0*(Double(ename.count))/10.0
        print(textWidth)
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: formattedString.length))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: textWidth, height: 50)
        textLayer.position = CGPoint(x: bounds.maxX+40, y: bounds.minY+textWidth/2)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.5])
        //textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 0.0, 0.0, 1.0])
        textLayer.foregroundColor = UIColor.yellow.cgColor
        textLayer.contentsScale = 1.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    
    func createRoundedRectLayerWithBounds2(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Face"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0])
        shapeLayer.cornerRadius = 7
        shapeLayer.borderColor =  CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.0, 1.0])
        shapeLayer.borderWidth = 3.0
        return shapeLayer
    }
}
