//
//  Item.swift
//  Todoey
//
//  Created by Radhi Mighri on 19/07/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//


import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var toDoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // making the bar colour the same as the category one
        
    }
    
    // the problem here thats the viewDidLoad() can be executed but the navigation controller its not yet ready
    override func viewWillAppear(_ animated: Bool) { //viewWillAppear() gets called later than viewDidLoad() : so after the viewDidLoad() has benn loaded up and after the navigation stack has been established and just before the user sees anything on screen this is the time point that we can access using viewWillAppear()
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: colourHex) {
                //Original setting: navBar.barTintColor = UIColor(hexString: colourHex)
                //Revised for iOS13 w/ Prefer Large Titles setting:
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                searchBar.barTintColor = navBarColour
            }
        }
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            //print("Version 1 \(CGFloat(indexPath.row / (toDoItems!.count)))")
            //print("Version 2 \(CGFloat(indexPath.row) / CGFloat(toDoItems!.count))")
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No items added yet"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do{
                try realm.write{
                    item.done = !item.done // update the done status of the selected item
                    //realm.delete(item) // delete the hole selected object
                    
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    if textField.text?.count != 0 {
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.done = false
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }
                    else {
                        let action2 = UIAlertAction(title: "OK", style: .default)
                        let alert2 = UIAlertController(title: "Please Enter an Item Name!", message: "", preferredStyle: .alert)
                        alert2.addAction(action2)
                        self.present(alert2, animated: true, completion: nil)
                    }
                    
                }catch{
                    print("Error saving new items, \(error)")
                }
                
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    
    
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
        
    }
    
    //MARK:- Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        // super.updateModel(at: indexPath) // just if u want to execute the functionalities written in the super class but in our case there is nothing important 'just a print statment for testing'
        
        if let itemForDeletion = self.toDoItems?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion) // delete the hole selected object
                }
            }catch{
                print("Error deleting category, \(error)")
            }
            
        }
    }
    
}



//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: false)
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








