//
//  SharedDataManager.swift
//  workout-regimen-manager
//
//  Created by Matthew Durcan on 8/7/23.
//

import Foundation

class SharedDataManager {
    static let shared = SharedDataManager()
    
    let sharedAppGroupIdentifier = "group.sharedGroupmjrd"
    let sharedUserDefaults: UserDefaults
    
    private var allKeys: [String] = []
    
    
    private init() {
        sharedUserDefaults = UserDefaults(suiteName: sharedAppGroupIdentifier)!
        if let savedKeys = sharedUserDefaults.array(forKey: "allKeys") as? [String] {
            allKeys = savedKeys
        }
    }
    
    func saveData(_ data: Any?, forKey key: String) {
        sharedUserDefaults.setValue(data, forKey: key)
        sharedUserDefaults.synchronize()
        
        if !allKeys.contains(key) {
            allKeys.append(key)
            sharedUserDefaults.set(allKeys, forKey: "allKeys")
            sharedUserDefaults.synchronize()
        }
    }
    
    func getData(forKey key: String) -> Any? {
        return sharedUserDefaults.value(forKey: key)
    }
    
    func keysEndingWithText() -> [String] {
        return allKeys.filter { $0.hasSuffix("Text") && !$0.hasPrefix("original") }
    }
    
    func returnAllKeys() -> [String] {
        return allKeys
    }
    
    func removeData(forKey key: String) {
        sharedUserDefaults.removeObject(forKey: key)
        if let index = allKeys.firstIndex(of: key) {
            allKeys.remove(at: index)
            sharedUserDefaults.set(allKeys, forKey: "allKeys")
            sharedUserDefaults.synchronize()
        }
    }
}
