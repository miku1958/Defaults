//
//  Defaults.swift
//  Defaults
//
//  Created by mikun on 2019/9/24.
//  Copyright © 2019 庄黛淳华. All rights reserved.
//

import Foundation

public struct Defaults {
	public struct Keys { }
	
	public static var prefix = ""
	
	public static var defaults = UserDefaults.standard
	
	public static subscript<Key, R>(_ key: Key) -> R? where Key: RawRepresentable, Key.RawValue == String {
		return defaults.object(forKey: key.keyValue) as? R
    }
	public static subscript<Key, R>(_ key: Key, default defaultValue: R) -> R where Key: RawRepresentable, Key.RawValue == String {
        return defaults.object(forKey: key.keyValue) as? R ?? defaultValue
    }
    public static subscript<Key>(_ key: Key) -> Any? where Key: RawRepresentable, Key.RawValue == String {
        get {
            return defaults.object(forKey: key.keyValue)
        }
        set {
            guard let newValue = newValue else {
                removeObject(forKey: key)
                return
            }
            defaults.set(newValue, forKey: key.keyValue)
            defaults.synchronize()
        }
    }
	
	public static func removeObject<Key>(forKey key: Key) where Key: RawRepresentable, Key.RawValue == String {
		defaults.removeObject(forKey: key.keyValue)
		defaults.synchronize()
	}
}
extension Defaults {
	public static subscript<Key>(bool key: Key) -> Bool where Key: RawRepresentable, Key.RawValue == String {
		return Self[key, default: false]
    }
	
	public static subscript<Key>(string key: Key) -> String where Key: RawRepresentable, Key.RawValue == String {
		return Self[key, default: ""]
    }
	public static subscript<Key>(date key: Key) -> Date? where Key: RawRepresentable, Key.RawValue == String {
		return Self[key]
    }
	public static subscript<Key>(array key: Key) -> [Any] where Key: RawRepresentable, Key.RawValue == String {
		get {
			return Self[key, default: [Any]()]
		}
		set {
			Self[key] = newValue
		}
    }
	
	public static subscript<Key, T>(dic key: Key) -> [String: T] where Key: RawRepresentable, Key.RawValue == String {
		get {
			let dic = Defaults[key] as? [String: Any] ?? [:]
			return dic.compactMapValues { $0 as? T }
		}
		set {
			var dic = Defaults[key] as? [String: Any] ?? newValue
			dic.merge(newValue) { $1 }
			Self[key] = dic
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
	fileprivate var keyValue: String {
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
