//
//  OrderPlacedScreen.swift
//  EnterSlice
//
//  Created by OSX on 07/10/17.
//  Copyright © 2017 athenasoft. All rights reserved.
//

import UIKit

class OrderPlacedScreen: UIViewController, PGTransactionDelegate, PUCBWebVCDelegate, NetworkServiceDelegate {
    
    var mParentScreen : MainOrderScreen!
    
    var mParent : PaymentOptionScreen!
    
    @IBOutlet var mMenuBtn: UIBarButtonItem!
    
    @IBOutlet var mOrderPlacedImage: UIImageView!
    
    @IBOutlet var mOrderLbl: UILabel!
    
    @IBOutlet var mViewOrderBtn: UIButton!
    
    var newOrderModel = NewOrderModel()
    
    var payInVoiceModel = PayInVoiceModel()
    
    var payInVoiceSuccessModel = PayInVoiceSuccessModel()
    
    var isPaymentMethod = false
    
    var isGetHashForPayU = false
    
    var isPayInvoice = false
    
    let networkService = NetworkService.getInstance()
    
    var mSpinner: UIActivityIndicatorView!
    
    var isPaymentSuccessORFail = false
    
    var isSuccessPayment = false
    
    var isFailurePayment = false
    
    var isViewProfile = false
    
    var isSuccessPayInVoicePayment = false
    
    var isFailerPayInVoicePayment = false
    
    var userModel = UserModel()
    
    var merchant:PGMerchantConfiguration!
    
    var paymentHash = ""
    
    var payInVoice = false
    
    var checkoutModel = CheckoutModel()
    
    let mStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    var viewProfileModel = ViewProfileModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = Validation.AppThemeColor()
        
        self.mSpinner = Validation.createProgressRing(self)
        
        self.userModel = UserPreferenceClass.getInstance().getUserInfo()
        
