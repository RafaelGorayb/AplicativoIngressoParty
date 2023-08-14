import SwiftUI
import AVFoundation

struct QRCodeScannerViewView: View {
    @EnvironmentObject var qrcodeVm: QrcodeScannerViewModel
    @State private var showTicketOverlay: Bool = false
    let eventoId: String

    var body: some View {
        NavigationView {
            ZStack {
                QRCodeScannerView(viewModel: qrcodeVm, showTicketOverlay: $showTicketOverlay) { decodedTicketInfo in
                    qrcodeVm.ticketInfo = decodedTicketInfo
                    showTicketOverlay = true
                }
                .edgesIgnoringSafeArea(.all)

                if showTicketOverlay, let ticketInfo = qrcodeVm.ticketInfo {
                    VStack{
                        Spacer()
                        ValidationCard(info: ticketInfo,
                                       isTicketValid: qrcodeVm.isTicketValid,
                                       validationMessage: qrcodeVm.validationMessage,
                                       eventoId: eventoId) {
                            showTicketOverlay = false
                        }
                    }
                }
            }
        }
    }
}


struct QRCodeScannerView: UIViewControllerRepresentable {
    var viewModel: QrcodeScannerViewModel
    @Binding var showTicketOverlay: Bool
    var onDetected: (TicketInfo?) -> Void

    func makeCoordinator() -> QRCodeScannerCoordinator {
        return QRCodeScannerCoordinator(onDetected: onDetected, viewModel: viewModel, showTicketOverlay: $showTicketOverlay)
    }





    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return viewController
        }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


class QRCodeScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var onDetected: (TicketInfo?) -> Void
    var viewModel: QrcodeScannerViewModel
    var showTicketOverlay: Binding<Bool>

    init(onDetected: @escaping (TicketInfo?) -> Void, viewModel: QrcodeScannerViewModel, showTicketOverlay: Binding<Bool>) {
        self.onDetected = onDetected
        self.viewModel = viewModel
        self.showTicketOverlay = showTicketOverlay
    }


    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if showTicketOverlay.wrappedValue {
            return
        }

        // Resetar o estado
        viewModel.resetState()

        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let qrCodeString = metadataObject.stringValue else { return }

        processQRCode(qrCodeString: qrCodeString)
    }





    func processQRCode(qrCodeString: String) {
        let jsonData = qrCodeString.data(using: .utf8)!
        let decoder = JSONDecoder()
        if let ticketInfo = try? decoder.decode(TicketInfo.self, from: jsonData) {
            self.viewModel.ticketInfo = ticketInfo
            self.viewModel.checkTicketValidity()
            self.showTicketOverlay.wrappedValue = true // Adicione esta linha
        }
    }


}
