import SwiftUI
import AVFoundation
import UIKit

enum CameraPosition {
    case front
    case back
}

enum CameraFlashMode {
    case on
    case off
    case auto
    
    func get() -> AVCaptureDevice.FlashMode {
        switch self {
        case .on: return .on
        case .off: return .off
        case .auto: return .auto
        }
    }
}

enum CameraTorchMode {
    case on
    case off
    
    func get() -> AVCaptureDevice.TorchMode {
        switch self {
        case .on: return .on
        case .off: return .off
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var geselecteerdeFoto: UIImage?
    @Binding var isCameraActive: Bool
    var voltooiFoto: (UIImage) -> Void
    @Binding var huidigeFotoNaam: String

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        var captureSession: AVCaptureSession?
        var photoOutput: AVCapturePhotoOutput?
        var previewLayer: AVCaptureVideoPreviewLayer?
        var frontCameraInput: AVCaptureDeviceInput?
        var backCameraInput: AVCaptureDeviceInput?
        var currentCameraPosition: CameraPosition = .back

        init(parent: CameraView) {
            self.parent = parent
            super.init()

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(deviceOrientationDidChange),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        func setupSession(in view: UIView) {
            captureSession = AVCaptureSession()
            guard let captureSession = captureSession else { return }

            captureSession.beginConfiguration()

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  captureSession.canAddInput(videoInput) else {
                print("❌ Error: Cannot configure camera input.")
                return
            }
            captureSession.addInput(videoInput)
            backCameraInput = videoInput

            photoOutput = AVCapturePhotoOutput()
            guard let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) else {
                print("❌ Error: Cannot configure photo output.")
                return
            }
            captureSession.addOutput(photoOutput)

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            if let previewLayer = previewLayer {
                DispatchQueue.main.async {
                    view.layer.insertSublayer(previewLayer, at: 0)
                }
            }

            captureSession.commitConfiguration()
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }

            updatePreviewOrientation()
        }

        @objc func deviceOrientationDidChange() {
            updatePreviewOrientation()
        }

        func updatePreviewOrientation() {
            guard let connection = previewLayer?.connection else { return }
            guard connection.isVideoRotationAngleSupported else { return }

            switch UIDevice.current.orientation {
            case .portrait:
                connection.videoRotationAngle = 0
            case .landscapeLeft:
                connection.videoRotationAngle = 90
            case .landscapeRight:
                connection.videoRotationAngle = -90
            case .portraitUpsideDown:
                connection.videoRotationAngle = 180
            default:
                connection.videoRotationAngle = 0
            }

            DispatchQueue.main.async {
                self.previewLayer?.frame = UIScreen.main.bounds
            }
        }

        @objc func capturePhoto() {
            guard let photoOutput = photoOutput else { return }

            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            photoOutput.capturePhoto(with: settings, delegate: self)
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                print("❌ Error capturing photo: \(error.localizedDescription)")
                return
            }

            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                print("❌ Error: Could not process photo data.")
                return
            }

            let fixedImage = image.fixedOrientation()
            DispatchQueue.main.async {
                self.parent.geselecteerdeFoto = fixedImage
                self.parent.voltooiFoto(fixedImage)
                
                // Update the photo name
                self.parent.huidigeFotoNaam = "Foto_\(UUID().uuidString).jpg"
            }
        }

        @objc func toggleFlash() {
            if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = device.torchMode == .on ? .off : .on
                    device.unlockForConfiguration()
                } catch {
                    print("❌ Error toggling flash: \(error)")
                }
            }
        }

        @objc func adjustExposure(_ sender: UISlider) {
            if let device = AVCaptureDevice.default(for: .video) {
                do {
                    try device.lockForConfiguration()
                    device.setExposureTargetBias(sender.value, completionHandler: nil)
                    device.unlockForConfiguration()
                } catch {
                    print("❌ Error adjusting exposure: \(error)")
                }
            }
        }

        @objc func switchCamera() {
            guard let captureSession = captureSession else { return }
            captureSession.beginConfiguration()

            if currentCameraPosition == .back {
                guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                      let frontInput = try? AVCaptureDeviceInput(device: frontCamera),
                      captureSession.canAddInput(frontInput) else {
                    print("❌ Error: Cannot switch to front camera.")
                    return
                }
                captureSession.removeInput(backCameraInput!)
                captureSession.addInput(frontInput)
                frontCameraInput = frontInput
                currentCameraPosition = .front
            } else {
                captureSession.removeInput(frontCameraInput!)
                captureSession.addInput(backCameraInput!)
                currentCameraPosition = .back
            }

            captureSession.commitConfiguration()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        context.coordinator.setupSession(in: viewController.view)

        let captureButton = UIButton()
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(context.coordinator, action: #selector(Coordinator.capturePhoto), for: .touchUpInside)
        viewController.view.addSubview(captureButton)

        let flashButton = UIButton()
        flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        flashButton.backgroundColor = .gray
        flashButton.layer.cornerRadius = 20
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.addTarget(context.coordinator, action: #selector(Coordinator.toggleFlash), for: .touchUpInside)
        viewController.view.addSubview(flashButton)

        let switchButton = UIButton()
        switchButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        switchButton.backgroundColor = .gray
        switchButton.layer.cornerRadius = 20
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.addTarget(context.coordinator, action: #selector(Coordinator.switchCamera), for: .touchUpInside)
        viewController.view.addSubview(switchButton)

        let exposureSlider = UISlider()
        exposureSlider.minimumValue = -2.0
        exposureSlider.maximumValue = 2.0
        exposureSlider.translatesAutoresizingMaskIntoConstraints = false
        exposureSlider.addTarget(context.coordinator, action: #selector(Coordinator.adjustExposure(_:)), for: .valueChanged)
        viewController.view.addSubview(exposureSlider)

        let fotoNaamLabel = UILabel()
        fotoNaamLabel.text = huidigeFotoNaam
        fotoNaamLabel.textAlignment = .center
        fotoNaamLabel.textColor = .white
        fotoNaamLabel.font = UIFont.boldSystemFont(ofSize: 20)
        fotoNaamLabel.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(fotoNaamLabel)

        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            captureButton.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),

            flashButton.widthAnchor.constraint(equalToConstant: 40),
            flashButton.heightAnchor.constraint(equalToConstant: 40),
            flashButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
            flashButton.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            switchButton.widthAnchor.constraint(equalToConstant: 40),
            switchButton.heightAnchor.constraint(equalToConstant: 40),
            switchButton.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: -20),
            switchButton.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),

            exposureSlider.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
            exposureSlider.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
            exposureSlider.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),

            fotoNaamLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            fotoNaamLabel.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let label = uiViewController.view.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.text = huidigeFotoNaam
        }
    }
}


extension UIImage {
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
