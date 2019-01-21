//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Emanuel Andrade on 16/01/2019.
//  Copyright © 2019 Emanuel Andrade. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        loadCategories()
    }

    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // If categories is nil, them simply return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let category = categories?[indexPath.row] else {fatalError()}
        cell.textLabel?.text = category.name
        
        guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
        cell.backgroundColor = categoryColor
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        
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

    
    //MARK - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "ADD", style: .default) { (action) in
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            if newCategory.name.count != 0{
                self.save(category: newCategory)
            } else {
                alert.title = ""
                alert.message = "Please Enter a Ctegory Name Before You Add It"
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            NSLog("Cancel Pressed")
            alert.removeFromParent()
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
    
    //MARK - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDelection = categories?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDelection)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}
