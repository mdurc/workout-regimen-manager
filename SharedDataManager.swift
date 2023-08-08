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
    
    private init() {
        sharedUserDefaults = UserDefaults(suiteName: sharedAppGroupIdentifier)!
    }
    
    func saveData(_ data: Any?, forKey key: String) {
        sharedUserDefaults.setValue(data, forKey: key)
        sharedUserDefaults.synchronize()
    }
    
    func getData(forKey key: String) -> Any? {
        return sharedUserDefaults.value(forKey: key)
    }
}
