//
//  TableViewCell.swift
//  CFT_Task
//
//  Created by Даниил Ярмоленко on 24.03.2022.
//

import UIKit

class NoteViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView(){
        addSubview(titleLabel)
        addSubview(dataLabel)
        
        let titleLabelConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
        ]
        let dataLabelConstraints = [
            dataLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            dataLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
        ]
        
        [titleLabelConstraints, dataLabelConstraints].forEach{ NSLayoutConstraint.activate($0)}
        
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Text"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let dataLabel: UILabel = {
        let label = UILabel()
        label.text = "DATA"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
