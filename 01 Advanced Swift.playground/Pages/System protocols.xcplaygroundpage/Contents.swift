import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # System protocols

 In the previous section we saw the `Equatable` protocol. But that's not the only protocol in Swift. There is much more.

 In this secton we'll see some of them. Personally these are the most used during the development.

 Let's start by defining a new model for this section.
 */

struct Engine {
    let size: Double
    let horsePower: Int
}

struct Car {
    let licensePlate: String
    let brand: String
    let model: String
    let price: Int
    let engine: Engine
}

let car = Car(licensePlate: "ABC", brand: "VW", model: "Golf", price: 100, engine: Engine(size: 2.0, horsePower: 300))

/*:
 ## Equatable

 This protocol defines an equality relation between a set of objects. When your type conforms to this protocol then you are able for example to search through a collection of those types.
 */
extension Car: Equatable {
    static func == (lhs: Car, rhs: Car) -> Bool {
        lhs.licensePlate == rhs.licensePlate
    }
}

/*:
 ## Hashable

 When the array is not enough and you want something more powerful you can use `Set`. `Set` can store elements which conform to the protocol `Hashable`. With `Hashable` you provide a logic for computing the `hashValue` of your object. The only requirement of this protocol is the following method
 ```
 func hash(into hasher: inout Hasher)
 ```
 In the `Hasher` you can combine all `Hashable` properties of you object which should create a stronger hash. But in real world application only the identifier of the object can be enough.

 If you look at the definition of `Hashable` you can see that it conforms to the `Equatable` protocol. This is very common pattern in Swift. Many system protocols conforms to another system protocols. With this hierarchy system you can implememt only one method from the `Hashable` protocol and you can be sure that you can use search methods on a collection of your objects, just like with `Equatable` protocol.
 */
extension Car: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(licensePlate)
        hasher.combine(brand)
        hasher.combine(model)
        hasher.combine(price)
        hasher.combine(engine.size)
        hasher.combine(engine.horsePower)
    }
}

/*:
 ## Comparable

 Another very common protocol is `Comparable`. With this protocol you can define sorting order for your type. Just implement
 ```
 static func < (lhs: Self, rhs: Self) -> Bool
 ```
 and that's it.
 */
extension Car: Comparable {
    static func < (lhs: Car, rhs: Car) -> Bool {
        lhs.price < rhs.price
    }
}

/*:
 ## CustomStringConvertible, CustomDebugStringConvertible

 In some cases you need to convert your object to the `String` and pass it somewhere, e.g. to the label. Swift has a built-in protocol for it named `CustomStringConvertible`. Its only requirement is
 ```
 var description: String { get }
 ```
 Now when you try to print the instance of your object you will see the value from the `description` property.

 Same goes for the `CustomDebugStringConvertible` which is used for debugging purposes. The requirement there is property `debugDescription`.
 */
extension Car: CustomStringConvertible {
    var description: String {
        "\(brand) \(model) (\(engine.size), \(engine.horsePower) hp)"
    }
}

print(car) // No need to use `description` property directly

/*:
 ## Codable

 `Codable` protocol is in the reality a composition of two protocols: `Encodable` and `Decodable`. These two protocols are responsible for encoding and decoding of the object. Basically everytime you try to communicate with some API you need this protocol to successfully and easily decode the server model.

 Both of them use `enum CodingKeys: CodingKey`. This enum specifies which mapping key should be translated to which property. When your model is identical to the server model, you have to just specify the conformance and everything is done automatically for you by the compiler.

 When the server model has different naming of its properties you have to implement `CodingKeys` on your own. Just list all your properties as cases of this enum and assign to each case its mapping key. The encoding / decoding method is still generated for you.

 If you need something custom during the decoding / encoding you have to implement the required methods on your own. At first you create the container in each method. The container is responsible for storing / loading the data. Then you create your custom logic and voilà.
 */

extension Car: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case licensePlate = "spz"
        case brand = "znacka"
        case model
        case price = "cena"
        case engine = "motor"
    }

    enum EngineCodingKeys: String, CodingKey {
        case size
        case horsePower = "hp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        licensePlate = try container.decode(String.self, forKey: .licensePlate)
        brand = try container.decode(String.self, forKey: .brand)
        model = try container.decode(String.self, forKey: .model)
        price = try container.decode(Int.self, forKey: .price)

        let engineContainer = try container.nestedContainer(keyedBy: EngineCodingKeys.self, forKey: .engine)
        let size = try engineContainer.decode(Double.self, forKey: .size)
        let horsePower = try engineContainer.decode(Int.self, forKey: .horsePower)
        engine = Engine(size: size, horsePower: horsePower)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(licensePlate, forKey: .licensePlate)
        try container.encode(brand, forKey: .brand)
        try container.encode(model, forKey: .model)
        try container.encode(price, forKey: .price)

        var engineContainer = container.nestedContainer(keyedBy: EngineCodingKeys.self, forKey: .engine)
        try engineContainer.encode(engine.size, forKey: .size)
        try engineContainer.encode(engine.horsePower, forKey: .horsePower)
    }
}

let data: [String: Any] = [
    "spz": "AHOJ",
    "znacka": "BMW",
    "model": "M3",
    "cena": 100000,
    "motor": [
        "size": 3.0,
        "hp": 400
    ]
]

let json = try! JSONSerialization.data(withJSONObject: data)
let decodedCar = try! JSONDecoder().decode(Car.self, from: json)
print(decodedCar)

/*:
 ## CaseIterable

 `CaseIterable` is very helpful protocol with which you can iterate over enum's cases. In the example above the enum `CodingKeys` is marked as `CaseIterable`. Now we can get all its cases as a collection. The order of the collection is given by the top-bottom order of those cases.
 */

Car.CodingKeys.allCases.forEach { print($0) }

/*:
 ## Identifiable

 `Identifable` protocol adds to the type its `id`, which can be anything `Hashable`.

 It's used in SwiftUI's `ForEach` to determine the changes between elements.
 */

struct SomeIdentifiable: Identifiable {
    let id: String
}

/*:
 If you need something custom during the decoding / encoding you have to implement the required methods on your own. At first you create the container in each method. The container is responsible for storing / loading the data. Then you create your custom logic and voilà.
 */

struct ImplicitID: Identifiable {
    let id = UUID()
}
 
//: [Next](@next)
