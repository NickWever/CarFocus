//
//  CameraController.swift
//  CarFocus
//
//  Created by Nick Wever on 02/12/2024.
//
import SwiftUI
import AVFoundation

struct CameraController: View {
    @ObservedObject var cameraManager = CameraManager()
    @State private var cameraError: CameraManager.Error?

    var body: some View {
        ZStack {
            if let error = cameraError {
                createErrorStateView(error)
            } else {
                createCameraView()
            }
        }
        .onAppear(perform: checkCameraPermissions)
        .onChange(of: UIDevice.current.orientation) { _ in
            cameraManager.updatePreviewOrientation()
        }
    }

    private func checkCameraPermissions() {
        do {
            try cameraManager.checkPermissions()
        } catch {
            cameraError = error as? CameraManager.Error
        }
    }

    private func createErrorStateView(_ error: CameraManager.Error) -> some View {
        Text("Camera Error: \(error.localizedDescription)")
    }

    private func createCameraView() -> some View {
        CameraInputView(cameraManager: cameraManager)
    }
}

struct CameraInputView: UIViewRepresentable {
    let cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        cameraManager.setup(in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController()
    }
}

