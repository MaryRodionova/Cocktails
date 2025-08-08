import UIKit

final class CocktailGuideViewController: UIViewController {
    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let buttonHeight: CGFloat = 52
        static let searchBarHeight: CGFloat = 52
    }

    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Введите название коктейля..."
        search.searchBarStyle = .minimal
        search.layer.cornerRadius = 12
        search.clipsToBounds = true
        search.backgroundColor = UIColor.systemGray6
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()

    private let randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎲 Случайный коктейль", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 12
        button.addTarget(self,
                         action: #selector(randomButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = .systemBlue
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        return loader
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = """
        🔍 Введите название коктейля
        или нажмите на случайный коктейль
        
        💡 Попробуйте: margarita, mojito,
        cosmopolitan, bloody mary
        """
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var searchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        addSubviews()
        setupConstraints()
        showEmptyState()
    }

    private func setupNavigationBar() {
        title = "🍸 Коктейльный гид"

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]

        searchBar.delegate = self
    }

    @objc private func randomButtonTapped() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadRandomCocktail()
    }

    private func loadRandomCocktail() {
        showLoading()
        CocktailService.shared.getRandomCocktail { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }

    private func searchCocktails(query: String) {
        guard !query.isEmpty else {
            clearResults()
            return
        }
        showLoading()
        CocktailService.shared.searchCocktail(name: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }

    private func handleResult(_ result: Result<[Cocktail], Error>) {
        hideLoading()
        switch result {
        case .success(let cocktails):
            cocktails.isEmpty ? showError("Коктейли не найдены") : displayCocktails(cocktails)
        case .failure(let error):
            showError("Ошибка: \(error.localizedDescription)")
        }
    }

    private func displayCocktails(_ cocktails: [Cocktail]) {
        clearResults()
        cocktails.forEach {
            let card = CocktailCardView()
            card.configure(with: $0)
            stackView.addArrangedSubview(card)
        }
        hideEmptyState()
    }

    private func clearResults() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        showEmptyState()
    }

    private func showLoading() {
        loadingIndicator.startAnimating()
        hideEmptyState()
    }

    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }

    private func showEmptyState() {
        emptyStateLabel.isHidden = false
    }

    private func hideEmptyState() {
        emptyStateLabel.isHidden = true
    }

    private func showError(_ message: String) {
        clearResults()
        emptyStateLabel.text = "❌ \(message)\n\n💡 Попробуйте другое название"
        showEmptyState()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.emptyStateLabel.text = """
            🔍 Введите название коктейля
            или нажмите на случайный коктейль

            💡 Попробуйте: margarita, mojito,
            cosmopolitan, bloody mary
            """
        }
    }
}

// MARK: - UISearchBarDelegate

extension CocktailGuideViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { [weak self] _ in
            self?.searchCocktails(query: searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let query = searchBar.text, !query.isEmpty {
            searchCocktails(query: query)
        }
    }
}


private extension CocktailGuideViewController {
    
    func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(randomButton)
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.verticalSpacing),
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalPadding),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalPadding),
                searchBar.heightAnchor.constraint(equalToConstant: Layout.searchBarHeight),
                
                randomButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Layout.verticalSpacing),
                randomButton.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
                randomButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
                randomButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
                
                scrollView.topAnchor.constraint(equalTo: randomButton.bottomAnchor, constant: Layout.verticalSpacing),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalPadding),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalPadding),
                
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
                emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
            ]
        )
    }
}


