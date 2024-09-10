//
//  SeasonDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 08.02.24.
//

import Architecture
import SharedModels
import UIKit

public protocol SeasonDisplayDelegate: AnyObject {
    func didChangePagination(to: Int)
}

public class SeasonDisplay: UIView {

    public weak var delegate: SeasonDisplayDelegate?
    public var infoData: InfoData
    public var selectedPagination: Int = 0

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let seasonLabel: UILabel = {
        let label = UILabel()
        label.text = "Season 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    public let seasonButton = CircleButton(icon: "chevron.right")

    let mediaCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Media"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.alpha = 0.7
        return label
    }()

    let pagination = PaginationDisplay()

    // MARK: Lifecycle

    public init(infoData: InfoData) {
        self.infoData = infoData
        super.init(frame: .zero)
        configure()
        setupConstraints()
        updateData()
    }

    // MARK: View Lifecycle

    override public init(frame: CGRect) {
        self.infoData = .sample
        super.init(frame: frame)
        configure()
        setupConstraints()
        updateData()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func configure() {
        horizontalStack.addArrangedSubview(seasonLabel)
        horizontalStack.addArrangedSubview(seasonButton)

        stack.addArrangedSubview(horizontalStack)
        stack.addArrangedSubview(mediaCountLabel)
        stack.addArrangedSubview(pagination)

        addSubview(stack)
        pagination.delegate = self
    }

    public func updateData() {
        if infoData.mediaList.count > selectedPagination {
            mediaCountLabel.text = "\(infoData.mediaList[selectedPagination].pagination.first?.items.count ?? 0) \(infoData.mediaType)"
        }
        seasonLabel.text = infoData.seasons.first(where: { $0.selected == true })?.name
        pagination.infoData = infoData
        pagination.updateData()
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        if !infoData.tags.isEmpty {
            NSLayoutConstraint.activate([
                pagination.heightAnchor.constraint(equalToConstant: 24),
                pagination.topAnchor.constraint(equalTo: mediaCountLabel.bottomAnchor, constant: 8)
            ])
        }
    }
}

extension SeasonDisplay: PaginationDelegate {
    public func didChangePagination(to index: Int) {
        selectedPagination = index
        if infoData.mediaList.count > selectedPagination {
            mediaCountLabel.text = "\(infoData.mediaList[selectedPagination].pagination.first?.items.count ?? 0) \(infoData.mediaType)"
        }
        delegate?.didChangePagination(to: index)
    }
}
