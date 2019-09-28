//
//  DefaultsTests.swift
//  DefaultsTests
//
//  Created by mikun on 2019/9/28.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import XCTest
extension Defaults.Keys {
	enum Test: String {
		case enumKey
		case dicSubKey1
		case dicSubKey2
	}
	static let customKey = Defaults.CustomKey("CustomKey", prefix: "CustomKeyPrefix")
}

class DefaultsTests: XCTestCase {
	func removeUserDefault() {
		let userDefaults = UserDefaults.standard
		let dics = userDefaults.dictionaryRepresentation()
		for key in dics {
			userDefaults.removeObject(forKey: key.key)
		}
		userDefaults.synchronize()
	}
	
    func testSubscript() {
		removeUserDefault()
		XCTAssertFalse(Defaults[bool: Defaults.Keys.Test.enumKey])
		Defaults[Defaults.Keys.Test.enumKey] = true
		XCTAssertTrue(Defaults[bool: Defaults.Keys.Test.enumKey])
		removeUserDefault()
		
		XCTAssertEqual(Defaults[string: Defaults.Keys.Test.enumKey], "")
		Defaults[Defaults.Keys.Test.enumKey] = "TestString"
		XCTAssertEqual(Defaults[string: Defaults.Keys.Test.enumKey], "TestString")
		removeUserDefault()
		
		let date = Date()
		XCTAssertNil(Defaults[date: Defaults.Keys.Test.enumKey])
		Defaults[Defaults.Keys.Test.enumKey] = date
		XCTAssertEqual(Defaults[date: Defaults.Keys.Test.enumKey], date)
		removeUserDefault()
		
		
		XCTAssertEqual(Defaults[array: Defaults.Keys.Test.enumKey].count, 0)
		Defaults[Defaults.Keys.Test.enumKey] = [1, 2, 3]
		Defaults[array: Defaults.Keys.Test.enumKey].append(4)
		if let array = Defaults[array: Defaults.Keys.Test.enumKey] as? [Int] {
			XCTAssertEqual(array, [1, 2, 3, 4])
		} else {
			XCTFail()
		}
		Defaults[array: Defaults.Keys.Test.enumKey].append(4)
		removeUserDefault()
		let defaultValue = Int.random(in: 0...100)
		XCTAssertEqual(Defaults[dic: Defaults.Keys.Test.enumKey][Defaults.Keys.Test.dicSubKey1.rawValue, default: defaultValue], defaultValue)
		Defaults[dic: Defaults.Keys.Test.enumKey][Defaults.Keys.Test.dicSubKey1.rawValue] = 256
		Defaults[dic: Defaults.Keys.Test.enumKey][Defaults.Keys.Test.dicSubKey2.rawValue] = "512"
		XCTAssertEqual(Defaults[dic: Defaults.Keys.Test.enumKey][Defaults.Keys.Test.dicSubKey1.rawValue, default: defaultValue], 256)
		XCTAssertEqual(Defaults[dic: Defaults.Keys.Test.enumKey][Defaults.Keys.Test.dicSubKey2.rawValue, default: ""], "512")
		removeUserDefault()
		let result = Defaults[Defaults.Keys.Test.enumKey]
		XCTAssertNil(result)
    }
	
    func testRemove() {
		removeUserDefault()
		Defaults[Defaults.Keys.Test.enumKey] = true
		Defaults[Defaults.Keys.Test.enumKey] = nil
		XCTAssertFalse(Defaults[bool: Defaults.Keys.Test.enumKey])
	}
	func testPrefix() {
		removeUserDefault()
		Defaults.prefix = "testPrefix1"
		Defaults[Defaults.Keys.Test.enumKey] = true
		XCTAssertTrue(Defaults.defaults.bool(forKey: "\(Defaults.prefix).\(Defaults.Keys.Test.enumKey.rawValue)"))
		
		Defaults[Defaults.Keys.customKey] = "912"
		XCTAssertTrue(Defaults.defaults.string(forKey: "\(Defaults.Keys.customKey.prefix).\(Defaults.Keys.customKey.rawValue)") == "912")
	}
}
