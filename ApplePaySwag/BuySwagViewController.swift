//
//  DetailViewController.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit
import PassKit

class BuySwagViewController: UIViewController {

    @IBOutlet weak var swagPriceLabel: UILabel!
    @IBOutlet weak var swagTitleLabel: UILabel!
    @IBOutlet weak var swagImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePaySwagMerchantID = "yourAppleMerchantID"
    
    var swag: Swag! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {

        if (!self.isViewLoaded()) {
            return
        }
        
        self.title = swag.title
        self.swagPriceLabel.text = "$" + swag.priceString
        self.swagImage.image = swag.image
        self.swagTitleLabel.text = swag.description
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        applePayButton.hidden =
            !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
    }
    
    @IBAction func purchase(sender: UIButton) {
        let request  = PKPaymentRequest()
        
        request.merchantIdentifier = ApplePaySwagMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        switch (swag.swagType) {
        case SwagType.Delivered:
            request.requiredShippingAddressFields = [PKAddressField.PostalAddress, PKAddressField.Phone]
        case SwagType.Electronic:
            request.requiredShippingAddressFields = PKAddressField.Email
        }
        
        var summaryItems = [PKPaymentSummaryItem]()
        summaryItems.append(PKPaymentSummaryItem(label: swag.title, amount: swag.price))
        
        if (swag.swagType == .Delivered) {
            summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: swag.shippingPrice))
        }
        
        summaryItems.append(PKPaymentSummaryItem(label: "CyberSource", amount: swag.total()))
        
        request.paymentSummaryItems = summaryItems
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self
        self.presentViewController(applePayController, animated: true, completion: nil)
    }
    
}

extension BuySwagViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        // This section forwards the blob to a resource that handles sending the request off to CYBS for processing.
        // You can print it or do the same, whatever works.
        /*
         let encryptedPaymentData = String(data: payment.token.paymentData.base64EncodedDataWithOptions([]), encoding: NSUTF8StringEncoding)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://myBlobUrl.com")!)
        request.HTTPMethod = "POST"
        let postString = "blob=\(encryptedPaymentData)"
        print(postString)
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
        */
        completion(PKPaymentAuthorizationStatus.Success) 
        
    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}