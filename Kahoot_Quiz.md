# Pokedex App - Kahoot Quiz Questions

## Question 1: UITableView Cell Reuse
**What happens when you call `dequeueReusableCell(withIdentifier:for:)` on a UITableView?**

A) Creates a new cell every time
B) Returns an existing cell if available, otherwise creates new one ✓
C) Always returns the first cell in the table
D) Downloads the cell from the cloud

**Time: 20 seconds**

---

## Question 2: Value vs Reference Semantics
**Your `Pokeymon` is a struct. You write:**
```swift
var pikachu = Pokeymon(name: "Pikachu", type: .electric, attack: 55)
var clone = pikachu
clone.attack = 100
```
**What is `pikachu.attack` now?**

A) 100
B) 55 ✓
C) nil
D) Compiler error

**Time: 30 seconds**

---

## Question 3: Protocol-Delegate Pattern
**Which statement about the delegate pattern is TRUE?**

A) Delegate should be a strong reference
B) Delegate should be marked `weak` to avoid retain cycles ✓
C) Delegate must be a class, never a protocol
D) You can only have one delegate in your entire app

**Time: 20 seconds**

---

## Question 4: Closures vs Delegation
**Instead of using a delegate protocol, you could pass data back using a closure:**
```swift
class FormViewController {
    var onSave: ((Pokeymon) -> Void)?
}

// Calling it:
formVC.onSave = { pokeymon in
    self.items.append(pokeymon)
}
```
**What are advantages of this approach? (Select all that apply)**

A) More concise for simple callbacks ✓
B) No need to define a separate protocol ✓
C) Automatically prevents retain cycles
D) Can only be called once

**Time: 30 seconds**

---

## Question 5: UITableViewController
**What do you get "for free" when subclassing `UITableViewController` instead of `UIViewController`?**

A) The table view is automatically created and set up ✓
B) Cell reuse is automatic
C) The table view is set as the root view ✓
D) Data source methods are already implemented

**Time: 20 seconds**

---

## Question 6: IndexPath
**In `tableView(_:cellForRowAt:)`, you receive an IndexPath. What does it represent?**

A) The file path to the cell
B) Section and row numbers ✓
C) Only the row number
D) The memory address of the cell

**Time: 20 seconds**

---

## Question 7: Optional Protocol Methods
**You have:**
```swift
protocol MyDelegate: AnyObject {
    func didUpdate(_ item: Item)
}

extension MyDelegate {
    func didUpdate(_ item: Item) {}
}
```
**What does the extension do?**

A) Makes the protocol method optional by providing default implementation ✓
B) Breaks the protocol
C) Forces all conformers to implement it
D) Creates a retain cycle

**Time: 30 seconds**

---

## Question 8: What Does This Code Do?
```swift
func tableView(_ tableView: UITableView,
               commit editingStyle: UITableViewCell.EditingStyle,
               forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
```

A) Deletes all rows in the table
B) Enables swipe-to-delete functionality ✓
C) Commits changes to a database
D) Marks cells for editing mode

**Time: 30 seconds**

---

## Question 9: Switch on Tuple
**In a static table view, why use `switch (indexPath.section, indexPath.row)`?**

A) It's required by UITableView
B) Makes it easy to handle different cells in different sections ✓
C) It's faster than if-else
D) Tuples are required for pattern matching

**Time: 20 seconds**

---

## Question 10: Navigation Patterns
**What's the difference between these two?**
```swift
// Option A:
navigationController?.pushViewController(detailVC, animated: true)

// Option B:
present(detailVC, animated: true)
```

A) A adds to navigation stack, B presents modally ✓
B) A shows from bottom, B shows from side
C) A keeps navigation bar, B doesn't (unless wrapped in nav controller) ✓
D) They do exactly the same thing

**Time: 30 seconds**

---

## Question 11: UIStepper
**When the user taps a UIStepper, what should you do to update the cell's label?**

A) Call `tableView.reloadData()`
B) Get the cell and update its `detailTextLabel` directly ✓
C) Call `tableView.reloadRows(at:with:)`
D) Recreate the entire table view

**Time: 20 seconds**

---

## Question 12: Codable Protocol
**Your `Pokeymon` struct conforms to `Codable`. What can you do?**

A) Convert to/from JSON automatically ✓
B) Make copies of the struct
C) Save to UserDefaults without encoding
D) Encode to Data and decode back ✓

**Time: 20 seconds**

---

## Answer Key

1. B
2. B
3. B
4. A, B
5. A, C
6. B
7. A
8. B
9. B
10. A, C
11. B
12. A, D
