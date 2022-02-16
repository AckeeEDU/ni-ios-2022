import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Property wrappers

 Sometimes you need to do some additional work with the property - you need to format it, apply some rules, store it somewhere. But with simple property this cannot be done easily. Or it can be done easily but it's not general.

 For those situations Swift 5.1 introduces **property wrappers**.

 You can create a property wrapper that is class or struct, it has to have `@propertyWrapper` annotation and it should have property named `wrappedValue` that is inside that type.

 That is all you need to create a property wrapper. Let's start with something really simple. The first property will multiple each integer value by 10.
 */

@propertyWrapper
struct TenTimes {
    var wrappedValue: Int {
        didSet {
            wrappedValue *= 10
        }
    }

    init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue * 10
    }
}

// Property wrapper cannot be used on the top-level code. So we need to create some dummy class to use it.
class Test {
    @TenTimes
    var value = 10

    func run() {
        print(value)
        value = 100
        print(value)
    }
}

let test = Test()
test.run()

/*:
 Basic property wrapper is really simple. But since it's a class or struct you can defined your own properties inside the property wrappers and then use them.
 */

@propertyWrapper
struct Defaults<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value? {
        get {
            let value = UserDefaults.standard.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

class Test2 {
    @Defaults(key: "search-limit", defaultValue: 20)
    var searchLimit: Int?
}

let test2 = Test2()
print(test2.searchLimit)
test2.searchLimit = 10
print(test2.searchLimit)
print(UserDefaults.standard.value(forKey: "search-limit"))
UserDefaults.standard.set(100, forKey: "search-limit")
print(test2.searchLimit)
UserDefaults.standard.set("not-valid", forKey: "search-limit")
print(test2.searchLimit)

//: [Next](@next)
