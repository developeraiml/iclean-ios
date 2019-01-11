//
//  Created by YML on 16/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import UIKit


class ApiNetwork: NSObject, URLSessionDelegate {
    
    static let KErrorKey                           =  NSLocalizedDescriptionKey 

    let kGETHttpMethod = "GET"
    let kPOSTHttpMethod = "POST"
    let kPUTHttpMethod = "PUT"
    let kDELETEHttpMethod = "DELETE"


    let kJSONRequestValue = "application/json"
    let kContentTypeHeaderField = "Content-Type"
    let kContentLengthHeaderField = "Content-Length"
    let kAcceptHeaderField = "Accept"
    
    let KBaseUrl = "http://52.8.247.60:8000/"  //http://52.8.247.60:8000/user/signup/
    var baseUrl : URL?
    
    override init() {
        super.init()
        
        baseUrl = URL(string: KBaseUrl)
    }

    convenience init(urlString: String){
        self.init()
        baseUrl = URL(string: urlString)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - bodyDict: <#bodyDict description#>
    ///   - path: <#path description#>
    ///   - postCompleted: <#postCompleted description#>
    func post(_ bodyDict : [String: AnyObject]?, path : String,
              postCompleted : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void){
        var bodyDicts = bodyDict
        let appDel : AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        
        if appDel?.isNetworkAvailable() ==  false {
          
            let error : NSError = NSError(domain: "No Network", code: 404, userInfo: [ApiNetwork.KErrorKey : "No network found"])
            
            postCompleted(false, nil, error)
            return
        }
        
        
        let url = URL(string: path, relativeTo: baseUrl)
        
        var request = URLRequest(url: url!)
            
            //NSMutableURLRequest(url: url!)
        
        //Remove session delegate once ssl has been added to the domain

        
        let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        request.httpMethod = kPOSTHttpMethod
        request.timeoutInterval = 20.0
        
        if let _  = bodyDicts?["Token"] {
            if let tokenUpdated = (UserDefaults.standard.value(forKey: "Token")) {

               _ = bodyDicts?.updateValue((tokenUpdated as AnyObject?)!, forKey: "Token")

            }
            
        }
        
        do {
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDicts!, options: [])
        }catch let error as NSError {
           // print("json error: \(error)")
            postCompleted(false, nil, error)
            return
        }

        request.addValue(kJSONRequestValue, forHTTPHeaderField: kContentTypeHeaderField)
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kAcceptHeaderField)
       // request.addValue("staging", forHTTPHeaderField: "x-per-key")

        if let userToken =  UserDefaults.standard.object(forKey: "userToken") as? String {
            request.addValue(userToken, forHTTPHeaderField: "Token")
        }

        
        
        let task = session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) in
            
//            if data != nil {
//                let dataString = String(data: data!, encoding: String.Encoding.utf8)
//                
//                print(dataString)
//            }
           
            
           guard error == nil else {
            postCompleted(false, nil, error as NSError?)
            return
            }
           
            var json : [String:AnyObject]?
            do {
                
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                if let validJson = json {
                    postCompleted(true, validJson as [String: AnyObject]?, nil)
                }else {
                    postCompleted(false, nil, error as NSError?)
                }
                
            }catch let error as NSError {
                postCompleted(false, nil, error)
            }

        }) 
        
        task.resume()
    }
    
    
    func put(_ bodyDict : [String: AnyObject]?, path : String,
              postCompleted : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void){
        
        var bodyDicts = bodyDict
        let appDel : AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        if appDel?.isNetworkAvailable() ==  false {
            
            let error : NSError = NSError(domain: "No Network", code: 404, userInfo: [ApiNetwork.KErrorKey : "No network found"])
            
            postCompleted(false, nil, error)
            return
        }
        
        
        let url = URL(string: path, relativeTo: baseUrl)
        
        var request = URLRequest(url: url!)
        
        //NSMutableURLRequest(url: url!)
        
        //Remove session delegate once ssl has been added to the domain
        
        
        let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        request.httpMethod = kPUTHttpMethod
        request.timeoutInterval = 30.0
       
        if let _  = bodyDicts?["Token"] {
            if let tokenUpdated = (UserDefaults.standard.value(forKey: "Token")) {
                
                _ = bodyDicts?.updateValue((tokenUpdated as AnyObject?)!, forKey: "Token")
                
            }
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyDicts!, options: [])
        }catch let error as NSError {
            // print("json error: \(error)")
            postCompleted(false, nil, error)
            return
        }
        
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kContentTypeHeaderField)
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kAcceptHeaderField)
        // request.addValue("staging", forHTTPHeaderField: "x-per-key")
        
        
        if let userToken =  UserDefaults.standard.object(forKey: "userToken") as? String {
            request.addValue(userToken, forHTTPHeaderField: "Token")
        }
        
        
        
        let task = session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) in
            