        if payInVoice {
            if isPaymentSuccessORFail {
                self.mOrderLbl.text = "InVoice #\(newOrderModel.order_no) Created Successfully Our Agents will respond in 12 Working Hours."
                self.mViewOrderBtn.setTitle("VIEW INVOICE", for: .normal)
            }
            else{
                self.mOrderLbl.text = "Your Payment was unsuccessfull. Any Debit will be refunded in 3-7 working days."
                self.mOrderPlacedImage.image = UIImage.init(named: "plane")
                self.mViewOrderBtn.setTitle("RETRY", for: .normal)
                self.mViewOrderBtn.backgroundColor = UIColor.init(red: 54.0/255.0, green: 198.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            }
        }
        else{
            if isPaymentSuccessORFail {
                self.mOrderLbl.text = "Order #\(newOrderModel.order_no) Created Successfully Our Agents will respond in 12 Working Hours."
            }
            else{
                self.mOrderLbl.text = "Your Payment was unsuccessfull. Any Debit will be refunded in 3-7 working days."
                self.mOrderPlacedImage.image = UIImage.init(named: "plane")
                self.mViewOrderBtn.setTitle("RETRY", for: .normal)
                self.mViewOrderBtn.backgroundColor = UIColor.init(red: 54.0/255.0, green: 198.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            }
        }
        
        //self.mSpinner.startAnimating()
        
//        if isPaymentMethod {
//            self.paytmPaymentIntegration()
//        }
//        else{
//            self.payUPaymentIntegrate()
//        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func menuBtnAction(_ sender: Any) {
        
        let obj = self.mStoryboard.instantiateViewController(withIdentifier: "Menu") as! MenuScreen
        self.present(obj, animated: true, completion: nil)
    }
    
    @IBAction func viewOrderAction(_ sender: Any) {
        
        if (self.mViewOrderBtn.currentTitle?.contains("RETRY"))! {
            if self.mParent.isPayInvoice {
                if self.mParent.isPaymentMethod {
                    self.isPayInvoice = self.mParent.isPayInvoice
                    self.setMerchant()
                    self.paytmPaymentIntegration()
                }
                else{
                    self.isPayInvoice = self.mParent.isPayInvoice
                    self.payUPaymentIntegrate()
                }
            }
            else {
                if self.mParent.isPaymentMethod {
                    self.isPayInvoice = self.mParent.isPayInvoice
                    self.setMerchant()
                    self.paytmPaymentIntegration()
                }
                else{
                    self.isPayInvoice = self.mParent.isPayInvoice
                    self.payUPaymentIntegrate()
                }
            }
        }
        else {
            if payInVoice {
                if isPaymentSuccessORFail {
                    let obj = self.mStoryboard.instantiateViewController(withIdentifier: "InVoices") as! InVoicesScreen
                    
                    obj.payInVoiceSuccessModel = payInVoiceSuccessModel
                    
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                else{
                    
                }
            }
            else{
                if isPaymentSuccessORFail {
                    
                    let obj = self.mStoryboard.instantiateViewController(withIdentifier: "AllOrdersDesc") as! AllOrdersDescScreen
                    
                    obj.newOrderModel = newOrderModel
                    
                    obj.mParent = self
                    
                    obj.mParentScreen = self.mParentScreen
                    
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                else{
                    
                }
            }
        }
    }
    
    func payUPaymentIntegrate() {
        
        //https://enterslice.com/app/services.php?opt=getHashes&txnid=5138&amount=3999&productinfo=Private%20Limited%20Company&member_id=782
        
        let orderNo = String(newOrderModel.order_no)
        
        var orderDict: [String : String] = [:]
        
        if isPayInvoice {
            orderDict = [
                
                "opt" : "getHashes",
                "txnid" : payInVoiceModel.order_no,
                "amount" : payInVoiceModel.amount,   //(todo)
                //"amount" : "1",
                "productinfo" : payInVoiceModel.productinfo,
                "member_id":self.userModel.member_id
            ]
        }
        else{
            orderDict = [
                
                "opt" : "getHashes",
                "txnid" : orderNo,
                "amount" : newOrderModel.amount,   // (todo)
               // "amount" : "1",
                "productinfo" : newOrderModel.productinfo,
                "member_id":self.userModel.member_id
            ]
        }
        
        isGetHashForPayU = true
        
        isSuccessPayment = false
        
        isFailurePayment = false
        
        networkService.delegate = self
        
        networkService.makeServiceCall(method: .get, headers: orderDict)
    }
    
    func payUPaymentWebView() {
        
        let restURL = URL(string:PAYU_PAYMENT_PRODUCTION_URL) //PAYU_PAYMENT_TEST_URL   //PAYU_PAYMENT_MOBILETEST_URL
        
        
        //restURL = [NSURL URLWithString:@"https://secure.payu.in/_payment"];
        let name1 = viewProfileModel.fname + " " + viewProfileModel.lname
        var userCredit = KEY + ":" + viewProfileModel.member_email
        var val1 = "udf1"
        var val2 = "udf2"
        var val3 = "udf3"
        var val4 = "udf4"
        var val5 = "udf5"
        let req = NSMutableURLRequest(url: restURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        req.httpMethod = "POST"
        /* Format to generate hash Value
         hashValue = @"key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT";
         */
        let orderNo = String(newOrderModel.order_no)
        
        var postData = ""
        
        if isPayInvoice {
            // \(payInVoiceModel.amount)     todo
            postData = "key=\(KEY)&salt=\(ID)&email=\(viewProfileModel.member_email)&amount=\(payInVoiceModel.amount)&firstname=\(name1)&txnid=\(payInVoiceModel.order_no)&user_credentials=\("DEFAULT")&productinfo=\(payInVoiceModel.productinfo)&phone=\(viewProfileModel.contact_no)&surl=\(SURL)&furl=\(FURL)&offer_key=\(OFFERKEY)&hash=\(paymentHash)&&user_credentials=\(userCredit)&udf1=\(val1)&udf2=\(val2)&udf3=\(val3)&udf4=\(val4)&udf5=\(val5)"
            
            print("Post Data = \(postData)")
        }
        else{
         //   \(newOrderModel.amount)  todo
            postData = "key=\(KEY)&salt=\(ID)&email=\(viewProfileModel.member_email)&amount=\(newOrderModel.amount)&firstname=\(name1)&txnid=\(orderNo)&user_credentials=\("DEFAULT")&productinfo=\(newOrderModel.productinfo)&phone=\(viewProfileModel.contact_no)&surl=\(SURL)&furl=\(FURL)&offer_key=\(OFFERKEY)&hash=\(paymentHash)&&user_credentials=\(userCredit)&udf1=\(val1)&udf2=\(val2)&udf3=\(val3)&udf4=\(val4)&udf5=\(val5)"
            
            print("Post Data = \(postData)")
        }
        
        req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        req.httpBody = postData.data(using: String.Encoding.utf8)
        
        do{
            let webVC = try PUCBWebVC.init(nsurlRequest:req as URLRequest! , merchantKey: KEY)  //(postParam:postData , url: restURL, merchantKey: KEY)
            webVC.cbWebVCDelegate = self
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        catch {
            print(error)
        }
    }
    
    //        let PVC = self.mStoryboard.instantiateViewController(withIdentifier: "Web") as! WebScreen
    //        PVC.req = req
    //        self.navigationController?.pushViewController(PVC, animated: true)
    
    /*!
     * This method gets called when transaction is successfull. It logs txn_success event.
     * @param [response]            [id type]
     */
    public func payUSuccessResponse(_ response: Any!) {
        print("Sresponse \(response)")
    }
    
    /*!
     * This method gets called when transaction fails. It logs txn_fail event.
     * @param [response]            [id type]
     */
    public func payUFailureResponse(_ response: Any!) {
        print("Fresponse \(response)")
    }
    
    /*!
     * This method gets called in case of network error
     * @param [notification]            [NSDictionary type]
     */
    public func payUConnectionError(_ notification: [AnyHashable : Any]!) {
        print("notification \(notification)")
    }
    
    /*!
     * This method gets called in case of transaction is cancelled by Back press
     */
    public func payUTransactionCancel() {
        print("cancel")
    }
    
    public func payUSuccessResponse(_ payUResponse: Any!, surlResponse: Any!) {
        print("payUResponse \(payUResponse) && surlResponse \(surlResponse)")
    }
    
    public func payUFailureResponse(_ payUResponse: Any!, furlResponse: Any!) {
        print("payUResponse \(payUResponse) && furlResponse \(furlResponse)")
    }
    
    
    func setMerchant(){
        merchant  = PGMerchantConfiguration.default()!
        //user your checksum urls here or connect to paytm developer team for this or use default urls of paytm
        merchant.checksumGenerationURL = "http://getlook.in/cgi-bin/checksum_generate.cgi";
        merchant.checksumValidationURL = "http://getlook.in/cgi-bin/checksum_validate.cgi";
        
        // Set the client SSL certificate path. Certificate.p12 is the certificate which you received from Paytm during the registration process. Set the password if the certificate is protected by a password.
        merchant.clientSSLCertPath = nil; //[[NSBundle mainBundle]pathForResource:@"Certificate" ofType:@"p12"];
        merchant.clientSSLCertPassword = nil; //@"password";
        
        //configure the PGMerchantConfiguration object specific to your requirements
        merchant.merchantID = payTmKey;//paste here your merchant id  //mandatory
        merchant.website = "Enterslice";//mandatory
        merchant.industryID = "Retail110";//mandatory
        merchant.channelID = "WAP"; //provided by PG WAP //mandatory
        
    }
    
    func paytmPaymentIntegration() {
        
        let orderNo = String(newOrderModel.order_no)
        
        var orderDict = [String : String]()
        
        if isPayInvoice {
            orderDict["MID"] = payTmKey;//paste here your merchant id   //mandatory //orderDict["MID"] = "getloo16416993055668";/
            orderDict["CHANNEL_ID"] = "WAP"; // paste here channel id                       // mandatory
            orderDict["INDUSTRY_TYPE_ID"] = "Retail110";//paste industry type              //mandatory
            orderDict["WEBSITE"] = "Enterslice";// paste website                            //mandatory //orderDict["WEBSITE"] = "getlookwap";
            //Order configuration in the order object
            orderDict["TXN_AMOUNT"] = payInVoiceModel.amount; // amount to charge                      // mandatory
            orderDict["ORDER_ID"] = payInVoiceModel.order_no;//change order id every time on new transaction
            orderDict["REQUEST_TYPE"] = "DEFAULT";// remain same
            orderDict["CUST_ID"] = "123456789027"; // change acc. to your database user/customers
            orderDict["MOBILE_NO"] = viewProfileModel.contact_no;// optional
            orderDict["EMAIL"] = viewProfileModel.member_email; //optional
        }
        else{
            
            orderDict["MID"] = payTmKey;//paste here your merchant id   //mandatory
            orderDict["CHANNEL_ID"] = "WAP"; // paste here channel id                       // mandatory
            orderDict["INDUSTRY_TYPE_ID"] = "Retail110";//paste industry type              //mandatory
            orderDict["WEBSITE"] = "Enterslice";// paste website                            //mandatory
            //Order configuration in the order object
            orderDict["TXN_AMOUNT"] = newOrderModel.amount; // amount to charge                      // mandatory
            orderDict["ORDER_ID"] = orderNo;//change order id every time on new transaction
            orderDict["REQUEST_TYPE"] = "DEFAULT";// remain same
            orderDict["CUST_ID"] = "123456789027"; // change acc. to your database user/customers
            orderDict["MOBILE_NO"] = viewProfileModel.contact_no;// optional
            orderDict["EMAIL"] = viewProfileModel.member_email; //optional
        }
        
        let pgOrder = PGOrder(params: orderDict )
        
        let transaction = PGTransactionViewController.init(transactionFor: pgOrder)
        
        transaction!.serverType =  eServerTypeProduction
        transaction!.merchant = merchant
        transaction!.loggingEnabled = true
        transaction!.delegate = self
        let nav1  = UINavigationController.init(rootViewController: transaction!)
        self.present(nav1, animated: true, completion: {
            
        })
    }
    
    // MARK: Delegate methods of Payment SDK.
    func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        
        // After Successful Payment
        print("ViewController::didSucceedTransactionresponse= %@", response)
        let msg: String = "Your order was completed successfully.\n Rs. \(response["TXN_AMOUNT"]!)"
        
        print(msg)
    }
    
    func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        // Called when Transation is Failed
        //print("ViewController::didFailTransaction error = %@ response= %@", error, response)
    }
    
    func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        //Cal when Process is Canceled
        var msg: String = ""
        
        if error != nil {
            
            msg = String(format: "Successful")
        }
        else {
            msg = String(format: "UnSuccessful")
        }
        print(msg)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func didFinishCASTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        print(response)
    }
    
    func receivedGroupsJSON(_ json: Any, url: URL) {
        self.mSpinner.stopAnimating()
        if isViewProfile {
            isViewProfile = false
            let viewProfileArray = GroupBuilder.parseViewProfileAPI(json: json as AnyObject)
            
            if (viewProfileArray?.count)! > 0 {
                viewProfileModel = viewProfileArray?[0] as! ViewProfileModel
            }
        }
        else if isGetHashForPayU {
            isGetHashForPayU = false
            
            if (json as AnyObject).value(forKey: "status") != nil {
                let status = (json as AnyObject).value(forKey: "status") as! String
                
                if status == "Success" {
                    let dataJson = (json as AnyObject).value(forKey: "data") as AnyObject
                    if dataJson.value(forKey: "payment_hash") != nil {
                        let hash = dataJson.value(forKey: "payment_hash") as? String
                        if hash != nil {
                            self.paymentHash = dataJson.value(forKey: "payment_hash") as! String
                        }
                        else{
                            self.paymentHash = ""
                        }
                    }
                }
            }
            
            self.payUPaymentWebView()
        }
        else if isSuccessPayment {
            isSuccessPayment = false
            let obj = self.mStoryboard.instantiateViewController(withIdentifier: "OrderPlaced") as! OrderPlacedScreen
            obj.newOrderModel = newOrderModel
            obj.mParentScreen = self.mParentScreen
            obj.isPaymentSuccessORFail = true
            let nav1 = UINavigationController.init(rootViewController: obj)
            self.present(nav1, animated: true, completion: nil)
        }
        else if isFailurePayment {
            
        }
        else if isSuccessPayInVoicePayment {
            isSuccessPayInVoicePayment = false
            let model = GroupBuilder.parsePayInVoicePaymentSuccessAPI(json: json as AnyObject)!
            let obj = self.mStoryboard.instantiateViewController(withIdentifier: "OrderPlaced") as! OrderPlacedScreen
            obj.payInVoiceModel = payInVoiceModel
            obj.payInVoiceSuccessModel = model
            obj.isPaymentSuccessORFail = true
            obj.payInVoice = true
            let nav1 = UINavigationController.init(rootViewController: obj)
            self.present(nav1, animated: true, completion: nil)
        }
        else if isFailerPayInVoicePayment {
            
        }
    }
    
    func fetchingGroupsFailedWithError(_ error: Error, url: URL) {
        self.mSpinner.stopAnimating()
        if isViewProfile {
            isViewProfile = false
            let error1 = error as NSError
            let errorString = error1.localizedDescription
            let alert = UIAlertController(title: errorString.capitalized, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{
                (ACTION :UIAlertAction!)in
                print("User click Ok button")
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if isGetHashForPayU {
            isGetHashForPayU = false
            print(error)
            let error1 = error as NSError
            let errorString = error1.localizedDescription
            let alert = UIAlertController(title: errorString.capitalized, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{
                (ACTION :UIAlertAction!)in
                print("User click Ok button")
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if isSuccessPayment {
            isSuccessPayment = false
            print(error)
            let error1 = error as NSError
            let errorString = error1.localizedDescription
            let alert = UIAlertController(title: errorString.capitalized, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{
                (ACTION :UIAlertAction!)in
                print("User click Ok button")
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if isFailurePayment {
            isFailurePayment = false
            print(error)
            let error1 = error as NSError
            let errorString = error1.localizedDescription
            let alert = UIAlertController(title: errorString.capitalized, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{
                (ACTION :UIAlertAction!)in
                print("User click Ok button")
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func fetchingGroupsWithProgressBar(_ progressValue: Double, url: URL) {
        
    }
    
    func fetchingGroupsFailedWithStringError(_ titleMessage: String, errorMessage: String, json: Any, url: URL) {
        self.mSpinner.stopAnimating()
        if isFailurePayment {
            
        }
        if isFailerPayInVoicePayment {
            
        }
    }
    
//    func payUPaymentIntegrate() {
//        
//        //https://payu.herokuapp.com/get_hash
//        
//        let url = URL.init(string: "https://payu.herokuapp.com/get_hash")
//        
//        let orderNo = String(newOrderModel.order_no)
//        
//        let orderDict: [String : String] = [
//            
//            "key" : KEY,
//            "txnid" : orderNo,
//            "amount" : newOrderModel.amount,
//            "productinfo" : newOrderModel.productinfo,
//            "firstname" : "hims",
//            "email" : "himanshu@gmail.com",
//            "udf1" : "",
//            "udf2" : "",
//            "udf3" : "",
//            "udf4" : "",
//            "udf5":"",
//            "Salt":ID
//        ]
//        
//        isGetHashForPayU = true
//        
//        networkService.delegate = self
//        
//        networkService.makePayementOptionCall(method: .post, headers: orderDict, url:url!)
//    }
//    
//    func payUPaymentWebView() {
//        
//        
//        let restURL = URL(string:PAYU_PAYMENT_MOBILETEST_URL) //PAYU_PAYMENT_TEST_URL
//        
//    
//        //restURL = [NSURL URLWithString:@"https://secure.payu.in/_payment"];
//        
//        let req = NSMutableURLRequest(url: restURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
//        req.httpMethod = "POST"
//        /* Format to generate hash Value
//         hashValue = @"key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT";
//         */
//        let orderNo = String(newOrderModel.order_no)
//        
//        let postData = "key=\(KEY)&email=\("himanshu@gmail.com")&amount=\(newOrderModel.amount)&firstname=\("hims")&txnid=\(orderNo)&user_credentials=\("DEFAULT")&productinfo=\(newOrderModel.productinfo)&phone=\("4324234523")&surl=\(SURL)&furl=\(FURL)&offer_key=\(OFFERKEY)&hash=\(paymentHash)"
//        
//        print("Post Data = \(postData)")
//        
//        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        req.httpBody = postData.data(using: String.Encoding.utf8)
//        
//        do{
//            let webVC = try PUCBWebVC.init(nsurlRequest:req as URLRequest! , merchantKey: KEY)  //(postParam:postData , url: restURL, merchantKey: KEY)
//            webVC.cbWebVCDelegate = self
//            self.navigationController?.pushViewController(webVC, animated: true)
//        }
//        catch {
//            print(error)
//        }
////        let PVC = self.mStoryboard.instantiateViewController(withIdentifier: "Web") as! WebScreen
////        PVC.req = req
////        self.navigationController?.pushViewController(PVC, animated: true)
//    }
//    
//    /*!
//     * This method gets called when transaction is successfull. It logs txn_success event.
//     * @param [response]            [id type]
//     */
//    public func payUSuccessResponse(_ response: Any!) {
//        print("Sresponse \(response)")
//    }
//    
//    /*!
//     * This method gets called when transaction fails. It logs txn_fail event.
//     * @param [response]            [id type]
//     */
//    public func payUFailureResponse(_ response: Any!) {
//        print("Fresponse \(response)")
//    }
//    
//    /*!
//     * This method gets called in case of network error
//     * @param [notification]            [NSDictionary type]
//     */
//    public func payUConnectionError(_ notification: [AnyHashable : Any]!) {
//        print("notification \(notification)")
//    }
//    
//    
//    /*!
//     * This method gets called in case of transaction is cancelled by Back press
//     */
//    public func payUTransactionCancel() {
//        print("cancel")
//    }
//    
//    public func payUSuccessResponse(_ payUResponse: Any!, surlResponse: Any!) {
//        print("payUResponse \(payUResponse) && surlResponse \(surlResponse)")
//    }
//    
//    
//    public func payUFailureResponse(_ payUResponse: Any!, furlResponse: Any!) {
//        print("payUResponse \(payUResponse) && furlResponse \(furlResponse)")
//    }
//
//    
//    
//    
//    func paytmPaymentIntegration() {
//        
//        let mc: PGMerchantConfiguration = PGMerchantConfiguration.default()
//        
//        //Step 2: If you have your own checksum generation and validation url set this here. Otherwise use the default Paytm urls
//        
//        mc.checksumGenerationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumGenerator.jsp"
//        mc.checksumValidationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumVerify.jsp"
//        
//        //Step 3: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
//        
//        let orderNo = String(newOrderModel.order_no)
//        
//        let orderDict: [String : String] = [
//            
//            "MID" : "WorldP64425807474247",
//            "CHANNEL_ID" : "WAP",
//            "INDUSTRY_TYPE_ID" : "Retail",
//            "WEBSITE" : "worldpressplg",
//            "TXN_AMOUNT" : newOrderModel.amount,
//            "ORDER_ID" : orderNo,
//            "REQUEST_TYPE" : "DEFAULT",
//            "CUST_ID" : "1234567890"
//        ]
//        
//        let order: PGOrder = PGOrder(params: orderDict)
//        
//        //Step 4: Choose the PG server. In your production build dont call selectServerDialog. Just create a instance of the
//        //PGTransactionViewController and set the serverType to eServerTypeProduction
//        PGServerEnvironment.selectServerDialog(self.view, completionHandler: {(type: ServerType) -> Void in
//            
//            let txnController = PGTransactionViewController.init(transactionFor: order)
//            
//            if type != eServerTypeNone {
//                txnController?.serverType = type
//                txnController?.merchant = mc
//                txnController?.delegate = self
//                self.navigationController?.pushViewController(txnController!, animated: true)
//            }
//        })
//    }
//    
//    // MARK: Delegate methods of Payment SDK.
//    func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
//        
//        // After Successful Payment
//        print("ViewController::didSucceedTransactionresponse= %@", response)
//        let msg: String = "Your order was completed successfully.\n Rs. \(response["TXN_AMOUNT"]!)"
//        
//        
//        print(msg)
//    }
//    
//    func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
//        // Called when Transation is Failed
//        //print("ViewController::didFailTransaction error = %@ response= %@", error, response)
//    }
//    
//    func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
//        //Cal when Process is Canceled
//        var msg: String = ""
//        
//        if error != nil {
//            
//            msg = String(format: "Successful")
//        }
//        else {
//            msg = String(format: "UnSuccessful")
//        }
//        print(msg)
//        
//        controller.navigationController?.popViewController(animated: true)
//    }
//    
//    func receivedGroupsJSON(_ json: Any, url: URL) {
//        if isGetHashForPayU {
//            isGetHashForPayU = false
//            if (json as AnyObject).value(forKey: "payment_hash") != nil {
//                self.paymentHash = (json as AnyObject).value(forKey: "payment_hash") as! String
//                
//                self.payUPaymentWebView()
//            }
//        }
//    }
//    
//    func fetchingGroupsFailedWithError(_ error: Error, url: URL) {
//        self.mSpinner.stopAnimating()
//        if isGetHashForPayU {
//            isGetHashForPayU = false
//            print(error)
//            let error1 = error as NSError
//            let errorString = error1.localizedDescription
//            let alert = UIAlertController(title: errorString.capitalized, message: "", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{
//                (ACTION :UIAlertAction!)in
//                print("User click Ok button")
//                
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//    
//    func fetchingGroupsWithProgressBar(_ progressValue: Double, url: URL) {
//        
//    }
//    
//    func fetchingGroupsFailedWithStringError(_ titleMessage: String, errorMessage: String, json: Any, url: URL) {
//        
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
