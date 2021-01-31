//
//  SearchPlaceholderView.swift
//  Album
//
//  Created by Calvin Lau on 31/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import UIKit

class SearchPlaceholderView: UIView {
    
    private let iv: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_search_placeholder")
        iv.setColor(.descText)
        return iv
    }()
    
    private let lbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .primaryText
        lbl.font = .boldSystemFont(ofSize: 40)
        lbl.text = "Bookmarked albums will be shown here"
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(iv)
        iv.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(iv.snp.width)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        
        addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(iv.snp.bottom).offset(10)
        }
    }
}
