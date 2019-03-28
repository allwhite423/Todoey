//
//  ViewController.swift
//  Todoey
//
//  Created by Daheen Lee on 27/03/2019.
//  Copyright © 2019 allwhite. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    // UITableViewController 상속받으면 따로 Table View 구성요소에 대한 IBOutlet 등을 추가하지 않아도 된다.
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet { //해당 변수가 value가 세팅되면 실행되는 부분
            loadtodoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }
    
    //MARK: - TableView Datasource Methods
    // Datasource 관련 2개 메소드 - 1. cell 구성하는 내용(cellForRowAtIndexPath)  2. 몇개 row (numberOfRowsInSection)
    
    //1. cell 구성하는 내용(cellForRowAtIndexPath)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let parentColor = UIColor(hexString: selectedCategory!.backgroundColor)
            if let color = parentColor?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No items added"
        }
    
        return cell
    }
    
    //2. 몇개 row (numberOfRowsInSection)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    //MARK: - TableView Delegate Methods
    // TableView 의 cell 클릭시 실행되는 method
    // UITableViewContorller 는 UITableViewDelegate의 하위클래스
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택되면 done 반대로 바꾸기
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
//                    realm.delete(item) //delete item
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        //선택시 백그라운드 색이 회색이 되도록 하는 효과 없앰
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New todoItems
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // UIAlert , textfield
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField() //reference 용
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen onece the user clicks the Add Item button on our UIAlert

            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in //addTextField method가 실행될 때 실행되는 함수
            alertTextField.placeholder = "Create new item" //입력전에 보이는 문장
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadtodoItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let seletedItem = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(seletedItem)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
}

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //검색 버튼 눌렀을 때
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadtodoItems() // load all todoItems
            
            DispatchQueue.main.async { // main queue 에서 실행되야 하는 것.
                searchBar.resignFirstResponder() //to get rid of keyboard, no longer have the ccursor
            }
        }
    }
}
