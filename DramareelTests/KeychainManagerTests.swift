import XCTest
@testable import Dramareel

final class KeychainManagerTests: XCTestCase {
    
    let testKey = "dramareel.unit_test_key"
    let testValue = "secure_token_secret_value_12345"
    
    override func tearDown() {
        super.tearDown()
        KeychainManager.shared.delete(key: testKey)
    }
    
    func testKeychainSaveAndRetrieve() {
        let saved = KeychainManager.shared.save(key: testKey, value: testValue)
        XCTAssertTrue(saved, "Failed to save secret to Keychain")
        
        let retrieved = KeychainManager.shared.get(key: testKey)
        XCTAssertEqual(retrieved, testValue, "Retrieved value does not match saved value")
    }
    
    func testKeychainOverwrite() {
        _ = KeychainManager.shared.save(key: testKey, value: "first_value")
        let updated = KeychainManager.shared.save(key: testKey, value: "second_value")
        XCTAssertTrue(updated, "Failed to update existing Keychain entry")
        
        let retrieved = KeychainManager.shared.get(key: testKey)
        XCTAssertEqual(retrieved, "second_value", "Overwritten value does not match")
    }
    
    func testKeychainDelete() {
        _ = KeychainManager.shared.save(key: testKey, value: testValue)
        let deleted = KeychainManager.shared.delete(key: testKey)
        XCTAssertTrue(deleted, "Failed to delete key from Keychain")
        
        let retrieved = KeychainManager.shared.get(key: testKey)
        XCTAssertNil(retrieved, "Value still present after deletion")
    }
}
