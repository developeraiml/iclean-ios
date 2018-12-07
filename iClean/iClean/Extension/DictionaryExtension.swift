//
//  DictionaryExtension.swift
//  iClean
//
//  Created by Anand on 21/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import Foundation

extension Dictionary {
    func mergedWith(otherDictionary: [Key: Value]) -> [Key: Value] {
        var mergedDict: [Key: Value] = [:]
        [self, otherDictionary].forEach { dict in
            for (key, value) in dict {
                mergedDict[key] = value
            }
        }
        return mergedDict
    }
}
