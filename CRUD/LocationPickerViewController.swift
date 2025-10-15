//
//  LocationPickerViewController.swift
//  CRUD
//
//  Created by Sing Hui Hang on 10/10/25.
//

import UIKit
import MapKit

protocol LocationPickerDelegate: AnyObject {
    func didSelectLocation(address: String, coordinate: CLLocationCoordinate2D)
}

class LocationPickerViewController: UIViewController {
    
    weak var delegate: LocationPickerDelegate?
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let mapView = MKMapView()
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var selectedAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Location"
        view.backgroundColor = Theme.background
        
        // Setup navigation buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        setupUI()
        setupSearchCompleter()
    }
    
    private func setupUI() {
        // Search bar
        searchBar.placeholder = "Search for a location"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = Theme.coffeeBrown
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Table view for results
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Theme.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Map view
        mapView.isHidden = true
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        // Include both addresses and points of interest (cafes, restaurants, etc.)
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        // Bias results to Singapore
        searchCompleter.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }
    
    private func showLocation(completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let response = response,
                  let item = response.mapItems.first else {
                return
            }
            
            // Store selected location using modern API
            // Get coordinate from the item's location property
            let location = item.location
            self.selectedCoordinate = location.coordinate
            
            // Build address string from completion
            // Use the search completion which has the full address text
            self.selectedAddress = "\(completion.title), \(completion.subtitle)"
            
            // Show map
            self.tableView.isHidden = true
            self.mapView.isHidden = false
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            // Add annotation
            self.mapView.removeAnnotations(self.mapView.annotations)
            let annotation = MKPointAnnotation()
            if let coordinate = self.selectedCoordinate {
                annotation.coordinate = coordinate
            }
            annotation.title = item.name
            self.mapView.addAnnotation(annotation)
            
            // Zoom to location
            if let coordinate = self.selectedCoordinate {
                let region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        guard let address = selectedAddress,
              let coordinate = selectedCoordinate else {
            return
        }
        
        delegate?.didSelectLocation(address: address, coordinate: coordinate)
        dismiss(animated: true)
    }
}

// MARK: - Search Bar Delegate
extension LocationPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

// MARK: - Search Completer Delegate
extension LocationPickerViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

// MARK: - Table View Delegate & Data Source
extension LocationPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use subtitle style to show both title and address
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let result = searchResults[indexPath.row]
        
        // Configure cell with better styling
        cell.textLabel?.text = result.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = Theme.coffeeBrown
        
        cell.detailTextLabel?.text = result.subtitle
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        showLocation(completion: result)
        searchBar.resignFirstResponder()
    }
}
