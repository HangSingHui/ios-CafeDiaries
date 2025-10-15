import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let table = UITableView()
    var cafes = [Cafe]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title first
        title = "My Cafes"
        
        // Large titles
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = Theme.background
        
        // Add + button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCafeTapped)
        )
        
        setupTableview()
        loadMockData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Restore large titles every time
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        table.reloadData() // ensures updates from edits
    }

    private func setupTableview() {
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(CafeTableViewCell.self,
                       forCellReuseIdentifier: CafeTableViewCell.identifier)
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadMockData() {
        let cafe1 = Cafe(name: "Hvala",
                         dateVisited: Date().addingTimeInterval(-86400 * 5),
                         rating: 5,
                         specialty: .drinks,
                         notes: "Excellent coffee and service",
                         favourite: false,
                         location: "23 Duxton Rd, Singapore")
        
        let cafe2 = Cafe(name: "September Coffee",
                         dateVisited: Date().addingTimeInterval(-86400 * 10),
                         rating: 3,
                         specialty: .food,
                         notes: "Tasty pastries, friendly staff",
                         favourite: false,
                         location: "45 Kampong Glam Rd, Singapore")

        let cafe3 = Cafe(name: "Syip",
                         dateVisited: Date().addingTimeInterval(-86400 * 30),
                         rating: 4,
                         specialty: .music,
                         notes: "Live music on weekends",
                         favourite: true,
                         location: "12 Tanjong Pagar Rd, Singapore")
        
        cafes = [cafe1, cafe2, cafe3]
    }
    
    @objc private func addCafeTapped() {
        let formVC = CafeFormViewController(cafe: nil)
        formVC.delegate = self
        let navController = UINavigationController(rootViewController: formVC)
        present(navController, animated: true)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CafeTableViewCell.identifier,
            for: indexPath
        ) as? CafeTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: cafes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCafe = cafes[indexPath.row]
        let detailVC = CafeDetailViewController(cafe: selectedCafe)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cafes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Cafe Form Delegate
extension ListViewController: CafeFormViewControllerDelegate {
    func didAddCafe(_ cafe: Cafe) {
        cafes.append(cafe)
        table.reloadData()
    }
    
    func didUpdateCafe(_ cafe: Cafe) {
        // Reload only the row that changed
        if let index = cafes.firstIndex(where: { $0 === cafe }) {
            table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
