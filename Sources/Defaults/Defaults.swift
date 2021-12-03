//
//  Defaults.swift
//  Defaults
//
//  Created by mikun on 2019/9/24.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import Foundation

@_disfavoredOverload
func isUserDefaultsSupportTypes(_ value: Any) -> Bool {
	switch value {
	case
		is Bool,
		is String,
		is Data,
		is URL
		: return true
	case
		is ObjCBool,
		is NSNumber,
		is NSString,
		is NSData,
		is NSURL:
			return true
	case let array as NSArray:
		return array.allSatisfy(isUserDefaultsSupportTypes(_:))
	case let dict as NSDictionary:
		return dict.allKeys.allSatisfy(isUserDefaultsSupportTypes(_:)) && dict.allValues.allSatisfy(isUserDefaultsSupportTypes(_:))
	default:
		return false
	}
}

func isUserDefaultsSupportTypes<Value>(_ value: Value) -> Bool where Value: FixedWidthInteger {
	return true
}

func isUserDefaultsSupportTypes<Value>(_ value: Value) -> Bool where Value: BinaryFloatingPoint {
	return true
}

public struct Defaults {
	public struct Keys { }
	
	public static var prefix = ""
	
	public static var defaults = UserDefaults.standard

	@_disfavoredOverload
	public static subscript<Key>(_ key: Key) -> Any? where Key: RawRepresentable, Key.RawValue == String {
		get {
			fatalError("Please define a Codable like, for example: Defaults[key] as Int")
		}
		set {
			if newValue == nil {
				removeObject(forKey: key)
			} else {
				fatalError("please set a codable object")
			}
		}
    }
	public static subscript<Key, Value>(_ key: Key, default defaultValue: Value) -> Value where Key: RawRepresentable, Key.RawValue == String, Value: Codable {
        return self[key] as Value? ?? defaultValue
    }
	public static subscript<Key, Value>(_ key: Key) -> Value? where Key: RawRepresentable, Key.RawValue == String, Value: Codable {
        get {
            let value = defaults.object(forKey: key.keyValue)
			if let result = value as? Value {
				return result
			}
			if
				let data = value as? Data,
				let result = try? JSONDecoder().decode(Value.self, from: data) {
				return result
			}
			return nil
        }
        set {
            guard let value = newValue else {
                removeObject(forKey: key)
                return
            }
			if isUserDefaultsSupportTypes(value) {
				defaults.set(newValue, forKey: key.keyValue)
			} else if let value = try? JSONEncoder().encode(value) {
				defaults.set(value, forKey: key.keyValue)
				defaults.synchronize()
			}
        }
    }
	
	public static func removeObject<Key>(forKey key: Key) where Key: RawRepresentable, Key.RawValue == String {
		defaults.removeObject(forKey: key.keyValue)
		defaults.synchronize()
	}
}
extension Defaults {
	@inlinable public static subscript<Key>(bool key: Key) -> Bool where Key: RawRepresentable, Key.RawValue == String {
		get {
			Self[key, default: false]
		}
		set {
			Self[key] = newValue
		}
    }

	@inlinable public static subscript<Key>(int key: Key) -> Int where Key: RawRepresentable, Key.RawValue == String {
		get {
			Self[key, default: 0]
		}
		set {
			Self[key] = newValue
		}
	}
	
	@inlinable public static subscript<Key>(string key: Key) -> String where Key: RawRepresentable, Key.RawValue == String {
		get {
			Self[key, default: ""]
		}
		set {
			Self[key] = newValue
		}
    }
	@inlinable public static subscript<Key>(date key: Key) -> Date? where Key: RawRepresentable, Key.RawValue == String {
		get {
			Self[key]
		}
		set {
			Self[key] = newValue
		}
	}
	@inlinable public static subscript<Key>(array key: Key) -> [Any] where Key: RawRepresentable, Key.RawValue == String {
		get {
			let obj = defaults.object(forKey: key.keyValue)
			if let data = obj as? Data, let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
				return array
			}
			return obj as? [Any] ?? []
		}
		set {
			defaults.set(newValue, forKey: key.keyValue)
		}
    }
	
	@inlinable public static subscript<Key, Value>(dic key: Key) -> [String: Value] where Key: RawRepresentable, Key.RawValue == String, Value: Codable {
		get {
			let dic = defaults.object(forKey: key.keyValue) as? [String: Any] ?? [:]
			return dic.compactMapValues {
				if let value = $0 as? Value {
					return value
				}
				if let data = $0 as? Data, let value = try? JSONDecoder().decode(Value.self, from: data) {
					return value
				}
				return nil
			}
		}
		set {
			var dic = defaults.object(forKey: key.keyValue) as? [String: Any] ?? newValue
			dic.merge(newValue) { $1 }
			defaults.set(dic, forKey: key.keyValue)
		}
    }
}

extension Defaults {
	public struct CustomKey: RawRepresentable {
		public let rawValue: String
		let prefix: String
		
		public init?(rawValue: String) {
			self.rawValue = rawValue
			prefix = ""
		}
		
		public init(_ userDefaultkey: String, prefix: String = Defaults.prefix) {
			rawValue = userDefaultkey
			self.prefix = prefix
		}
	}
}

extension RawRepresentable where RawValue == String {
	@usableFromInline
	var keyValue: String {
		var prefixKey: String
		if let customKey = self as? Defaults.CustomKey {
			prefixKey = customKey.prefix
		} else {
			prefixKey = Defaults.prefix
		}
		if prefixKey.isEmpty {
			return rawValue
		} else {
			return "\(prefixKey).\(rawValue)"
		}
	}
}

extension Dictionary where Key == String {
	@inlinable public subscript<Key>(key: Key) -> Value?  where Key: RawRepresentable, Key.RawValue == String {
		get {
			self[key.rawValue]
		}
		set {
			self[key.rawValue] = newValue
		}
	}
	@inlinable public subscript<Key>(key: Key, default defaultValue: @autoclosure () -> Value) -> Value where Key: RawRepresentable, Key.RawValue == String {
		if let value = self[key.rawValue] {
			return value
		} else {
			return defaultValue()
		}
	}
}
