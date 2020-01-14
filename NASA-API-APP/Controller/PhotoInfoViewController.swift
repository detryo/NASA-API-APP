//
//  PhotoInfoViewController.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import MessageUI

class PhotoInfoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var addTextField: UITextField!
    
    var photo: RoverImage!
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTextField.delegate = self
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
            
        }
    }
    
    @IBAction func addTextClicked(_ sender: Any) {
        
        if let textMessage = addTextField.text {
            
            if textMessage != "" {
                
                if let image = self.imageView.image {
                    
                    let newImage = textToImage(drawText: textMessage as NSString, inImage: image, atPoint: CGPoint(x: 20, y: 20))
                    self.self.imageView.image = newImage
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 200)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 200)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
           UIView.beginAnimations( "animateView", context: nil)
           UIView.setAnimationBeginsFromCurrentState(true)
           UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
           UIView.commitAnimations()
    }
    
    @IBAction func EmailImageClicked(_ sender: Any) {
        composeMail()
    }
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {


        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrs = [NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: 12)!,NSAttributedString.Key.foregroundColor : UIColor.white , NSAttributedString.Key.paragraphStyle: paragraphStyle]

        text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func composeMail() {
        
        guard MFMailComposeViewController.canSendMail() else {
            
            self.generalAlert(title: "Email Missing", message: "You must set up an email address on this device to send a postcard.")
            return
        }
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        mailComposeVC.addAttachmentData(imageView.image!.jpegData(compressionQuality: 1.0)!, mimeType: "image/jpeg", fileName:  "MarsPostcard.jpeg")
        mailComposeVC.setSubject("Postcard from Mars")
        mailComposeVC.setMessageBody("<html><body><p>This is your message</p></body></html>", isHTML: true)
        
        self.present(mailComposeVC, animated: true, completion: nil)
    }
}

extension PhotoInfoViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let error = error {
            self.generalAlert(title: "Error", message: "Please check your connection and try again.\n\nError: \(error.localizedDescription)")
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
            case .cancelled:
                print("cancelled")
            case .failed:
                print("failed")
            case .saved:
                print("saved")
            case .sent:
                print("sent")
            default: return
        }
        
        controller.dismiss(animated: true)
    }
}

extension UIViewController {
    
    func generalAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
