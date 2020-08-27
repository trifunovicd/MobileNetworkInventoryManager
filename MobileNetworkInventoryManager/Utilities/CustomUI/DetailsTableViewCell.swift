//
//  DetailsTableViewCell.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 23/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    private let itemLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let itemText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(label: String, text: String) {
        itemLabel.text = label
        itemText.text = text
    }
}

private extension DetailsTableViewCell {
    func setupLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubviews(itemLabel, itemText)
        setConstraints()
    }
    
    func setConstraints() {
        itemLabel.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16))
        }
        
        itemText.snp.makeConstraints { (maker) in
            maker.top.equalTo(itemLabel.snp.bottom).offset(8)
            maker.leading.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16))
        }
    }
}
