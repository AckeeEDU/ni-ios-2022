import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Protocol oriented programming

 The protocol oriented programming is relatively new programming paradigm used in Swift. Protocols should be seen as a headers or interfaces but not as base classes. The protocol has some requirements which then have to be implement by the concrete types. We can also add functionality to the protocol. That is called protocol extension.
 */

protocol Person {
    var firstName: String { get }
    var surname: String { get }
}

// We can create a simple extension that will add `fullName` property to the `Person` protocol
extension Person {
    var fullName: String {
        firstName + " " + surname
    }
}

// Let's create two simple structs that implement the `Person` protocol
struct Michal: Person {
    var firstName: String { "Michal" }
    var surname: String { "Novák" }
}

struct Petr: Person {
    var firstName: String { "Petr" }
    var surname: String { "Ujčík" }
}

let michal = Michal()
let petr = Petr()

print(michal.fullName)
print(petr.fullName)

let array: [Person] = [michal, petr]
array.forEach { print($0.fullName) }

//: [Next](@next)
