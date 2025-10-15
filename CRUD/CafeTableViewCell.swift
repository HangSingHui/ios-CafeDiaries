//
//  CafeTableViewCell.swift
//  CRUD
//
//  Created by Sing Hui Hang on 10/10/25.
//

import UIKit

class CafeTableViewCell: UITableViewCell {
    
    static let identifier = "CafeTableViewCell"
    
    private let cafeName = UILabel()
    private let cafeRating = UILabel()
    private let dateVisited = UILabel()
    private let speciality = UILabel()
    
    private let stack = UIStackView()
    private let cardView = UIView()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        // Setup card view
        cardView.backgroundColor = Theme.cardBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        accessoryType = .disclosureIndicator
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(cafeName)
        stack.addArrangedSubview(cafeRating)
        stack.addArrangedSubview(dateVisited)
        stack.addArrangedSubview(speciality)
        
        cardView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        cafeName.font = .boldSystemFont(ofSize: 18)
        cafeName.textColor = Theme.coffeeBrown
        
        cafeRating.font = .systemFont(ofSize: 16)
        cafeRating.textColor = Theme.starYellow
        
        dateVisited.font = .systemFont(ofSize: 14)
        dateVisited.textColor = Theme.secondaryText
        
        speciality.font = .italicSystemFont(ofSize: 14)
        speciality.textColor = Theme.warmOrange
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with cafe: Cafe) {
        cafeName.text = cafe.name
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateVisited.text = "📅 \(formatter.string(from: cafe.dateVisited))"
        
        let stars = String(repeating: "⭐️", count: cafe.rating)
        cafeRating.text = stars
        
        speciality.text = "✨ \(cafe.specialty.rawValue.capitalized)"
    }
}
