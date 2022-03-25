//
//  DetailVC.swift
//  CFT_Task
//
//  Created by Даниил Ярмоленко on 24.03.2022.
//

import UIKit
import TextViewMaster
import CoreData

class DetailVC: UIViewController, UIScrollViewDelegate {
    var context: NSManagedObjectContext?
    var stateEdit = false
    var uuid: UUID?
    var stateNew = false
    var imageChangeState: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageChangeState = false
        view.backgroundColor = .white
        if !stateNew {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editNote))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(editNote))
            imageView.isUserInteractionEnabled = true
            imageView.image = UIImage(named: "QuestionIcon")
            mainTextView.isEditable = true
            titleTextView.isEditable = true
        }
        registerKeyboardNotification()
        mainTextView.maxHeight = view.frame.height - 400
        titleTextView.maxHeight = 50
        let noteImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(noteImageTapRecognizer)
        setupView()
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    func setupView(){
        [mainTextView, titleTextView, imageView].forEach { view.addSubview($0)}
        
        let mainTextFieldConstraints = [
            mainTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 10),
            mainTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            mainTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
        ]
        let titleTextFieldConstraints = [
            titleTextView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 5),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
        ]
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: mainTextView.bottomAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200)
            
        ]
        
        
        [titleTextFieldConstraints, mainTextFieldConstraints, imageViewConstraints].forEach{ NSLayoutConstraint.activate($0)}
        
        
    }
    
    
    
    let titleTextView: TextViewMaster = {
        let textView = TextViewMaster()
        textView.placeHolder = "Как называется заметка ?"
        textView.placeHolderFont = .systemFont(ofSize: 10)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 10
        textView.maxHeight = 100
        textView.isEditable = false
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    let mainTextView: TextViewMaster = {
        let textView = TextViewMaster()
        textView.placeHolder = "Напиши текст"
        textView.placeHolderFont = .systemFont(ofSize: 10)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.isEditable = false
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    let saveButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    let editButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = 10
        img.isUserInteractionEnabled = false
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    @objc func editNote(){
        if !stateEdit {
            mainTextView.isEditable = true
            titleTextView.isEditable = true
            imageView.isUserInteractionEnabled = true
            if imageView.image == nil{
                imageView.image = UIImage(named: "QuestionIcon")
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(editNote))
            stateEdit = true
        } else {
            if !stateNew {
                updateData()
            } else {
                saveNewData()
                stateNew = false
            }
            updateData()
            if !imageChangeState! &&  imageView.image == UIImage(named: "QuestionIcon"){
                imageView.image = nil
            }
            mainTextView.isEditable = false
            titleTextView.isEditable = false
            imageView.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editNote))
            stateEdit = false
        }
    }
    func saveNewData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        var imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        uuid = UUID()
        if !imageChangeState! {
            imageData = nil
        }
        newNote.setValue(uuid, forKey: "id")
        
        newNote.setValue(titleTextView.text!, forKey: "noteTitle")
        newNote.setValue(mainTextView.text!, forKey: "noteText")
        newNote.setValue(Date.now, forKey: "noteDate")
        if imageData != nil {
            newNote.setValue(imageData!, forKey: "noteImage")
        }
        
        
        do{
            try context.save()
            NotificationCenter.default.post(name: Notification.Name("reloadData"), object: nil)
            let alert = UIAlertController(title: "Заметка добавлена!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            print("save success")
        }catch{
            print("sace error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    func updateData() {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in : managedContext)
        let request = NSFetchRequest < NSFetchRequestResult > ()
        request.entity = entity
        let stringUUID = uuid?.uuidString
        let predicate = NSPredicate(format: "(id = %@)", stringUUID!)
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        request.predicate = predicate
        do {
            let results =
            try managedContext.fetch(request)
            let objectUpdate = results[0] as!NSManagedObject
            objectUpdate.setValue(titleTextView.text!, forKey: "noteTitle")
            objectUpdate.setValue(mainTextView.text!, forKey: "noteText")
            if imageData != nil && imageChangeState! {
                objectUpdate.setValue(imageData!, forKey: "noteImage")
            }
            do {
                try managedContext.save()
                let alert = UIAlertController(title: "Заметка обновлена!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true, completion: nil)
                print("Record Updated!")
                NotificationCenter.default.post(name: Notification.Name("reloadData"), object: nil)
            } catch
                let error as NSError {
                print(error.localizedDescription)
            }
        } catch
            let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
}


extension DetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func registerKeyboardNotification(){
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification){
        let userInfo = notification.userInfo
        let keyboardHeight = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if mainTextView.frame.height > UIScreen.main.bounds.height/2 - 50 {
            mainTextView.maxHeight -= keyboardHeight.height/2
            mainTextView.setNeedsLayout()
        }
        self.view.layoutIfNeeded()
    }
    
    @objc private func keyboardWillHide(notification: Notification){
        let userInfo = notification.userInfo
        let keyboardHeight = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        mainTextView.maxHeight += keyboardHeight.height/2
        mainTextView.setNeedsLayout()
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image=info[.originalImage] as? UIImage
        imageChangeState = true
        mainTextView.setNeedsLayout()
        self.dismiss(animated: true, completion: nil)
        
    }
}
