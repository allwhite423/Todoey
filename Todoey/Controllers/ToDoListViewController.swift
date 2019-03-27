//
//  ViewController.swift
//  Todoey
//
//  Created by Daheen Lee on 27/03/2019.
//  Copyright © 2019 allwhite. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    // UITableViewController 상속받으면 따로 Table View 구성요소에 대한 IBOutlet 등을 추가하지 않아도 된다.
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet { //해당 변수가 value가 세팅되면 실행되는 부분
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }
    
    //MARK: - TableView Datasource Methods
    // Datasource 관련 2개 메소드 - 1. cell 구성하는 내용(cellForRowAtIndexPath)  2. 몇개 row (numberOfRowsInSection)
    
    //1. cell 구성하는 내용(cellForRowAtIndexPath)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //2. 몇개 row (numberOfRowsInSection)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    //MARK: - TableView Delegate Methods
    // TableView 의 cell 클릭시 실행되는 method
    // UITableViewContorller 는 UITableViewDelegate의 하위클래스
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
        // 선택되면 done 반대로 바꾸기
        // (같은 기능) itemArray[indexPath.row].setValue(!itemArray[indexPath.row].done, forKey: "done")
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        //선택시 백그라운드 색이 회색이 되도록 하는 효과 없앰
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // UIAlert , textfield
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField() //reference 용
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen onece the user clicks the Add Item button on our UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem) //default value를 넣음
            
            self.saveItems()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in //addTextField method가 실행될 때 실행되는 함수
            alertTextField.placeholder = "Create new item" //입력전에 보이는 문장
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        do {
            try context.save() //commit 역할
        } catch {
            print("Error saving data \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    
}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //검색 버튼 눌렀을 때
        let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: searchPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems() // load all items
            DispatchQueue.main.async { // main queue 에서 실행되야 하는 것.
                searchBar.resignFirstResponder() //to get rid of keyboard, no longer have the ccursor
            }
        }
    }
}
