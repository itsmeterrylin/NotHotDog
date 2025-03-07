import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var cameraModel: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraModel.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(cameraModel: cameraModel)
    }

    class Coordinator: NSObject {
        var cameraModel: CameraModel

        init(cameraModel: CameraModel) {
            self.cameraModel = cameraModel
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            DispatchQueue.main.async {
                self.cameraModel.focus(at: location, in: gesture.view!)
            }
        }
    }
}

struct CameraOverlayView: View {
    @ObservedObject var cameraModel: CameraModel

    var body: some View {
        ZStack {
            if let focusPoint = cameraModel.focusPoint, cameraModel.showFocusIndicator {
                FocusIndicatorView(position: focusPoint)
            }
        }
        .allowsHitTesting(false) // Ensures taps pass through to CameraView
    }
}

struct FocusIndicatorView: View {
    var position: CGPoint

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: 80, height: 80)
            .position(CGPoint(x: position.x - 5, y: position.y - 50)) // 🔥 Adjust Y offset
            .opacity(0.8)
            .transition(.opacity) // 🔥 Smooth fade-in/out
            .animation(.easeOut(duration: 0.5), value: position) // 🔥 Better animation
    }
}
