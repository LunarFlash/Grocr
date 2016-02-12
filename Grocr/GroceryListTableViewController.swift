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
    
    // This is a Firebase reference that points to an online location that stores a list of online users.
    let usersRef = Firebase(url: "\(BASE_URL)/online")
    
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up swipe to delete
        tableView.allowsMultipleSelectionDuringEditing = false
        
        // User Count
        userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
        userCountBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Here you’ve added an observer that executes the given closure whenever the value that ref points to is changed.
        
        // The app is notified of the change via a closure, which is passed an instance FDataSnapshot. The snapshot, as its name suggests, represents the data at that specific moment in time. To access the data in the snapshot, you use the value property.
        
        
        
        
        ref.queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            var newItems = [GroceryItem]()
            for item in snapshot.children {
                let groceryItem = GroceryItem(snapshot: item as! FDataSnapshot)
                newItems.append(groceryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
        
        
        // Here we attach an authentication observer to the Firebase reference, that in turn assigns the user property when a user successfully signs in.
        ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                self.user = User(authData: authData)
                
                // Create a child reference using a user’s uid, which is generated when Firebase creates an account.
                let currentUserRef = self.usersRef.childByAppendingPath(self.user.uid)
                
                // Use this reference to save the current user’s email.
                currentUserRef.setValue(self.user.email)
                
                // Call onDisconnectRemoveValue() on currentUserRef. This removes the value at the reference’s location after the connection to Firebase closes, for instance when a user quits your app. This is perfect for monitoring users who have gone offline.
                currentUserRef.onDisconnectRemoveValue()
                
            }
        }
        
        // observe users list
        usersRef.observeEventType(FEventType.Value) { (snapshot:FDataSnapshot!) -> Void in
            
            if snapshot.exists() == true{
                // value changed
                self.userCountBarButtonItem.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem.title = "0"
            }
            
        }
        
        
        
        
        
        /*
        
        // Attach a listener to receive updates whenever the grocery-items endpoint is modified.
        ref.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            
            print(snapshot.value)
            
            // Store the latest version of the data in a local variable inside the listener’s closure.
            var newItems = [GroceryItem]()
            
            // The listener’s closure returns a snapshot of the latest set of data. The snapshot contains the entire list of grocery items, not just the updates. Using children, you loop through the grocery items.
            for item in snapshot.children {
                
                // The GroceryItem struct has an initializer that populates its properties using a FDataSnapshot. A snapshot’s value is of type AnyObject, and can be a dictionary, array, number, or string. After creating an instance of GroceryItem, it’s added it to the array that contains the latest version of the data.
                let groceryItem = GroceryItem(snapshot: item as! FDataSnapshot)
                newItems.append(groceryItem)
                
                // Reassign items to the latest version of the data, then reload the table view so it displays the latest version.
                self.items = newItems
                self.tableView.reloadData()
                
            }
            
            
            
            }) { (error) -> Void in
            print(error.description)
        }
        */
        
        
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
            
            // Firebase follows a unidirectional data flow model, so the listener in viewWillAppear(_:) notifies the app of the latest value of the grocery list. A removal of an item triggers a value change.
            // The index path’s row is used to retrieve the corresponding grocery item. Each GroceryItem has a Firebase reference property named ref, and calling removeValue() on that reference causes the listener in viewDidLoad() to fire. The listener has a closure attached that reloads the table view using the latest data.
            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Find the cell the user tapped using cellForRowAtIndexPath(_:).
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        // Get the corresponding GroceryItem by using the index path’s row.
        let groceryItem = items[indexPath.row]
        
        // Negate completed on the grocery item to toggle the status.
        let toggledCompletion = !groceryItem.completed
        
        // Call toggleCellCheckbox() update the visual properties of the cell.
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
       
        // Use updateChildValues(_:), passing a dictionary, to update Firebase. This method is different than setValue(_:) because it only applies updates, whereas setValue(_:) is destructive and replaces the entire value at that reference.
        groceryItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
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
