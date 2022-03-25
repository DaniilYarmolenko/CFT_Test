//
//  ExtensionViewController.swift
//  CFT_Task
//
//  Created by Даниил Ярмоленко on 24.03.2022.
//

import UIKit
import CoreData

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteViewCell", for: indexPath) as? NoteViewCell else {
            return .init()
        }
        let note = model[indexPath.row]
        if note.value(forKey: "noteTitle") != nil {
            
            cell.titleLabel.text = note.value(forKey: "noteTitle") as? String
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        if note.value(forKey: "noteDate") != nil{
            cell.dataLabel.text = dateFormatter.string(from: note.value(forKey: "noteDate") as! Date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = model[indexPath.row]
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        let viewController = DetailVC()
        viewController.stateNew = false
        viewController.stateEdit = false
        if note.value(forKey: "noteText") != nil {
            viewController.mainTextView.text = note.value(forKey: "noteText") as? String
        } else {
            viewController.mainTextView.text = "Пусто"
        }
        if note.value(forKey: "noteImage") != nil {
            viewController.imageView.image = UIImage(data:  note.value(forKey: "noteImage") as! Data)
        } else {
            viewController.imageView.image = nil
        }
        if note.value(forKey: "noteTitle") != nil {
            viewController.titleTextView.text = note.value(forKey: "noteTitle") as? String
            viewController.title =  note.value(forKey: "noteTitle") as? String
        }
        if note.value(forKey: "id") != nil{
            viewController.uuid = note.value(forKey: "id") as? UUID
        }
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let note = model[indexPath.row]
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Вы дейстрительно хотите удалить заметку?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                managedContext.delete(note as NSManagedObject)
                self.model.remove(at: indexPath.row)
                do {
                    try managedContext.save()
                } catch
                    let error as NSError {
                    print("Could not save. \(error),\(error.userInfo)")
                }
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func showAlert(mes: String, iP: IndexPath, completion: @escaping () -> ()){
        let alert = UIAlertController(title: "Вы дейстрительно хотите удалить вопрос?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
            completion()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
