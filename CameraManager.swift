import SwiftUI
import AVFoundation
import UIKit

// CameraManager with device orientation handling
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    // MARK: Devices
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?

    // MARK: Input
    private var captureSession: AVCaptureSession!
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?

    // MARK: Output
    private var photoOutput: AVCapturePhotoOutput?

    // MARK: UI Elements
    private(set) var cameraLayer: AVCaptureVideoPreviewLayer!
    @Published private(set) var isGridVisible: Bool = true
    private(set) var cameraGridView: GridView!

    // MARK: Attributes
    @Published private(set) var capturedImage: Data? = nil
    @Published private(set) var cameraPosition: CameraPosition = .back
    @Published private(set) var flashMode: CameraFlashMode = .off
    @Published private(set) var torchMode: CameraTorchMode = .off

    // MARK: Orientation Handling
    override init() {
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
    
    @objc func deviceOrientationDidChange() {
        guard UIDevice.current.orientation.isLandscape else { return }
        updatePreviewOrientation()
    }

    func updatePreviewOrientation() {
        guard let connection = cameraLayer?.connection else { return }
        guard connection.isVideoOrientationSupported else { return }

        connection.videoOrientation = .landscapeRight

        DispatchQueue.main.async {
            self.cameraLayer?.frame = UIScreen.main.bounds
        }
    }

    // Setup methods
    func setup(in cameraView: UIView) throws {
        initialiseCaptureSession()
        initialiseCameraLayer(cameraView)
        initialiseDevices()
        initialiseInputs()
        initialiseOutputs()

        try setupDeviceInputs()
        try setupDeviceOutput()

        startCaptureSession()
        announceSetupCompletion()
        initialiseCameraGridView(cameraView)
    }

    func initialiseCaptureSession() {
        captureSession = .init()
    }

    func initialiseCameraLayer(_ cameraView: UIView) {
        cameraLayer = .init(session: captureSession)
        cameraLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(cameraLayer)
    }

    func initialiseDevices() {
        frontCamera = .default(.builtInWideAngleCamera, for: .video, position: .front)
        backCamera = .default(for: .video)
    }

    func initialiseInputs() {
        if let frontCamera = frontCamera {
            frontCameraInput = try? AVCaptureDeviceInput(device: frontCamera)
        }
        if let backCamera = backCamera {
            backCameraInput = try? AVCaptureDeviceInput(device: backCamera)
        }
    }

    func initialiseOutputs() {
        photoOutput = .init()
    }

    func setupDeviceInputs() throws {
        try setupCameraInput(.back)
    }

    func setupDeviceOutput() throws {
        try setupCameraOutput(.photo)
    }

    func startCaptureSession() {
        DispatchQueue(label: "cameraSession").async {
            self.captureSession.startRunning()
        }
    }

    func announceSetupCompletion() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    func setupCameraInput(_ cameraPosition: CameraPosition) throws {
        switch cameraPosition {
        case .front:
            try setupInput(frontCameraInput)
        case .back:
            try setupInput(backCameraInput)
        }
    }

    func setupCameraOutput(_ outputType: CameraOutputType) throws {
        if let output = getOutput(outputType) {
            try setupOutput(output)
        }
    }

    func setupInput(_ input: AVCaptureDeviceInput?) throws {
        guard let input = input, captureSession.canAddInput(input) else {
            throw Error.cannotSetupInput
        }
        captureSession.addInput(input)
    }

    func setupOutput(_ output: AVCaptureOutput?) throws {
        guard let output = output, captureSession.canAddOutput(output) else {
            throw Error.cannotSetupOutput
        }
        captureSession.addOutput(output)
    }
    
    func initialiseCameraGridView(_ cameraView: UIView) {
        cameraGridView = .init()
        cameraGridView.addAsSubview(to: cameraView)
        cameraGridView.alpha = isGridVisible ? 1 : 0
    }

    func changeGridVisibility(_ shouldShowGrid: Bool) {
        animateGridVisibilityChange(shouldShowGrid)
        updateGridVisibility(shouldShowGrid)
    }

    func animateGridVisibilityChange(_ shouldShowGrid: Bool) {
        UIView.animate(withDuration: 0.32) {
            self.cameraGridView.alpha = shouldShowGrid ? 1 : 0
        }
    }

    func updateGridVisibility(_ shouldShowGrid: Bool) {
        isGridVisible = shouldShowGrid
    }

    func capturePhoto() {
        let settings = getPhotoOutputSettings()
        configureOutput(photoOutput)
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func getPhotoOutputSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode.get()
        return settings
    }

    func changeCamera(_ newPosition: CameraPosition) throws {
        if newPosition != cameraPosition {
            removeCameraInput(cameraPosition)
            try setupCameraInput(newPosition)
            updateCameraPosition(newPosition)
        }
    }

    func removeCameraInput(_ position: CameraPosition) {
        if let input = getInput(position) {
            captureSession.removeInput(input)
        }
    }

    func updateCameraPosition(_ position: CameraPosition) {
        cameraPosition = position
    }

    func getInput(_ position: CameraPosition) -> AVCaptureInput? {
        switch position {
        case .front:
            return frontCameraInput
        case .back:
            return backCameraInput
        }
    }

    func changeFlashMode(_ mode: CameraFlashMode) throws {
        if let device = getDevice(cameraPosition), device.hasFlash {
            updateFlashMode(mode)
        }
    }

    func updateFlashMode(_ value: CameraFlashMode) {
        flashMode = value
    }

    func changeTorchMode(_ mode: CameraTorchMode) throws {
        if let device = getDevice(cameraPosition), device.hasTorch {
            try changeTorchMode(device, mode)
            updateTorchMode(mode)
        }
    }

    func changeTorchMode(_ device: AVCaptureDevice, _ mode: CameraTorchMode) throws {
        try device.lockForConfiguration()
        device.torchMode = mode.get()
        device.unlockForConfiguration()
    }

    func updateTorchMode(_ value: CameraTorchMode) {
        torchMode = value
    }

    func getDevice(_ position: CameraPosition) -> AVCaptureDevice? {
        switch position {
        case .front:
            return frontCamera
        case .back:
            return backCamera
        }
    }

    enum Error: Swift.Error {
        case cannotSetupInput
        case cannotSetupOutput
        case cameraPermissionsNotGranted
    }

    func checkPermissions() throws {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    // Handle the error without throwing
                    DispatchQueue.main.async {
                        self.handlePermissionError()
                    }
                }
            }
        default:
            throw CameraManager.Error.cameraPermissionsNotGranted
        }
    }

    private func handlePermissionError() {
        // Handle the permission error appropriately
    }
    func configureOutput(_ output: AVCapturePhotoOutput?) {
        // Add any necessary configuration for the photo output
        if #available(iOS 16.0, *) {
            output?.maxPhotoDimensions = .init(width: 4032, height: 3024)
        } else {
            output?.isHighResolutionCaptureEnabled = true
        }
    }

    enum CameraOutputType {
        case photo
    }

    func getOutput(_ outputType: CameraOutputType) -> AVCaptureOutput? {
        switch outputType {
        case .photo:
            return photoOutput
        }
    }
}

