//
//  ViewController.swift
//  CFT_Task
//
//  Created by Даниил Ярмоленко on 24.03.2022.
//

import UIKit
import Foundation
import PinLayout
import CoreData
class ViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate 
    var tableView = UITableView()
    var model: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataLoad()
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource =  self
        tableView.register(NoteViewCell.self, forCellReuseIdentifier: "NoteViewCell")
        view.addSubview(tableView)
        view.addSubview(labelEmpty)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("reloadData"), object: nil)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addBtnClicked))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.pin.all()
        labelEmpty.pin.all()
    }
    override func viewDidAppear(_ animated: Bool) {
        if model.isEmpty {
            tableView.isHidden = true
            labelEmpty.isHidden = false
        } else {
            tableView.isHidden = false
            labelEmpty.isHidden = true
        }
        
    }
    
    @objc func addBtnClicked(){
        let viewController = DetailVC()
        viewController.uuid = UUID()
        viewController.stateNew = true
        viewController.stateEdit = true
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    let labelEmpty: UILabel = {
        let label = UILabel()
        label.text = "Заметок нет"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    func dataLoad(){
        if UserDefaults.standard.string(forKey: "FirstLaunch") == nil {
            let firstNotes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: appDelegate.persistentContainer.viewContext)
            firstNotes.setValue(UUID(), forKey: "id")
            firstNotes.setValue("Как пользоваться приложением", forKey: "noteTitle")
            firstNotes.setValue("Просто добавь заметку нажав на плюс", forKey: "noteText")
            firstNotes.setValue(Date.now, forKey: "noteDate")
            appDelegate.saveContext()
            UserDefaults.standard.set("NotFirst", forKey: "FirstLaunch")
            do {
                try appDelegate.persistentContainer.viewContext.save()
            }
            catch {
            }
        }
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        model = try! appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
    }
    @objc func reloadData() {
        dataLoad()
        tableView.reloadData()
    }
    
}

