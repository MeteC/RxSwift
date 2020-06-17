import Foundation
import RxSwift
import RxCocoa

import CryptoKit

func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
    
    return digest.map {
        String(format: "%02hhx", $0)
    }.joined()
}




var str = "Hello, playground"

var request = URLRequest(url: URL(string: "https://asign.cern.ch/register")!)
request.httpMethod = "POST"
request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
let key = MD5(string: "mete+mete")


/*
request.httpBody = try JSONSerialization.data(withJSONObject: ["username" : "mete12",
                                                               "password" : "mete",
                                                               "device"   : "iPhone",
                                                               "key"      : key,
                                                               "phone"    : "111222333"], 
                                              options: [.prettyPrinted])

print(String(data: request.httpBody!, encoding: .utf8))
*/
request.httpBody = "username=mete&password=mete&key=\(key)&device=Android&phone=0123".data(using: .utf8)

//let task =
//URLSession.shared.dataTask(with: request){ data, response, error in
//    print("$ resp \(response)")
//    print("$ data \(data)")
//    print("$ error \(error)")
//}
//
//
//task.resume()


// Rx
let ret = URLSession.shared.rx.data(request: request)

ret
.materialize()
//    .debug()
    .subscribe(onNext: { (event) in
        if let err = event.error as? RxCocoaURLError {
            print(".: \(err.debugDescription)")
            
            if case let RxCocoaURLError.httpRequestFailed(response, data) = err {
                print("resp: \(response)")
                let dataStr = String(data: data!, encoding: .utf8)
                print("data: \(dataStr)")
            }
        }
    })
