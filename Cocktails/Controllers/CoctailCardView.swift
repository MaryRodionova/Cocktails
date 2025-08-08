import UIKit

final class CocktailCardView: UIView {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let shadowOpacity: Float = 0.05
        static let shadowOffset: CGSize = .init(width: 0, height: 2)
        static let shadowRadius: CGFloat = 4
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 12
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Layout.shadowOpacity
        view.layer.shadowOffset = Layout.shadowOffset
        view.layer.shadowRadius = Layout.shadowRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ingredientsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "🍸 Ингредиенты:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ingredientsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let instructionsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "📝 Приготовление:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviews()
        setupConstraints()
    }

    func configure(with cocktail: Cocktail) {
        titleLabel.text = "🍹 " + cocktail.name.uppercased()
        instructionsLabel.text = "  \(cocktail.instructions)  "
        setupIngredients(cocktail.ingredients)
    }

    private func setupIngredients(_ ingredients: [String]) {
        ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for ingredient in ingredients {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .black
            label.numberOfLines = 0
            label.text = "• \(ingredient)"
            ingredientsStackView.addArrangedSubview(label)
        }
    }
}

private extension CocktailCardView {

    func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(ingredientsHeaderLabel)
        containerView.addSubview(ingredientsStackView)
        containerView.addSubview(instructionsHeaderLabel)
        containerView.addSubview(instructionsLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                containerView.topAnchor.constraint(equalTo: topAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.padding),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
                
                ingredientsHeaderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.spacing),
                ingredientsHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
                ingredientsHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
                
                ingredientsStackView.topAnchor.constraint(equalTo: ingredientsHeaderLabel.bottomAnchor, constant: 8),
                ingredientsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
                ingredientsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
                
                instructionsHeaderLabel.topAnchor.constraint(equalTo: ingredientsStackView.bottomAnchor, constant: Layout.spacing),
                instructionsHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
                instructionsHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
                
                instructionsLabel.topAnchor.constraint(equalTo: instructionsHeaderLabel.bottomAnchor, constant: 8),
                instructionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.padding),
                instructionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.padding),
                instructionsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.padding)
            ]
        )
    }
}

