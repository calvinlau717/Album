//
//  AlbumTableViewCell.swift
//  Album
//
//  Created by Calvin Lau on 31/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class AlbumTableViewCell: UITableViewCell {
    
    private let albumArtworkIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let collectionNameLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        lbl.textColor = .primaryText
        return lbl
    }()
    
    private let collectionDescLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .descText
        return lbl
    }()
    
    private let bookmarkBtn: UIButton = {
        let btn = UIButton()
        btn.contentVerticalAlignment = .center
        btn.contentHorizontalAlignment = .center
        
        
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumArtworkIV.image = nil
        collectionNameLbl.text = ""
        collectionDescLbl.text = ""
        bookmarkBtn.setImage(nil, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func config(_ albumData: Album.SearchResults.Result?) {
        guard let kAlbumData = albumData else { return }
        albumArtworkIV.sd_setImage(with: kAlbumData.artworkUrl100)
        collectionNameLbl.text = kAlbumData.collectionName
        collectionDescLbl.text = kAlbumData.artistName + " \u{2022} " + kAlbumData.primaryGenreName
        bookmarkBtn.setImage(kAlbumData.bookmarkImage, for: .normal)
        bookmarkBtn.imageView?.setColor(.primaryRed)
    }
    
    private func setup() {
        selectionStyle = .none
        backgroundColor = .darkBackground
        
        contentView.addSubview(albumArtworkIV)
        albumArtworkIV.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0))
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        contentView.addSubview(bookmarkBtn)
        bookmarkBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 15, height: 15))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(collectionNameLbl)
        collectionNameLbl.snp.makeConstraints { (make) in
            make.left.equalTo(albumArtworkIV.snp.right).offset(10)
            make.top.equalTo(albumArtworkIV)
            make.right.equalTo(bookmarkBtn.snp.left).offset(-10)
        }
        
        contentView.addSubview(collectionDescLbl)
        collectionDescLbl.snp.makeConstraints { (make) in
            make.left.right.equalTo(collectionNameLbl)
            make.top.equalTo(collectionNameLbl.snp.bottom).offset(3)
        }
    }

}
