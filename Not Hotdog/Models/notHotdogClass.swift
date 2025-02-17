//
//  notHotdog.swift
//  Not Hotdog
//
//  Created by Terry Lin on 2/17/25.
//

import CoreML
import Vision
import UIKit

class HotdogDetector {
    let model: VNCoreMLModel
    
    init?() {
        do {
            let config = MLModelConfiguration()
            let coreMLModel = try notHotdog(configuration: config).model
            let visionModel = try VNCoreMLModel(for: coreMLModel)
            self.model = visionModel
        } catch {
            print("Failed to load the ML model: \(error.localizedDescription)")
            return nil
        }
    }

    func classify(image: UIImage, completion: @escaping (String) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion("Invalid Image")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                completion(topResult.identifier) // Expected output: "hotdog" or "not hotdog"
            } else {
                completion("Unknown")
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            try? handler.perform([request])
        }
    }
}
