import Foundation

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Custom operators

 In Swift the operator is a method / function. And you have to treat it that way. If you want a operator that will create a sum of two vector, you can do it like this:
 */

func + (lhs: [Int], rhs: [Int]) -> [Int] {
    assert(lhs.count == rhs.count, "You can add only vectors of the same length")
    return zip(lhs, rhs).map { $0 + $1 }
}

print([1, 2, 3] + [2, 3, 4])
//print([1, 2] + [1, 2, 3]) // Assertion failed

/*:
 As you can see custom operators can do pretty much everything. As you probably remember from the school each operator has associativity and precedence. These two basic attributes are also applied to custom operators.

 * **Associativity** defines the order in which same operators should be applied.
 * **Precedence** defines the order of different operators in which they should be applied.

 Swift has also a special attribute **assignment** which defines the behavior of the operator when it's used in with the with optional chain (example below).

 All these attributes together define `precedencegroup`. And every operator has to be in some `precedencegroup`.

 In Swift there are 4 types of operators:

 * prefix: `++a`
 * postfix: `a++`
 * infix: `a + b`
 * ternary: `a ? b : c`

 Your custom operator can be of any of those types.

 Let's start with some basic custom operators. We'll create two operators - post increment and pre increment. The implementation is very simple.
 */

postfix operator ++

@discardableResult
postfix func ++ (variable: inout Int) -> Int {
    let value = variable
    variable += 1
    return value
}

var i = 0
print(i)
print(i++)
print(i)

// -----

prefix operator ++

@discardableResult
prefix func ++ (variable: inout Int) -> Int {
    variable += 1
    return variable
}

i = 1
print(i)
print(++i)
print(i)

/*:
 As you can see defining your own operator is very easy and can solve you many problem. But bare in mind that you always should prefer code's readability. Creating operator for every function is not the right way to take.

 Now we'll try to explain the meaning of the `assignment` attribute. The best way of explaining it would be an example, let's write one. We'll start by creating two `precedencegroup`s, one with `assignment` set to `false` and one with `assignment` set to `true`.
 */

precedencegroup AssignmentFalsePrecedence {
    assignment: false
}

precedencegroup AssignmentTruePrecedence {
    assignment: true
}

/*:
 Now we'll create two operators each from one `precedencegroup`.
 */

infix operator ++=: AssignmentFalsePrecedence
infix operator ++==: AssignmentTruePrecedence

func ++= (lhs: inout Int, value: Int) {
    lhs += value
}

func ++== (lhs: inout Int, value: Int) {
    lhs += value
}

/*:
 The main difference between these two `precedencegroup`s is how they behave when the operator is used in optional chain. This means that the operator is used with the left side being optional. In that case we can specify if the operator should behave like assignment operator (`assignment: true`) or not (`assignment: false`). If we choose the operator to behave like assignment operator the left side (optional chain) has higher precedence and if the value on the left side is nil our operator will not be executed.

 The following example should bring more light to the problem.
 */

class Test {
    var i = 0
}

let test: Test? = Test()
//test?.i ++= 1 // assignment: false
test?.i ++== 1 // assignment: true

/*:
 The first line
 ```
 test?.i ++= 1
 ```
 where the operator is not behaving like assignment operator is going to fail. Because in that case we're executing the operator on optional type on which our operator is not defined.

 The latter case is not going to crash because at first the left side is evaluated and if the left side is not nil the operator is called with the unwrapped value.

 We will finish this section with an operator that is more from the real world. Let's say that you have some optional value and you want to set this value to the dictionary but only if the value is not nil. We'll create a conditional assigment for it and we have to create its `precedencegroup`.

 All system precedence groups can be found here: https://developer.apple.com/documentation/swift/swift_standard_library/operator_declarations
 */

precedencegroup ConditionalAssignmentOperatorPrecedence {
    associativity: left
    assignment: true
    higherThan: AssignmentPrecedence
}

// Assign the operator to its precedencegroup
infix operator =?: ConditionalAssignmentOperatorPrecedence

func =? <T>(variable: inout T, value: T?) {
    guard let value = value else { return }
    variable = value
}

var data: [String: Any] = [:]
data["a"] =? "a"
data["b"] =? "b"
data["b"] =? nil
data["c"] =? nil
print(data)

//: [Next](@next)
