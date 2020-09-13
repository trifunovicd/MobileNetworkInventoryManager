//
//  HeaderTitleView.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 25/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

public class HeaderTitleView: UITableViewHeaderFooterView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(with title: String) {
        titleLabel.text = title.uppercased()
    }
}

private extension HeaderTitleView {
    func setupUI() {
        contentView.backgroundColor = .systemBlue
        contentView.addSubview(titleLabel)
        setConstraints()
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 16, bottom: 5, right: 0))
        }
    }
}
