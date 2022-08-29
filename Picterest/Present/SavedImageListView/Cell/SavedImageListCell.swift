//
//  SavedImageListCell.swift
//  Picterest
//
//  Created by 김기림 on 2022/07/28.
//

import UIKit

final class SavedImageListCell: UICollectionViewCell, ReuseIdentifying {
    
    private enum Define {
        static let starButtonTitle = "★"
        static let longGestureMinimumPressDuration:CGFloat = 0.5
    }
    
    private let topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = CellStyle.Color.topBarBackground
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let starButton: UIButton = {
        let button = UIButton()
        button.setTitle(Define.starButtonTitle, for: .normal)
        button.setTitleColor(Style.Color.selectedStar, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: CellStyle.Font.starButton, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = CellStyle.Color.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    weak var delegate: SavedImageListCellDelegate?
    private var id: UUID?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        attribute()
        layout()
        addLongTappedGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        titleLabel.text = ""
        imageView.image = nil
        id = nil
    }
    
    func configure(data: ImageCoreInfo?) {
        guard let data = data,
        let imageURL = data.imageURL else {
            return
        }
        id = data.id
        titleLabel.text = data.message
        imageView.load(urlString: imageURL)
    }

    private func addLongTappedGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTappedGesture))
        gesture.minimumPressDuration = Define.longGestureMinimumPressDuration
        gesture.delaysTouchesBegan = true
        imageView.addGestureRecognizer(gesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc private func handleLongTappedGesture(_ sender: UILongPressGestureRecognizer) {
        guard let id = id else {
            return
        }
        if sender.state == .ended {
            delegate?.didLongTappedCell(id: id)
        }
    }
    
    private func attribute() {
        contentView.layer.cornerRadius = CellStyle.Math.cornerRadius
        contentView.clipsToBounds = true
    }
    
    private func layout() {
        [imageView, topBarStackView].forEach {
            contentView.addSubview($0)
        }
        
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        topBarStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        topBarStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        topBarStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        topBarStackView.heightAnchor.constraint(equalToConstant: CellStyle.Math.topBarHeight).isActive = true
        
        let leftPadding = UIView()
        leftPadding.translatesAutoresizingMaskIntoConstraints = false
        let rightPadding = UIView()
        rightPadding.translatesAutoresizingMaskIntoConstraints = false
        
        [leftPadding, starButton, UIView(), titleLabel, rightPadding].forEach {
            topBarStackView.addArrangedSubview($0)
        }
        
        leftPadding.widthAnchor.constraint(equalToConstant: CellStyle.Math.largeCellTopBarSidePadding).isActive = true
        rightPadding.widthAnchor.constraint(equalToConstant: CellStyle.Math.largeCellTopBarSidePadding).isActive = true
        
        starButton.widthAnchor.constraint(equalToConstant: CellStyle.Math.starButtonSize).isActive = true
        starButton.heightAnchor.constraint(equalToConstant: CellStyle.Math.starButtonSize).isActive = true
    }
}
