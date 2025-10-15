//
//  CafeFormViewController.swift
//  CRUD
//
//  Created by Sing Hui Hang on 10/10/25.
//
import UIKit
import Foundation
import CoreLocation

// MARK: - Protocol
protocol CafeFormViewControllerDelegate: AnyObject {
    func didAddCafe(_ cafe: Cafe) //only for adding new cafe
    func didUpdateCafe(_ cafe: Cafe) //only for editing existing cafe
}

// Make delegate methods optional - because we don't need both for ListViewController (add) and DetailViewController
extension CafeFormViewControllerDelegate {
    func didAddCafe(_ cafe: Cafe) {}
    func didUpdateCafe(_ cafe: Cafe) {}
}

class CafeFormViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, LocationPickerDelegate {
    
    var cafe: Cafe?
    weak var delegate: CafeFormViewControllerDelegate?
    
    // Form data
    private var name: String = ""
    private var dateVisited: Date = Date()
    private var rating: Int = 3
    private var specialty: Specialty = .drinks
    private var notes: String = ""
    private var location: String = ""
    private var coordinate: CLLocationCoordinate2D?
    
    // UI Components
    private let nameTextField = UITextField()
    private let locationButton = UIButton(type: .system)
    private let notesTextView = UITextView()
    private let datePicker = UIDatePicker()
    private let specialtyPicker = UIPickerView()
    private let ratingStepper = UIStepper()
    
    // MARK: - Initialization
    init(cafe: Cafe?) {
        self.cafe = cafe
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply theme
        tableView.backgroundColor = Theme.background
        
        // Set title based on add vs edit
        title = cafe == nil ? "Add Cafe" : "Edit Cafe"
        
        // Setup navigation buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
        
        // Add bottom padding to tableView so we can scroll past the last cell
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        setupUI()
        configureForEditing()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Name text field
        nameTextField.placeholder = "Enter cafe name"
        nameTextField.borderStyle = .none
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        
        // Location button
        locationButton.setTitle("Tap to select location", for: .normal)
        locationButton.setTitleColor(Theme.warmOrange, for: .normal)
        locationButton.contentHorizontalAlignment = .left
        locationButton.addTarget(self, action: #selector(selectLocation), for: .touchUpInside)
        
        // Notes text view
        notesTextView.font = .systemFont(ofSize: 17)
        notesTextView.isScrollEnabled = false
        notesTextView.delegate = self
        
        // Date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        // Specialty picker
        specialtyPicker.delegate = self
        specialtyPicker.dataSource = self
        
        // Rating stepper
        ratingStepper.minimumValue = 1
        ratingStepper.maximumValue = 5
        ratingStepper.value = Double(rating)
        ratingStepper.addTarget(self, action: #selector(ratingChanged), for: .valueChanged)
    }
    
    private func configureForEditing() {
        guard let cafe = cafe else { return }
        
        name = cafe.name
        dateVisited = cafe.dateVisited
        rating = cafe.rating
        specialty = cafe.specialty
        notes = cafe.notes
        location = cafe.location
        coordinate = cafe.coordinate
        
        nameTextField.text = name
        locationButton.setTitle(location.isEmpty ? "Tap to select location" : location, for: .normal)
        notesTextView.text = notes
        datePicker.date = dateVisited
        ratingStepper.value = Double(rating)
        
        if let index = Specialty.allCases.firstIndex(of: specialty) {
            specialtyPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Actions
    @objc private func nameChanged() {
        name = nameTextField.text ?? ""
    }
    
    @objc private func selectLocation() {
        let locationPicker = LocationPickerViewController()
        locationPicker.delegate = self
        let navController = UINavigationController(rootViewController: locationPicker)
        present(navController, animated: true)
    }
    
    @objc private func dateChanged() {
        dateVisited = datePicker.date
    }
    
    @objc private func ratingChanged() {
        rating = Int(ratingStepper.value)
        // Update the star display directly instead of reloading the cell
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) {
            cell.detailTextLabel?.text = String(repeating: "⭐️", count: rating)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        // Validate name
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(
                title: "Missing Name",
                message: "Please enter a cafe name",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        if let existingCafe = cafe {
            // Editing existing cafe
            existingCafe.name = name
            existingCafe.dateVisited = dateVisited
            existingCafe.rating = rating
            existingCafe.specialty = specialty
            existingCafe.notes = notes
            existingCafe.location = location
            existingCafe.coordinate = coordinate
            
            delegate?.didUpdateCafe(existingCafe)
        } else {
            // Adding new cafe
            let newCafe = Cafe(
                name: name,
                dateVisited: dateVisited,
                rating: rating,
                specialty: specialty,
                notes: notes,
                favourite: false,
                location: location,
                coordinate: coordinate
            )
            
            delegate?.didAddCafe(newCafe)
        }
        
        dismiss(animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        // Remove any existing subviews to prevent duplication
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        switch indexPath.section {
        case 0: // Name
            cell.textLabel?.text = "Name"
            cell.textLabel?.textColor = Theme.coffeeBrown
            cell.contentView.addSubview(nameTextField)
            nameTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameTextField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 16),
                nameTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                nameTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
        case 1: // Date
            cell.textLabel?.text = nil
            cell.contentView.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
        case 2: // Location
            cell.textLabel?.text = "Location"
            cell.textLabel?.textColor = Theme.coffeeBrown
            cell.contentView.addSubview(locationButton)
            locationButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                locationButton.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 16),
                locationButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                locationButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
        case 3: // Specialty
            cell.textLabel?.text = nil
            cell.contentView.addSubview(specialtyPicker)
            specialtyPicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                specialtyPicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                specialtyPicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                specialtyPicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                specialtyPicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
        case 4: // Rating
            cell.textLabel?.text = "Rating"
            cell.textLabel?.textColor = Theme.coffeeBrown
            cell.detailTextLabel?.text = String(repeating: "⭐️", count: rating)
            cell.detailTextLabel?.font = .systemFont(ofSize: 20)
            cell.accessoryView = ratingStepper
            
        case 5: // Notes
            cell.textLabel?.text = "Notes"
            cell.textLabel?.textColor = Theme.coffeeBrown
            cell.textLabel?.numberOfLines = 0
            cell.contentView.addSubview(notesTextView)
            notesTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                notesTextView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                notesTextView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                notesTextView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                notesTextView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
                notesTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Basic Information"
        case 1: return "Visit Details"
        case 2: return "Location"
        case 3: return "Cafe Specialty"
        case 4: return "Your Rating"
        case 5: return "Additional Notes"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 200 // Date picker
        case 3: return 150 // Specialty picker
        case 5: return 120 // Notes
        default: return 44
        }
    }
    
    // MARK: - Picker View Data Source & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Specialty.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Specialty.allCases[row].rawValue.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        specialty = Specialty.allCases[row]
    }
}

// MARK: - Text View Delegate
extension CafeFormViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notes = textView.text
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - Location Picker Delegate
extension CafeFormViewController {
    func didSelectLocation(address: String, coordinate: CLLocationCoordinate2D) {
        location = address
        self.coordinate = coordinate
        locationButton.setTitle(address, for: .normal)
    }
}
