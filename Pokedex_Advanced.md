# Pokedex App - Advanced Features

Building on your CRUD app to teach modern iOS patterns: value semantics, persistence, generics, diffable data sources, and search.

## Part 1: From Classes to Structs (Value Semantics)

Currently your `Item` is a class, meaning instances are passed by reference. When you mutate a class instance, everyone holding that reference sees the change.

**Value semantics** work differently: structs are copied when passed around. Mutations create new instances.

**Why this matters:**
- Structs are safer (no unexpected mutations elsewhere)
- Better for Codable and persistence (immutable snapshots)
- Required for diffable data sources to detect changes properly

### Tasks

1. Convert your `Item` from `class` to `struct`
2. Remove the protocol extension with default implementations (we'll need all delegate methods now)
3. Update `ItemFormViewController`'s `saveTapped()`:
   - For editing, you must **create a new instance** with updated values:
   ```swift
   let updatedItem = Item(
       id: existingItem.id,  // keep same ID!
       name: name,
       type: type,
       // ... other properties
   )
   delegate?.didUpdateItem(updatedItem)
   ```
4. Update `ViewController`'s `didUpdateItem(_:)`:
   - Find the item by ID and replace it in the array:
   ```swift
   if let index = items.firstIndex(where: { $0.id == item.id }) {
       items[index] = item  // replace old struct with new one
       tableView.reloadData()
   }
   ```
5. Update `DetailViewController`'s `didUpdateItem(_:)`:
   - Must reassign the stored property: `self.item = item`
   - Then reload table

### Checkpoint

Run the app. Edit an item. Verify changes appear everywhere.

**Question:** Why do we need to find and replace the struct in the array now? Why didn't we need this with classes?

## Part 2: Persistence Layer (Codable + FileManager)

Time to save your data! We'll create a separate manager class to handle all data operations.

**Why separate?**
- Keeps ViewControllers focused on UI logic
- Easier to test
- Can swap storage mechanisms (JSON, database, network) without changing VCs
- This is sometimes called the Repository pattern or VIPER's Interactor

### Understanding Codable

`Codable` is Swift's serialization system. It converts structs to/from JSON automatically.

Your `Item: Codable` means:
```swift
let encoder = JSONEncoder()
let data = try encoder.encode(item)  // Item → JSON data

let decoder = JSONDecoder()
let item = try decoder.decode(Item.self, from: data)  // JSON data → Item
```

Works recursively - if your struct contains other Codable types (String, Int, Date, enums), it all encodes.

### Tasks

1. Create `ItemDataManager.swift`:
```swift
class ItemDataManager {
    static let shared = ItemDataManager()

    private init() {}

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentsPath.appendingPathComponent("items.json")
    }

    func loadItems() -> [Item] {
        guard let data = try? Data(contentsOf: fileURL),
              let items = try? JSONDecoder().decode([Item].self, from: data) else {
            return []
        }
        return items
    }

    func saveItems(_ items: [Item]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }
}
```

2. In ViewController:
   - Add property: `private let dataManager = ItemDataManager.shared`
   - In `viewDidLoad()`, load data: `items = dataManager.loadItems()`
   - Call `dataManager.saveItems(items)` after every add/update/delete

3. Test persistence:
   - Add several items
   - Quit app (from Xcode, not just home button)
   - Relaunch - items should still be there!

### Checkpoint

**Question:** Why can't we use `UserDefaults` for this?
- Hint: size limits, type restrictions, not designed for arrays of custom types

**Discussion:** Where does `ItemDataManager` fit in MVC? Is it Model, Controller, or something else?

## Part 3: Generics (Required Reading)

Before moving to diffable data sources, you need to understand generics.

**See:** `Generics_Exercises.md` for a separate lesson with exercises.

**Summary:**
- Generics are type parameters that make code reusable
- `Array<String>` and `Dictionary<String, Int>` use generics
- Diffable data source: `UITableViewDiffableDataSource<SectionType, ItemType>`
- Both types must be `Hashable`

## Part 4: Hashable Protocol

For diffable data sources, both your section type and item type must be `Hashable`.

**What is Hashable?**
- Provides unique identity for comparison
- Required for Dictionary keys and Set elements
- Combines `Equatable` (==) and hash function

**Identity vs Equality:**
- Two items are **equal** if they have the same ID
- Two items have same **hash** based on their ID (not other properties)
- Why? If hash changed when name/stats changed, diffable couldn't track updates

### Tasks

1. Make your enum conform to `Hashable` (probably already automatic since it has a raw value)

2. Make `Item` conform to `Hashable`:
```swift
extension Item: Hashable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
```

### Checkpoint

**Question:** What would happen if you hashed all properties instead of just ID? Why would this break diffable data sources?

## Part 5: Diffable Data Sources (Grouped by Type)

Now for the modern way: instead of manually tracking insertions/deletions, you declare what data should be shown. The system figures out how to get there.

**Traditional approach (what you've been doing):**
```swift
items.append(newItem)
tableView.insertRows(at: [indexPath], with: .automatic)
// If you get this wrong → crash
```

**Diffable approach:**
```swift
items.append(newItem)
applySnapshot()  // System calculates diff, animates automatically
```

### Understanding Snapshots

A **snapshot** represents the complete state of your table at a moment in time.
- What sections exist
- What items are in each section
- Order of everything

When you apply a snapshot, diffable compares it to the current state and animates the differences.

### Tasks

1. Remove the `UITableViewDataSource` extension entirely (diffable handles this now)

2. Add property:
```swift
private var dataSource: UITableViewDiffableDataSource<ItemType, Item>!
```

3. In `setupUI()`, configure the data source:
```swift
dataSource = UITableViewDiffableDataSource<ItemType, Item>(
    tableView: tableView
) { tableView, indexPath, item in
    guard let cell = tableView.dequeueReusableCell(
        withIdentifier: ItemTableViewCell.identifier,
        for: indexPath
    ) as? ItemTableViewCell else {
        return UITableViewCell()
    }
    cell.configure(with: item)
    return cell
}

dataSource.defaultRowAnimation = .fade
```

4. Create the snapshot method:
```swift
private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<ItemType, Item>()

    // Group items by type
    let grouped = Dictionary(grouping: items, by: { $0.type })

    // Sort types alphabetically
    let sortedTypes = grouped.keys.sorted(by: { $0.rawValue < $1.rawValue })

    // Build snapshot
    snapshot.appendSections(sortedTypes)
    for type in sortedTypes {
        snapshot.appendItems(grouped[type]!, toSection: type)
    }

    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
}
```

5. Replace all `tableView.reloadData()` calls with `applySnapshot()`
   - In `didAddItem`: after appending, call `applySnapshot()`
   - In `didUpdateItem`: after replacing in array, call `applySnapshot()`
   - In delete: after removing, call `applySnapshot()`
   - Initial load: call `applySnapshot(animatingDifferences: false)`

6. Add section headers in your `UITableViewDelegate` extension:
```swift
func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let type = dataSource.snapshot().sectionIdentifiers[section]
    return "\(type.emoji) \(type.rawValue.capitalized)"
}
```

7. Keep `tableView(_:commit:forRowAt:)` for swipe-to-delete - it still works with diffable!

### Test

- Add items of different types
- Watch them automatically organize into sections
- Edit an item's type - watch it move between sections with animation!
- Add/delete items - smooth animations
- Empty sections disappear automatically

### Checkpoint

**Questions:**
- What are the two type parameters in `UITableViewDiffableDataSource<SectionType, ItemType>`?
- Why must both be `Hashable`?
- What's the advantage over manual `insertRows`/`deleteRows`?
- When would you use `animatingDifferences: false`?

**Challenge:** What happens if you have an empty section in your snapshot? (Try it!)

## Part 6: Search (UISearchController)

Add a search bar that filters your items in real-time.

**How it works:**
- UISearchController manages the search UI
- You implement `UISearchResultsUpdating` to filter data
- Apply a filtered snapshot when searching

### Tasks

1. Add properties:
```swift
private let searchController = UISearchController(searchResultsController: nil)
private var filteredItems: [Item] = []

private var isSearching: Bool {
    searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
}
```

2. Configure search in `setupUI()`:
```swift
searchController.searchResultsUpdater = self
searchController.obscuresBackgroundDuringPresentation = false
searchController.searchBar.placeholder = "Search Items"
navigationItem.searchController = searchController
definesPresentationContext = true
```

3. Conform to `UISearchResultsUpdating`:
```swift
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(),
              !searchText.isEmpty else {
            applySnapshot()
            return
        }

        filteredItems = items.filter { item in
            item.name.lowercased().contains(searchText)
        }
        applySnapshot()
    }
}
```

4. Update `applySnapshot()` to use filtered data:
```swift
private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<ItemType, Item>()

    let itemsToDisplay = isSearching ? filteredItems : items
    let grouped = Dictionary(grouping: itemsToDisplay, by: { $0.type })
    // ... rest stays same
}
```

### Extensions

**Search scope buttons:** Filter by type category
```swift
searchController.searchBar.scopeButtonTitles = ["All", "Fire", "Water", "Grass"]
searchController.searchBar.delegate = self
```

**Multiple criteria:** Search by name OR stats

**Debouncing:** Delay filtering for performance with large datasets

### Checkpoint

Search for an item by name. Clear search. Try searching across different types.

**Question:** Why does diffable make search easier? What would the traditional approach require?

## Part 7: Additional Features (Choose Your Own)

Pick one or more to extend the app:

**Sorting:**
- Add toolbar button with sort options (name, attack, date)
- Apply sort before grouping in snapshot

**Favourites:**
- Add `isFavourite: Bool` property
- Leading swipe action to toggle
- Separate section for favourites at top

**Stats visualization:**
- Progress bars for attack/defense in cells
- Colour-coded based on value ranges

**Export/Import:**
- Share button to export JSON
- Import from files

**Animations:**
- Custom cell animations
- Hero transitions to detail screen

**Empty states:**
- Message when no items exist
- Different message for "no search results"

## Summary: What You've Learned

- **Value vs reference semantics** - Why structs behave differently from classes
- **Separation of concerns** - Extracting data management from ViewControllers
- **Codable** - Automatic JSON encoding/decoding
- **FileManager** - Persisting data to disk
- **Generics** - Type parameters for reusable code
- **Hashable** - Identity and equality for collection types
- **Diffable data sources** - Declarative UI updates with automatic animations
- **Snapshots** - Representing complete table state
- **UISearchController** - Built-in search UI

Traditional iOS development → Modern best practices.
