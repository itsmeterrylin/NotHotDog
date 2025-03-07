import SwiftUI
import AVFoundation

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}


struct ContentView: View {
    @StateObject private var cameraModel = CameraModel()
    
    var body: some View {
        ZStack {
            if let capturedImage = cameraModel.capturedImage {
                ZStack {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    if let result = cameraModel.classificationResult {
                        VStack {
                            Spacer().frame(height: 100)
                            
                            GeometryReader { geometry in
                                Image(result)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, geometry.safeAreaInsets.top + -100)
                                    .edgesIgnoringSafeArea(.horizontal)
                            }
                            .onAppear {
                                print("🖼 Classification result: \(result)")
                            }
                            
                            Spacer()
                            
                            Button("Try Again") {
                                print("🔄 Resetting session")
                                cameraModel.capturedImage = nil
                                cameraModel.classificationResult = nil
                                cameraModel.isProcessing = false
                                cameraModel.startSession()
                                print("✅ Reset complete")
                            }
                            .padding()
                            .background(Color(hex: "23D3FC"))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .padding(.bottom, 50)
                    } else {
                        // Show analyzing overlay while waiting for AI processing
                        Text("Analyzing with AI...")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
            } else {
                ZStack {
                    CameraView(cameraModel: cameraModel)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            print("▶️ Starting camera session automatically...")
                            cameraModel.startSession()
                        }

                    CameraOverlayView(cameraModel: cameraModel) // 🔥 Ensure it’s on top but non-blocking
                }
                
                VStack {
                    Spacer()
                    
                    if cameraModel.isProcessing {
                        Image("analyzing_with_ai")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        Button(action: {
                            cameraModel.capturePhoto()
                        }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 90, height: 90)
                                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}
