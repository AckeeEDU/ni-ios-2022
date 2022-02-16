import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Protocol with Self requirement and associated types

 If we look closer at `Equatable` protocol we can see that protocol's requirement has the following definition:
 ```
 protocol Equatable {
     static func == (lhs: Self, rhs: Self) -> Bool
 }
 ```
 The method of this protocol has `Self` as an argument. The `Self` can be seen as a placeholder for a concrete type that implements this protocol. As a result the compiler will automatically insert there the correct type during the compilation.

 Same thing happens when the protocol has some associated type. The compiler will also insert there the correct type.

 But there is a downside with this approach. Since the compiler needs to have a concrete type for those "placeholders" we need to provide them to it. As a consequence we cannot use these protocols as type constraints when defining properties.

 In this example we will use again the `Person` model.
*/
protocol Person: Equatable {
    var name: String { get }
}

struct Michal: Person {
    let name = "Michal"
}

/*:
 Now we want to implement the `Equatable` protocol for types implementing `Person` protocol.
 */

// Does not compile
//extension Person {
//    static func == (lhs: Person, rhs: Person) -> Bool {
//        lhs.name == rhs.name
//    }
//}

/*:
 As you can see we got an error message saying that we can use protocol `Person` only as a generic constraint. In this case the compiler cannot infer the `Self` type from the `Equatable` protocol.

 Same goes for an array of `Person`s. If we use the `Database` protocol the result is going to be the same.
 */

//let array: [Person] = [Michal(), Michal()] // Does not compile

protocol Database {
    associatedtype Item

    var items: [Item] { get set }
}

struct NamesDatabase: Database {
    var items: [String] = []
}

//let dbs: [Database] = [NamesDatabase(), NamesDatabase()] // Does not compile

//: [Next](@next)