// UIDeviceOrientation extensions
extension UIDeviceOrientation {
    var rotationAngle: CGFloat {
        switch self {
        case .portrait:
            return 0
        case .landscapeLeft:
            return 90
        case .landscapeRight:
            return -90
        case .portraitUpsideDown:
            return 180
        default:
            return 0
        }
    }

    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return nil
        }
    }
}

// GridView class and extensions
class GridView: UIView {}

extension GridView {
    func addAsSubview(to view: UIView?) {
        guard let view = view else { return }
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear

        view.addSubview(self)

        leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
}

extension GridView {
    override func draw(_ rect: CGRect) {
        let firstColumnPath = UIBezierPath()
        firstColumnPath.move(to: CGPoint(x: bounds.width / 3, y: 0))
        firstColumnPath.addLine(to: CGPoint(x: bounds.width / 3, y: bounds.height))
        let firstColumnLayer = createGridLayer()
        firstColumnLayer.path = firstColumnPath.cgPath
        layer.addSublayer(firstColumnLayer)

        let secondColumnPath = UIBezierPath()
        secondColumnPath.move(to: CGPoint(x: (2 * bounds.width) / 3, y: 0))
        secondColumnPath.addLine(to: CGPoint(x: (2 * bounds.width) / 3, y: bounds.height))
        let secondColumnLayer = createGridLayer()
        secondColumnLayer.path = secondColumnPath.cgPath
        layer.addSublayer(secondColumnLayer)

        let firstRowPath = UIBezierPath()
        firstRowPath.move(to: CGPoint(x: 0, y: bounds.height / 3))
        firstRowPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 3))
        let firstRowLayer = createGridLayer()
        firstRowLayer.path = firstRowPath.cgPath
        layer.addSublayer(firstRowLayer)

        let secondRowPath = UIBezierPath()
        secondRowPath.move(to: CGPoint(x: 0, y: (2 * bounds.height) / 3))
        secondRowPath.addLine(to: CGPoint(x: bounds.width, y: (2 * bounds.height) / 3))
        let secondRowLayer = createGridLayer()
        secondRowLayer.path = secondRowPath.cgPath
        layer.addSublayer(secondRowLayer)
    }
}

private extension GridView {
    func createGridLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(white: 1.0, alpha: 0.28).cgColor
        shapeLayer.frame = bounds
        shapeLayer.fillColor = nil
        return shapeLayer
    }
}
