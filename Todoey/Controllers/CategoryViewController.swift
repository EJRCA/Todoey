//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Emanuel Andrade on 16/01/2019.
//  Copyright © 2019 Emanuel Andrade. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // If categories is nil, them simply return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories add yet" //If there's no categories yet, them display "No categories add yet".
        
        return cell
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinatioVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinatioVC.selectCategory = categories?[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let selectCategory = categories?[indexPath.row]{
        do {
            try realm.write {
                realm.delete(selectCategory)
            }
        } catch {
            print("Error deleting category, \(error)")
        }
        }
        tableView.reloadData()
    }

    
    //MARK - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            NSLog("Cancel Pressed")
            //alert.removeFromParent()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add A New Category"
            textField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK - Data Manipulation Methods
    
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error)")
        }

        tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
}
