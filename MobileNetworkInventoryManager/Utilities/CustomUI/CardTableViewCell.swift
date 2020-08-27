//
//  CardTableViewCell.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

public class CardTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .darkGray
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .darkGray
        return label
    }()
    
    private let siteMarkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let siteImageView: UIImageView = {
        let view = UIImageView(image: R.image.cell_tower())
        return view
    }()
    
    var onCellClicked: (() -> Void)?

    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func cellClicked() {
        onCellClicked!()
    }
    
    func configure(_ item: Any) {
        if let site = item as? SitePreview {
            titleLabel.text = site.name
            subtitleLabel.text = site.address
            infoLabel.text = site.technology
            siteMarkLabel.text = site.mark
        }
        
        if let task = item as? TaskPreview {
            titleLabel.text = task.siteName
            subtitleLabel.text = task.taskCategoryName
            if let openingTime = task.taskOpeningTime {
                infoLabel.text = openingTime.getStringFromDate()
            } else {
                infoLabel.text = "-"
            }
            siteMarkLabel.text = task.siteMark
        }
    }
}

private extension CardTableViewCell {
    func setupLayout() {
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellClicked))
        containerView.addGestureRecognizer(tapGesture)
        
        let stackView = UIStackView(arrangedSubviews: [siteImageView, siteMarkLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        containerView.addSubviews(titleLabel, subtitleLabel, infoLabel, stackView)
        
        contentView.addSubview(containerView)
        contentView.backgroundColor = .white
        
        setConstraints(containerView: containerView, stackView: stackView)
    }
    
    func setConstraints(containerView: UIView, stackView: UIStackView) {
        containerView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8))
        }
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 0))
            maker.trailing.equalTo(stackView.snp.leading).offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(titleLabel.snp.bottom).offset(8)
            maker.leading.equalToSuperview().offset(16)
            maker.trailing.equalTo(stackView.snp.leading).offset(-16)
        }
        
        infoLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            maker.leading.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 0))
            maker.trailing.equalTo(stackView.snp.leading).offset(-16)
        }
        
        siteImageView.snp.makeConstraints { (maker) in
            maker.height.width.equalTo(35)
        }
        
        stackView.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.trailing.equalToSuperview().offset(-8)
            maker.width.equalTo(60)
        }
    }
}
