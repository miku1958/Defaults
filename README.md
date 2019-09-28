# Defaults
*A swifter UserDefaults*



## Requirement

- Xcode 11(for using static and class subscripts)
- Swift5.0

## Usage

### Key:

```
extension Defaults.Keys { // It is not necessary, you can put these enum wherever you like
	enum Detail: String {
		case name
		case sign
		case isLogin
	}
}
```

### Store

```
Defaults[Defaults.Keys.Detail.isLogin] = true
```



#### BaseType

Including Bool, String, Date

#### Read

```
let bool = Defaults[bool: Defaults.Keys.Detail.isLogin] // default is false
or
let bool = Defaults[Defaults.Keys.Detail.isLogin] as? Bool ?? false
```



### Array

#### Read

```
let arr = Defaults[array: Defaults.Keys.Detail.name] as? [String]
```

#### Update

```
Defaults[array: Defaults.Keys.Detail.name].append("Joshua")
```



### Dictionary

```
extension Defaults.Keys {
	static let currentUser = Defaults.CustomKey(User.current.name, prefix: "User")
}
```

#### Read

```
let sign = Defaults[dic: Defaults.Keys.currentUser][Defaults.Keys.Detail.sign.rawValue, default:""]
or 
let sign = Defaults[dic: Defaults.Keys.currentUser][Defaults.Keys.Detail.sign.rawValue] ?? ""
```

#### Update

```
Defaults[dic: Defaults.Keys.currentUser][Defaults.Keys.Detail.sign.rawValue] = "I am batman"
Defaults[dic: Defaults.Keys.currentUser][Defaults.Keys.Detail.isLogin.rawValue] = true
```



### 
