//
//  ViewController.swift
//  HighQualityPhoto
//
//  Created by Vít Šebela on 17.03.2021.
//

import UIKit
import AVFoundation
import VideoToolbox

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var cameraPreviewView: UIView!
    @IBOutlet var takePictureButton: UIButton!
    
    private let session = AVCaptureSession()
    private var camera: AVCaptureDevice?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var cameraCaptureOutput: AVCapturePhotoOutput?
    private var rawImageFileURL: URL?
    private var compressedFileData: Data?
    private var image: UIImage?
    private var numberOfImagesToCapture: Int = 4
    private var countDown: Int?
    private var sharpenedImage: UIImage?
    
    private var capturedImages: [UIImage] = []
//    private let saveButton: UIButton = {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
//        button.setTitle("Save to library", for: .normal)
//        button.backgroundColor = .systemBlue
//        return button
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let uialert = UIAlertController(title: "Processing image", message: "It may take a few seconds", preferredStyle: .alert)
        initCaptureSession()
//        self.present(uialert, animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
//        uialert.message = "Ahoj"
//        self.present(uialert, animated: true, completion: nil)
        session.startRunning()
    }
    
    func initCaptureSession(){
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        camera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.back)
        
        print(camera?.isFocusModeSupported(.continuousAutoFocus) as Any)
        
        try! camera?.lockForConfiguration()
        camera?.focusMode = .continuousAutoFocus
        camera?.videoZoomFactor = 1.0
        camera?.unlockForConfiguration()
        
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            guard session.canAddOutput(cameraCaptureOutput!) else { return }
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.bounds
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewView.layer.addSublayer(cameraPreviewLayer!)
//        cameraPreviewView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
//
//       view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    func showSimpleAlert() {
        let title = NSLocalizedString("A Short Title is Best", comment: "")
        let message = NSLocalizedString("Picture is being taken, hold still", comment: "")
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            print("The simple alert's cancel action occurred.")
        }

        // Add the action.
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func takePicturesButton(_ sender: Any) {
        
        capturedImages = []
        sharpenedImage = nil
        takePictureButton.isEnabled = false
        print("Capturing photo...\n")
        countDown = numberOfImagesToCapture
        takePicture()
    }
    
    @IBAction func captureOneImage(_ sender: Any) {
        self.numberOfImagesToCapture = 1
        print("Number of images to capture ",self.numberOfImagesToCapture)
    }
    
    @IBAction func captureTreeImages(_ sender: Any) {
        self.numberOfImagesToCapture = 3
        print("Number of images to capture ",self.numberOfImagesToCapture)
    }
    
    @IBAction func captureFiveImages(_ sender: Any) {
        self.numberOfImagesToCapture = 15
        print("Number of images to capture ",self.numberOfImagesToCapture)
    }
    
    func takePicture() {
//        showCountdownRectangle(number: countDown!)
        print("output captured")
//        guard let availableRawFormat = self.cameraCaptureOutput?.availableRawPhotoPixelFormatTypes.first else { return }
//        let photoSettings = AVCapturePhotoSettings(rawPixelFormatType: availableRawFormat, processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc])
        
        let pixelFormatType = kCVPixelFormatType_32BGRA
        guard self.cameraCaptureOutput!.availablePhotoPixelFormatTypes.contains(pixelFormatType) else { return }
//        let photoSettings = AVCapturePhotoSettings(format:
//            [ kCVPixelBufferPixelFormatTypeKey as String : pixelFormatType ])
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            
        // Capture image
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
//        }
        self.cameraCaptureOutput?.capturePhoto(with: photoSettings, delegate: self)
    
        print(photoSettings)
    }
    
    func storeImage(image: UIImage) {
        capturedImages.append(image)
        print(capturedImages)
    }
    
    // MARK: Delegate's photoOutput function for capture handling
    // delegate function called when photo is being captured
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // check if there is error
        print("Im here")
        print(countDown!)
        if let unwrappedError = error {
            print(unwrappedError.localizedDescription)
        }
        
//        guard let rawFormat = photo.pixelBuffer else {return}
        guard let compressedImage = photo.fileDataRepresentation() else {return}
        
        storeImage(image: UIImage(data: compressedImage)!)        
        
//        var tempImage: UnsafeMutablePointer<CGImage?> = UnsafeMutablePointer<CGImage?>.allocate(capacity: 1)
//
//
//        VTCreateCGImageFromCVPixelBuffer(rawFormat, options: nil, imageOut: tempImage)
        
//        if let temp = tempImage.pointee as CGImage? {
//            storeImage(image: UIImage(cgImage: temp))
//        } else {
//            print("Image from camera is nil!")
//        }
        
        
//        if let imageData = photo.fileDataRepresentation() {
//            storeImage(image: UIImage(data: imageData))
//        }
//        storeImage(image: image)
        // Create UIImage from data
        // Save to Users Photo App
//        !!
//        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil) TODO Save to LIB
//        print("Saved photo...")
        if countDown! > 1 {
            takePicture()
            print("Taking image number \(countDown!)")
            countDown! -= 1
        } else {
            print("FINISHED!")
            takePictureButton.isEnabled = true
            processImages()
                        
//            present(ProcessedImageViewController(image: image!), animated: true)
//            let newViewController = ProcessedImageViewController(image: image!)
//            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    
    var tempImg: UIImage?
    
    func processImages() {
        var CVWrapper: OpenCVWrapper? = OpenCVWrapper()
//        let x = AutoreleasingUnsafeMutablePointer<UIImage?>
        UIImageWriteToSavedPhotosAlbum(capturedImages[0], nil, nil, nil)
        sharpenedImage = CVWrapper!.process4(capturedImages[0], image2: capturedImages[1], image3: capturedImages[2], image4: capturedImages[3])
        UIImageWriteToSavedPhotosAlbum(sharpenedImage!, nil, nil, nil)
        tempImg = capturedImages[0]
        capturedImages = []
        performSegue(withIdentifier: "showImage", sender: nil)
        CVWrapper = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showImage = segue.destination as? showImageViewController {
            showImage.image = tempImg
//            showImage.imageView.image? = capturedImages[0]
        }
    }
}

class ProcessedImageViewController: UIViewController {
    private var bgImage: UIImageView?
    private var image: UIImage?
        
    init(image: UIImage) {
       self.image = image
       super.init(nibName: nil, bundle: nil)
   }

   @available(*, unavailable)
   required init?(coder: NSCoder) {
       fatalError("This class does not support NSCoder")
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            view.backgroundColor = .black
        }

        
//        var image: UIImage = UIImage(named: "afternoon")!
        bgImage = UIImageView(image: image)
                
        bgImage!.contentMode = UIView.ContentMode.scaleAspectFit
        bgImage!.frame.size.width = 432
        bgImage!.frame.size.height = 768
        bgImage!.center = self.view.center
        
        
        self.view.addSubview(bgImage!)

    }
}
