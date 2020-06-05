//
//  SitesTableViewCell.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 27/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class SitesTableViewCell: UITableViewCell {
    
    private let siteNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let siteAddressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let siteTechnologyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
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

        if selected {
            onCellClicked!()
        }
    }
    
    func configure(_ site: SitePreview) {
        siteNameLabel.text = site.name
        siteAddressLabel.text = site.address
        siteTechnologyLabel.text = site.technology
        siteMarkLabel.text = site.mark
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
        
        let stackView = UIStackView(arrangedSubviews: [siteImageView, siteMarkLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubviews(views: [siteNameLabel, siteAddressLabel, siteTechnologyLabel, stackView])
        
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
            
            siteAddressLabel.topAnchor.constraint(equalTo: siteNameLabel.bottomAnchor, constant: 8),
            siteAddressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            siteAddressLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -16),
            
            siteTechnologyLabel.topAnchor.constraint(equalTo: siteAddressLabel.bottomAnchor, constant: 8),
            siteTechnologyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            siteTechnologyLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -16),
            siteTechnologyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            siteImageView.heightAnchor.constraint(equalToConstant: 35),
            siteImageView.widthAnchor.constraint(equalToConstant: 35),
            
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

}
