//
//  TasksTableViewCell.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    private let siteNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskCategoryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskOpeningTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let siteMarkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let siteImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "cell-tower"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var onCellClicked: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func cellClicked() {
        onCellClicked!()
    }
    
    func configure(_ task: TaskPreview) {
        siteNameLabel.text = task.siteName
        taskCategoryLabel.text = task.taskCategoryName
        taskOpeningTimeLabel.text = task.taskOpeningTime.getStringFromDate()
        siteMarkLabel.text = task.siteMark
    }
    
    private func setupLayout() {
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.masksToBounds = false
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellClicked))
        containerView.addGestureRecognizer(tapGesture)
        
        let stackView = UIStackView(arrangedSubviews: [siteImageView, siteMarkLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubviews(views: [siteNameLabel, taskCategoryLabel, taskOpeningTimeLabel, stackView])
        
        contentView.addSubview(containerView)
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            siteNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            siteNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            siteNameLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -16),
            
            taskCategoryLabel.topAnchor.constraint(equalTo: siteNameLabel.bottomAnchor, constant: 8),
            taskCategoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            taskCategoryLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -16),
            
            taskOpeningTimeLabel.topAnchor.constraint(equalTo: taskCategoryLabel.bottomAnchor, constant: 8),
            taskOpeningTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            taskOpeningTimeLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -16),
            taskOpeningTimeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            siteImageView.heightAnchor.constraint(equalToConstant: 35),
            siteImageView.widthAnchor.constraint(equalToConstant: 35),
            
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

}
