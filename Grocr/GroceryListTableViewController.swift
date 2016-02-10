// You retrieve data in Firebase by attaching an asynchronous listener to a reference using observeEventType(_:withBlock:).

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let ListToUsers = "ListToUsers"
    
    // MARK: Properties
    var items = [GroceryItem]()
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // Firebase properties are referred to as references because they refer to a location in your Firebase database.
    
    // In short, this property allows for saving and syncing of data to the given location.
    let ref = Firebase(url: "\(BASE_URL)/grocery-items")
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up swipe to delete
        tableView.allowsMultipleSelectionDuringEditing = false
        
        // User Count
        userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
        userCountBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        user = User(uid: "FakeId", email: "hungry@person.food")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Here you’ve added an observer that executes the given closure whenever the value that ref points to is changed.
        ref.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            
            print(snapshot.value)
            
            }) { (error) -> Void in
            print(error.description)
        }
        
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as UITableViewCell!
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        
        // Determine whether the cell is checked
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Find the snapshot and remove the value
            items.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        var groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        
        // Determine whether the cell is checked
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        groceryItem.completed = toggledCompletion
        tableView.reloadData()
    }
    
    func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(sender: AnyObject) {
        // Alert View for input
        let alert = UIAlertController(title: "Grocery Item",
            message: "Add an Item",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                // Get the text field from the alert controller.
                let textField = alert.textFields![0] 
                
                // Using the current user’s data, create a new GroceryItem that is not completed by default.
                let groceryItem = GroceryItem(name: textField.text!, addedByUser: self.user.email, completed: false)
                
                // Create a child reference using childByAppendingPath(_:). The key value of this reference is the item’s name in lowercase, so when users add duplicate items — even if they capitalize it, or use mixed case — the database saves only the latest entry.
                let groceryItemRef = self.ref.childByAppendingPath(textField.text!.lowercaseString)
                
                // Use setValue(_:) to save data to the database. This method expects a dictionary. GroceryItem has a helper function to turn it into a dictionary called toAnyObject().
                groceryItemRef.setValue(groceryItem.toAnyObject())
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    func userCountButtonDidTouch() {
        performSegueWithIdentifier(ListToUsers, sender: nil)
    }
    
}
