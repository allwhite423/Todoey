//
//  ViewController.swift
//  Todoey
//
//  Created by Daheen Lee on 27/03/2019.
//  Copyright © 2019 allwhite. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    // UITableViewController 상속받으면 따로 Table View 구성요소에 대한 IBOutlet 등을 추가하지 않아도 된다.
    
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Study algorithm"
        itemArray.append(newItem)
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK - TableView Datasource Methods
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
    
    
    //MARK - TableView Delegate Methods
    // TableView 의 cell 클릭시 실행되는 method
    // UITableViewContorller 는 UITableViewDelegate의 하위클래스
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
        // 선택되면 done 반대로 바꾸기
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData()
        //선택시 백그라운드 색이 회색이 되도록 하는 효과 없앰
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // UIAlert , textfield
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField() //reference 용
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen onece the user clicks the Add Item button on our UIAlert
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem) //default value를 넣음
            
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in //addTextField method가 실행될 때 실행되는 함수
            alertTextField.placeholder = "Create new item" //입력전에 보이는 문장
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
}