//            let dataString = String(data: data!, encoding: String.Encoding.utf8)
//            
//            print(dataString)
            
            guard error == nil else {
                postCompleted(false, nil, error as NSError?)
                return
            }
            
            var json : [String:AnyObject]?
            do {
                
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                if let validJson = json {
                    postCompleted(true, validJson as [String: AnyObject]?, nil)
                }else {
                    postCompleted(false, nil, error as NSError?)
                }
                
            }catch let error as NSError {
                postCompleted(false, nil, error)
            }
            
        })
        
        task.resume()
    }
    
    
    func get(_ path : String,
             completed : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> ()){
        
        let appDel : AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        if appDel?.isNetworkAvailable() ==  false {
            
            let error : NSError = NSError(domain: "No Network", code: 404, userInfo: [ApiNetwork.KErrorKey : "No network found"])
            completed(false, nil, error)
            return
        }
        
        let url = URL(string: path, relativeTo: baseUrl)
        
        var request = URLRequest(url: url!)
        
        //Remove session delegate once ssl has been added to the domain
        
        let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        request.httpMethod = kGETHttpMethod
        request.timeoutInterval = 15.0
        
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kContentTypeHeaderField)
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kAcceptHeaderField)
      //  request.addValue("staging", forHTTPHeaderField: "x-per-key")
        if let userToken =  UserDefaults.standard.object(forKey: "userToken") as? String {
            request.addValue(userToken, forHTTPHeaderField: "Token")
        }


        let task = session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) in
            
            guard error == nil else {
                completed(false, nil, error as NSError?)
                return
            }
            
            var json : [String:AnyObject]?
            do {
                
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                
               // print(json)
                
                if let validJson = json {
                    completed(true, validJson as [String: AnyObject]?, nil)
                }else {
                    completed(false, nil, error as NSError?)

                }
                
            }catch let error as NSError {
                // failure
                // print("Fetch failed: \(error.localizedDescription)")
                completed(false, nil, error)
                
            }
            
        }) 
        
        task.resume()

        
    }
    
    func delete(_ path : String,
             completed : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> ()){
        
        let appDel : AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        if appDel?.isNetworkAvailable() ==  false {
            
            let error : NSError = NSError(domain: "No Network", code: 404, userInfo: [ApiNetwork.KErrorKey : "No network found"])
            completed(false, nil, error)
            return
        }
        
        let url = URL(string: path, relativeTo: baseUrl)
        
        var request = URLRequest(url: url!)
        
        //Remove session delegate once ssl has been added to the domain
        
        let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        request.httpMethod = kDELETEHttpMethod
        request.timeoutInterval = 30.0
        
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kContentTypeHeaderField)
        request.addValue(kJSONRequestValue, forHTTPHeaderField: kAcceptHeaderField)
        //  request.addValue("staging", forHTTPHeaderField: "x-per-key")
        if let userToken =  UserDefaults.standard.object(forKey: "userToken") as? String {
            request.addValue(userToken, forHTTPHeaderField: "Token")
        }
        
        
        let task = session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) in
            
            guard error == nil else {
                completed(false, nil, error as NSError?)
                return
            }
            
            var json : [String:AnyObject]?
            do {
                
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                
                // print(json)
                
                if let validJson = json {
                    completed(true, validJson as [String: AnyObject]?, nil)
                }else {
                    completed(false, nil, error as NSError?)
                    
                }
                
            }catch let error as NSError {
                // failure
                // print("Fetch failed: \(error.localizedDescription)")
                completed(false, nil, error)
                
            }
            
        })
        
        task.resume()
        
        
    }
    
    
    func getCurrentSession() -> Foundation.URLSession {
        
        return Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    func getBackgorundSession(_ identifier : String) -> Foundation.URLSession {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        
        return Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
    }
    
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//     
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            
//            if challenge.protectionSpace.host == "pasta.p-rosolutions.com" || challenge.protectionSpace.host == "69.160.85.30" {
//                
//                let localcredentials = URLCredential(trust: challenge.protectionSpace.serverTrust!)
//                completionHandler(.useCredential,localcredentials)
//            }
//        }
//    }
}
