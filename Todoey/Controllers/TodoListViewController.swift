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
            cell.textLabel?.text = item.title //
            
            // Ternary Operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none // Check if item.done is true, them put a checkmark, if is false them put none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
                } catch {
                print("Error change done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true) //Deselect the row after we click on it
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        do {
            try realm.write {
                let newItem = todoItems?[indexPath.row]
                realm.delete(newItem!)
            }
        } catch {
            print("Error deleting items, \(error)")
        }
        tableView.reloadData()
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
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item, \(error)")
                }
            }//Save item after create it
        
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            NSLog("Cancel Pressed")
            //alert.removeFromParent()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    

    //MARK - Model Manipulation Methods
    
    func loadItems() {
        todoItems = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
}


    //MARK - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
