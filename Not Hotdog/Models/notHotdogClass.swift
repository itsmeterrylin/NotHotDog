//
//  notHotdog.swift
//  Not Hotdog
//
//  Created by Terry Lin on 2/17/25.
//

import CoreML
import Vision
import UIKit
import AVFoundation




class HotdogDetector {
    let model: VNCoreMLModel
    var isProcessing = false
    var processingDelay: TimeInterval = 0.5  // Adjust this value (1.5 seconds by default)
    
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

    var audioPlayer: AVAudioPlayer?

    func playSound(named soundName: String) {
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.volume = 1.0  // Adjust volume (0.0 to 1.0)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error loading sound: \(error.localizedDescription)")
            }
        }
    }
    
    func classify(image: UIImage, completion: @escaping (String) -> Void) {
        guard !isProcessing else {
            print("⚠️ Already processing an image. Please wait.")
            return
        }

        isProcessing = true  // Lock further processing
        let timestamp = Date().timeIntervalSince1970
        print("📊 Processing image at \(Date()) | Image ID: \(timestamp)")

        guard let ciImage = CIImage(image: image) else {
            completion("Invalid Image")
            isProcessing = false  // Unlock processing
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let self = self else { return }

            if let results = request.results as? [VNClassificationObservation] {
                if let topResult = results.first {
                    let formattedResult: String

                    let imageResult: String

                    if topResult.identifier.lowercased().contains("notahotdog") {
                        formattedResult = "❌ Not Hotdog"
                        imageResult = "not_hotdog" // ✅ Image stored in Assets.xcassets
                    } else if topResult.identifier.lowercased().contains("hotdog") {
                        formattedResult = "✅ Hotdog"
                        imageResult = "hotdog" // ✅ If you also have a "hotdog" image
                    } else {
                        formattedResult = "🤔 Unsure"
                        imageResult = "unknown" // ✅ Use a placeholder image if needed
                    }

                    // Introduce a fake delay before displaying the result
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.processingDelay) {
                        print("📸 Sending classification image result: \(imageResult)")
                        completion(imageResult) // ✅ Now passing the image name instead of text  // Display the result after delay
                        self.playSound(named: formattedResult == "✅ Hotdog" ? "success" : "failure")  // Play sound after delay
                        self.isProcessing = false  // Unlock processing
                    }
                    print("🔬 Classification complete at \(Date()) with result: \(formattedResult)")
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.processingDelay) {
                        completion("Unknown")
                        self.isProcessing = false  // Unlock processing
                    }
                    print("⚠️ No classification results.")
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            try? handler.perform([request])
        }
    }
} // ✅ Closing brace properly added for class
