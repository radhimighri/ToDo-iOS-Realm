//  Item.swift
//  Todoey
//  Created by Radhi Mighri on 19/07/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        loadCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
         }
         navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
     }
     
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1 // if categories is not nil return 'count' else return 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"

        
        if let category = categories?[indexPath.row] {
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
                cell.backgroundColor = categoryColour
                cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
            }
            return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category : Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
        
    }
    
    //MARK:- Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
       // super.updateModel(at: indexPath) // just if u want to execute the functionalities written in the super class but in our case there is nothing important 'just a print statment for testing'
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion) // delete the hole selected object
                }
            }catch{
                print("Error deleting category, \(error)")
            }
            
        }
    }
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text?.count != 0 {
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            // self.categories.append(newCategory)
            // we dont need to append because the type 'Resulats' monitors for any changes and auto-update
            self.save(category: newCategory)
            }else {
                let action2 = UIAlertAction(title: "OK", style: .default)
                let alert2 = UIAlertController(title: "Please Enter a Category Name!", message: "", preferredStyle: .alert)
                alert2.addAction(action2)
                self.present(alert2, animated: true, completion: nil)
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert, animated: true, completion: nil)
    }
    
}

