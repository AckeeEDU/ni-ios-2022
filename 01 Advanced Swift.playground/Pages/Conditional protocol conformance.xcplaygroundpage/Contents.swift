import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Conditional protocol conformance and associated types

 In the next example we'll see how we can add methods and properties to types based on some other type. Also we'll see how to create a protocol which depends on some abstract type. This abstract type is called associated type and it will be specified by the concrete implementation. This type is used to make protocols generic - in other words you can use it with any type that satisfies type constraints.

 Let's start by reusing our Person model. For the sake of the example the model will be simpler.
 */

protocol Person {
    var name: String { get }
}

struct Michal: Person {
    let name = "Michal"
}

struct Petr: Person {
    let name = "Petr"
}

let michal = Michal()
let petr = Petr()

/*:
 Now let's create protocol that will represent some kind of storage / database.
 */

protocol Database {
    associatedtype Item // Created an associated type

    var items: [Item] { get set } // Associated type in action
}

extension Database {
    mutating func add(_ item: Item) {
        items.append(item)
    }
}

/*:
 `Database` protocol is very simple storage. It requires only an array to store all items.
 */

struct PeopleDatabase: Database {
    var items: [Person] = []
}

var peopleDB = PeopleDatabase()
peopleDB.add(michal)
peopleDB.add(petr)

peopleDB.items.forEach { print($0.name) }

/*:
 But how wants a database which can only accept new items. Let's create an extension of `Database` protocol which will add a constraint on the `Item` and by that we can add more functionality to the `Database`.
 */

extension Database where Item: Equatable {
    func indexOf(_ item: Item) -> Int? {
        items.firstIndex(of: item)
    }

    mutating func remove(_ item: Item) {
        guard let index = indexOf(item) else { return }
        items.remove(at: index)
    }

    func contains(_ item: Item) -> Bool {
        indexOf(item) != nil
    }
}

struct NameDatabase: Database {
    var items: [String] = []
}

var namesDB = NameDatabase()
namesDB.add("Michal")
namesDB.add("Petr")
namesDB.items.forEach { print($0) }
namesDB.remove("Michal")
namesDB.items.forEach { print($0) }

//peopleDB.remove(michal) // Does not compile

/*:
 Now we are able to remove item and check its existence in the database. The former database's item does not conform to `Equatable` protocol so we cannot use the new functionality with it.
 */

//: [Next](@next)
