//
//  KeychainStorage.swift
//  KeychainStorage
//
//  Created by Oleksii Bailo on 10/4/24.
//

import Foundation
import Security


@objc(ACKeychainStorage)
public class ACKeychainStorage : NSObject {
    
    @objc(isKeyExist:isPublic:)
    public static func isKeyExist(keyName: String, isPublic: Bool) -> Bool {

        let existingKey = findKey(keyName: keyName, isPublic: isPublic)
        if existingKey != nil {
            return true
        }

        return false;
    }
    
    @objc(getKey:isPublic:)
    public static func getKey(tag: String, isPublic: Bool) -> Data {

        //Searching existing key
        let existingKey = findKey(keyName: tag, isPublic: isPublic)
        if existingKey != nil {
            return exportKey(secKey:existingKey!, isPublic:isPublic)
        }
        
        return Data()
    }
    
    @objc(createRSAKeyAnsStoreInkeychain:algorithm:keySize:isKeyPublic:keyUsage:overwrite:)
    public static func createRSAKeyAnsStoreInkeychain(tag: String, algorithm: String, keySize: Int, isPublic: Bool, keyUsage: Bool, overwrite: Bool) -> Data {

        let tagData = tag.data(using: .utf8)!
        var keyType = kSecAttrKeyTypeRSA;
        
        switch algorithm {
        case "rsa":
            print("RSA algorithm selected")
        case "ec":
            keyType = kSecAttrKeyTypeEC
            print("Elliptic Curve algorithm selected")
//        case "dsa":
//            keyType = kSecAttrKeyTypeDSA
//            print("DSA algorithm selected")
        default:
            print("Unknown algorithm")
            return Data()
            //throw KeychainError.customError("Unknown algorithm")
        }
        
        if (overwrite)
        {
            // Delete the existing key if it exists
            let deleteQuery: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: tagData
            ]
            SecItemDelete(deleteQuery as CFDictionary) // Ignore error if key doesn't exist
        }

        //Searching existing key
        let existingKey = findKey(keyName: tag, isPublic: isPublic)
        if existingKey != nil {
            return exportKey(secKey:existingKey!, isPublic:isPublic)
        }
        
        //Key not found, let's try create and store new one
        var attributes: [String: Any] = [
            kSecAttrKeyType as String: keyType,             // Key type (RSA, EC, etc.)
            kSecAttrKeySizeInBits as String: keySize,       // Key size
            kSecAttrLabel as String: tag,                   // Label for the key
            kSecAttrApplicationTag as String: tagData,      // Custom tag for identifying the key
            kSecAttrIsPermanent as String: true,            // Store the key permanently in the Keychain
        ]

        if !isPublic {
            //Private key attributes
            var privateKeyAttributes: [String: Any] = [
                kSecAttrIsPermanent as String: true,            // Store the key permanently in the Keychain
                kSecAttrApplicationTag as String: tagData,      // Custom tag for identifying the key
            ]

            if (keyUsage) {
                privateKeyAttributes[kSecAttrCanDecrypt as String] = true   // Specify decryption usage
            } else {
                privateKeyAttributes[kSecAttrCanSign as String] = true      // Specify usage for signing (if needed)
            }
            attributes[kSecPrivateKeyAttrs as String] = privateKeyAttributes
        }

        //Finally generate the key
        var error: Unmanaged<CFError>?
        guard let newKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Error generating key: \(error!.takeRetainedValue())")
            return Data()
        }
        
        return exportKey(secKey:newKey, isPublic:isPublic)
    }

    //
    static func findKey(keyName: String, isPublic: Bool) -> SecKey? {

        var keyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyName.data(using: .utf8)!,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        keyQuery[kSecAttrKeyClass as String] = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate;
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(keyQuery as CFDictionary, &item)
        if status == errSecSuccess {
            if let keyRef = item, CFGetTypeID(keyRef) == SecKeyGetTypeID() {
                return (keyRef as! SecKey)
            }
        }

        print("Key not found: \(status)")
        return nil;
    }

    static func exportKey(secKey: SecKey, isPublic: Bool) -> Data {
        // Export the key
        var error: Unmanaged<CFError>?
        if isPublic {
            guard let publicKey = SecKeyCopyPublicKey(secKey) else { return Data() }
            if let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) {
                return publicKeyData as Data
            }
        } else {
            if let privateKeyData = SecKeyCopyExternalRepresentation(secKey, &error) {
                return privateKeyData as Data
            }
        }

        print("Error exporting key: \(String(describing: error))")
        return Data()
    }
}
