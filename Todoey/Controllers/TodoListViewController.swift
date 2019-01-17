//
//  ViewController.swift
//  Todoey
//
//  Created by Emanuel Andrade on 11/01/2019.
//  Copyright © 2019 Emanuel Andrade. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK - TableView Datasorce Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title // Fill the cell
            
            // Ternary Operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none // Check if item.done is true, them put a checkmark, if is false them put none
        } else {
            cell.textLabel?.text = "No Items add yet"
        }
        
        return cell
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done //This do the same of a If Statmen
//
//        saveItems(items: <#T##Item#>)
        tableView.deselectRow(at: indexPath, animated: true) //Deselect the row after we click on it
    }
    
    
     //MARK - Add new items
    
    @IBAction func addButtonPresses(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //  What will happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item, \(error)")
                }
            }//Save item after create it
        
            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    

    //MARK - Model Manipulation Methods
    
    func loadItems() {
        todoItems = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}


// MARK - Search bar methods

//extension TodoListViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}
