import AVFoundation
import SwiftUI

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var classificationResult: String? // Store ML classification result
    @Published var isProcessing: Bool = false // Show loading state
    @Published var capturedImage: UIImage? // Store the captured image
    @Published var focusPoint: CGPoint? = nil
    @Published var showFocusIndicator = false
    
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "camera.queue")
    private let detector = HotdogDetector() // Initialize ML Model

    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.startSession()
                    }
                }
            }
        default:
            print("Camera access is denied or restricted.")
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }

        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus // 🔥 Always keep autofocus ON
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            device.unlockForConfiguration()
        } catch {
            print("❌ Failed to configure focus/exposure: \(error)")
        }

        session.commitConfiguration()
    }
    
    func startSession() {
        queue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        queue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func focus(at point: CGPoint, in view: UIView) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        let focusPoint = CGPoint(x: point.y / view.bounds.height, y: 1.0 - (point.x / view.bounds.width)) // Convert tap location to camera coordinates

        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.autoFocus) {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }

            if device.isExposureModeSupported(.autoExpose) {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }

            device.unlockForConfiguration()

            // Show focus indicator in SwiftUI
            DispatchQueue.main.async {
                self.focusPoint = point
                self.showFocusIndicator = true
                
                // Hide the focus indicator after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showFocusIndicator = false
                }
            }

        } catch {
            print("❌ Failed to set focus point: \(error)")
        }
    }
    
    func capturePhoto() {
        print("📸 capturePhoto() called at \(Date())")

        DispatchQueue.main.async {
            self.capturedImage = nil
            self.classificationResult = nil
            self.isProcessing = false
        }

        print("✅ Cache cleared. Capturing new photo...")

        guard session.isRunning else {
            print("❌ Camera session is not running. Restarting session...")
            startSession()
            return
        }

        let settings = AVCapturePhotoSettings()

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                try device.lockForConfiguration()
                
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus // 🔥 Ensures it's always refocusing
                }

                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }

                device.unlockForConfiguration()
            } catch {
                print("❌ Failed to set autofocus before capture: \(error)")
            }
        }

        output.capturePhoto(with: settings, delegate: self)
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("⚠️ Failed to process image data.")
            return
        }

        print("✅ New image captured at \(Date()) | Size: \(image.size)")

        DispatchQueue.main.async {
            self.capturedImage = image // Show the captured image
            self.isProcessing = true
        }

        // Classify the image using Core ML
        detector?.classify(image: image) { result in
            DispatchQueue.main.async {
                print("🔎 Classification result received: \(result) at \(Date())") // Debug log
                self.classificationResult = result
                self.isProcessing = false

                // Restart camera preview after classification
                self.startSession()
            }
        }
    }
    
    
}
