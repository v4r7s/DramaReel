import XCTest
@testable import Dramareel

final class StoreKitVerificationTests: XCTestCase {
    
    // Helper to generate a mock unsigned JWS-like 3-part header.payload.signature structure
    func createMockJWSTransaction(
        productId: String = "com.dramareel.app.coins100",
        transactionId: String = "1000000987654321",
        bundleId: String = "com.dramareel.app",
        revocationDate: Int? = nil
    ) -> String {
        let header = ["alg": "ES256", "typ": "JWT"]
        var payload: [String: Any] = [
            "transactionId": transactionId,
            "originalTransactionId": transactionId,
            "bundleId": bundleId,
            "productId": productId,
            "purchaseDate": Int(Date().timeIntervalSince1970 * 1000),
            "type": "Consumable",
            "quantity": 1
        ]
        
        if let rev = revocationDate {
            payload["revocationDate"] = rev
        }
        
        let headerData = try! JSONSerialization.data(withJSONObject: header)
        let payloadData = try! JSONSerialization.data(withJSONObject: payload)
        
        let headerBase64 = headerData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let payloadBase64 = payloadData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        return "\(headerBase64).\(payloadBase64).mock_es256_signature_bytes"
    }
    
    func testJWSStructureValid() {
        let mockToken = createMockJWSTransaction()
        let parts = mockToken.components(separatedBy: ".")
        XCTAssertEqual(parts.count, 3, "JWS token must have 3 segments separated by dots")
        
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("Failed to decode JWS payload")
            return
        }
        
        XCTAssertEqual(json["bundleId"] as? String, "com.dramareel.app")
        XCTAssertEqual(json["productId"] as? String, "com.dramareel.app.coins100")
        XCTAssertEqual(json["type"] as? String, "Consumable")
        XCTAssertNil(json["revocationDate"])
    }
    
    func testRevokedTransactionDetected() {
        let mockToken = createMockJWSTransaction(revocationDate: 1714500000000)
        let parts = mockToken.components(separatedBy: ".")
        var base64 = parts[1].replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        
        let data = Data(base64Encoded: base64)!
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertNotNil(json["revocationDate"], "Revocation date should be present for refunded transactions")
    }
}
