import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Generics

 Generics are one of the most powerful features in Swift. With generics you can define methods or types that can work with some type that is not known beforehand. You can use type constraints to have more control over your code. Generics are very handy in combination with protocols. You'll see.

 Let's start with very simple example.
 */

func swapInts(_ a: inout Int, _ b: inout Int) {
    let temp = a
    a = b
    b = temp
}

func swapDoubles(_ a: inout Double, _ b: inout Double) {
    let temp = a
    a = b
    b = temp
}

var int1 = 0
var int2 = 1
print(int1, int2)
swapInts(&int1, &int2)
print(int1, int2)

var double1 = 10.0
var double2 = 20.0
print(double1, double2)
swapDoubles(&double1, &double2)
print(double1, double2)

/*:
 It's working but it's not great. You can see that the implementation of those two methods is almost identical. The only difference is the type that is swapped. With generics we can create much nicer code that can handle swap of any type. */

func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

print(int1, int2)
swapValues(&int1, &int2)
print(int1, int2)

print(double1, double2)
swapValues(&double1, &double2)
print(double1, double2)

/*:
 See, Generics is your friend.

 You can also have generic types. The idea is the same, you can create a type that depends on some type that is not known beforehand.
 */

class OrderedSet<Element> where Element: Hashable {
    var count: Int { items.count }

    private var items = NSMutableOrderedSet()

    func add(_ item: Element) {
        items.add(item)
    }

    func remove(_ item: Element) {
        items.remove(item)
    }
}

let set = OrderedSet<String>()
set.add("Michal")
print(set.count)
set.remove("Michal")
print(set.count)

/*:
 Enum is also a type. When it makes sense you can also have the enum generic.
 */

enum CustomResult<Value, Failure> {
    case value(Value)
    case failure(Failure)
}

/*:
 Many of system types are generic. For example `Array` or `Result`, when you are working with CoreData you should use `NSFetchResultsController` which is also generic any many other.
 */

//: [Next](@next)
