import UIKit

//: [Previous](@previous) | [Introduction](Introduction)

/*:
 # Generics + protocols

 On this page we'll see a real life example where Generics with protocol oriented programming is very great tool. We'll see a very nice solution to the registering and dequeueing of `UITableViewCell`s.

 We want each cell to be reusable, so we can reuse it somewhere inside our code. Let's start by defining `Reusable` protocol.
 */

protocol Reusable { }

/*:
 Nice! That wasn't so hard. Each reusable cell should have its own identifier.
 */

extension Reusable {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

/*:
 Done! Now we have `reuseIdentifier` for each type that conforms to the `Reusable` protocol. The last part is to conform `UITableViewCell` to the `Reusable` protocol.
 */

extension UITableViewCell: Reusable { }

/*:
 Bam! Each `UITableViewCell` now have its own `reuseIdentifier`. Let's see how the complete code looks like now.
 */

class CustomTableViewCell: UITableViewCell { }

let tableView = UITableView()
tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)

// ...

let indexPath = IndexPath(row: 0, section: 0)
let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as! CustomTableViewCell

/*:
 It's better than having all the identifiers defined as strings somewhere but still is too verbose. And there's the force cast... We can do better than this. Let's create an extension of `UITableView` which will handle the registration and the cell dequeue process.

 We'll create a method that will take only the `indexPath` parameter and the result type of that method will be inferred from the context. We need to use generics here.
 */

extension UITableView {
    func dequeueCell<Cell>(for indexPath: IndexPath) -> Cell where Cell: UITableViewCell {
        register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
}

/*:
 I know, I know... the force cast is still there but since we're using generics it's probably good idea to have the force cast here because if the cast would fail, we really want to know that.

 Also with each dequeue we are registering the cell again and again. It's not optimal but since the dequeuing has to be really fast due to frequent usage the implementation has to use some kind of hash table in which all the cells are registered. Hash table has a constant time complexity for the access. So with that knowledge (and with many years of usage) we can safely say that the registeration is done in constant time. So no pain here either.

 When we look at the final code of the example our code is very simple.
 */

let tableView2 = UITableView()

// No registration needed here
// ...

let indexPath2 = IndexPath(row: 0, section: 0)
let cell2: CustomTableViewCell = tableView2.dequeueCell(for: indexPath)

/*:
 Now the code is much cleaner and so much nicer. This is the way your code should look like when you're creating Swift applications.

 This example can be more extended to every reusable view in the UIKit / AppKit. You can try to extend it for the `UICollectionView`.
 */

//: [Next](@next)
