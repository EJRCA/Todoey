//
//  ViewController.swift
//  Todoey
//
//  Created by Emanuel Andrade on 11/01/2019.
//  Copyright © 2019 Emanuel Andrade. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectCategory?.name
        
        guard let colorHex = selectCategory?.color else {
            fatalError()}
        
        updateNavBar(withHexCode: colorHex)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    
    //MARK - Navibar setup codes methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {
            fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navBar.tintColor]
        searchBar.barTintColor = navBarColor
    }
    
    //MARK - TableView Datasorce Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
   
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title //
            
            let selectCategoryColor = UIColor(hexString: (selectCategory!.color))
            
            if let color = selectCategoryColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
                    item.done = !item.done
                }
                } catch {
                print("Error change done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true) //Deselect the row after we click on it
    }
    
    
     //MARK - Add new items
    
    @IBAction func addButtonPresses(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Item Name"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            NSLog("Cancel Pressed")
            alert.removeFromParent()
        }
        
        let addAction = UIAlertAction(title: "ADD", style: .default) { (action) in
            //  What will happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        
                        if newItem.title.count != 0{
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        } else {
                            alert.title = ""
                            alert.message = "Please Enter an Item Name Before You Add It"
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } catch {
                    print("Error saving new item, \(error)")
                }
            }//Save item after create it
        
            self.tableView.reloadData()
        }

        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    

    //MARK - Model Manipulation Methods
    
    func loadItems() {
        todoItems = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDelection = todoItems?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(itemForDelection)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
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
