import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Requirement vs extension

 Let's define another extension of our protocol and inside it we'll create a simple method `sayHi` that will return the person's greeting.
 */

protocol Person {
    var firstName: String { get }
    var surname: String { get }
}

extension Person {
    var fullName: String { firstName + " " + surname }

    func sayHi() -> String {
        "Hi"
    }
}

struct Michal: Person {
    var firstName: String { "Michal" }
    var surname: String { "Novák" }
}

extension Michal {
    func sayHi() -> String {
        "Hello, my name is " + fullName
    }
}

struct Petr: Person {
    var firstName: String { "Petr" }
    var surname: String { "Ujčík" }
}

extension Petr {
    func sayHi() -> String {
        "Hi everybody!"
    }
}

let michal = Michal()
let petr = Petr()

print(michal.sayHi())
print(petr.sayHi())

let array: [Person] = [Michal(), Petr()]
array.forEach { print($0.sayHi())}

/*:
 As you can see the output depends on the type on which the method is called. This behavior can cause a lot of problems during the development. If we want the method in the protocol extension to be the default implementation and let concrete types to implement their own logic inside it we have to specify the method as a **protocol requirement**.

 Let's reuse the example above and add the method as a protocol requirement.
 */

protocol BetterPerson {
    var firstName: String { get }
    var surname: String { get }

    func sayHi() -> String // Here is the method that was missing in the first exmaple
}

extension BetterPerson {
    var fullName: String { firstName + " " + surname }

    func sayHi() -> String { "Hi" }
}

struct BetterMichal: BetterPerson {
    var firstName: String { "Michal" }
    var surname: String { "Novák" }
}

extension BetterMichal {
    func sayHi() -> String {
        "Hello, my name is " + fullName
    }
}

struct BetterPetr: BetterPerson {
    var firstName: String { "Petr" }
    var surname: String { "Ujčík" }
}

extension BetterPetr {
    func sayHi() -> String {
        "Hi everybody!"
    }
}

let betterMichal = BetterMichal()
let betterPetr = BetterPetr()

print(betterMichal.sayHi())
print(betterPetr.sayHi())

let array2: [BetterPerson] = [betterMichal, betterPetr]
array2.forEach { print($0.sayHi())}

/*:
 The updated code looks pretty much the same as the one above. The only difference is that there is a new method in the `BetterPerson` protocol definition which tells the compiler that the concrete type can have its own implementation and that it should use the method in the procotol extension as a default.
 */

//: [Next](@next)
