//
//  CafeDetailViewController.swift
//  CRUD
//
//  Created by Sing Hui Hang on 10/10/25.
//

import UIKit
import MapKit

class CafeDetailViewController: UITableViewController {
    
    var cafe: Cafe! //force unwrapped because it is always set during init
    weak var delegate: CafeFormViewControllerDelegate?
    
    init(cafe: Cafe) {
        self.cafe = cafe //initialiser to pass in the Cafe object
        super.init(style: .insetGrouped) //modern iOS table style with rounded corners
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Theme.background
        title = cafe.name
        
        // Add Edit button on top right hand corner
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTapped)
        )
        
        // Disable large titles for detail
        navigationItem.largeTitleDisplayMode = .never
    }

    
    @objc private func editTapped() {
        let formVC = CafeFormViewController(cafe: cafe)
        formVC.delegate = self //set itself as delegate to receive updates
        let navController = UINavigationController(rootViewController: formVC)
        present(navController, animated: true) //present as modal popup
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5 // Includes map section
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Name
        case 1: return 2 // Rating + Specialty
        case 2: return 2 // Date + Location
        case 3: return 1 // Map
        case 4: return 1 // Notes
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "☕️ Name"
            cell.detailTextLabel?.text = cafe.name
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            
        case (1, 0):
            cell.textLabel?.text = "⭐️ Rating"
            cell.detailTextLabel?.text = String(repeating: "⭐️", count: cafe.rating)
            cell.detailTextLabel?.font = .systemFont(ofSize: 18)
            
        case (1, 1):
            cell.textLabel?.text = "✨ Specialty"
            cell.detailTextLabel?.text = cafe.specialty.rawValue.capitalized
            cell.detailTextLabel?.textColor = .systemBlue
            
        case (2, 0):
            cell.textLabel?.text = "📅 Date Visited"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            cell.detailTextLabel?.text = formatter.string(from: cafe.dateVisited)
            
        case (2, 1):
            cell.textLabel?.text = "📍 Location"
            cell.detailTextLabel?.text = cafe.location
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.textAlignment = .right
            
            if cafe.coordinate != nil {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
        
            
        case (3, 0):
            if let coordinate = cafe.coordinate {
                //if coordinate exist
                cell.selectionStyle = .none
                
                let mapView = MKMapView()
                mapView.isUserInteractionEnabled = true
                mapView.translatesAutoresizingMaskIntoConstraints = false
                
                //Pin on the map
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate //where the pin goes
                annotation.title = cafe.name //label when the pin is tapped
                mapView.addAnnotation(annotation)
                
                //centers the map around the region of the area that we identified
                let region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                mapView.setRegion(region, animated: true)
                
                cell.contentView.addSubview(mapView)
                NSLayoutConstraint.activate([
                    mapView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    mapView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    mapView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    mapView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    mapView.heightAnchor.constraint(equalToConstant: 200)
                ])
            } else {
                cell.textLabel?.text = "No location data"
                cell.textLabel?.textColor = .systemGray
            }
            
        case (4, 0):
            let notesCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            notesCell.selectionStyle = .none
            notesCell.textLabel?.text = "📝 Notes"
            notesCell.textLabel?.font = .systemFont(ofSize: 17)
            notesCell.detailTextLabel?.text = cafe.notes.isEmpty ? "No notes" : cafe.notes
            notesCell.detailTextLabel?.numberOfLines = 0
            notesCell.detailTextLabel?.font = .systemFont(ofSize: 15)
            notesCell.detailTextLabel?.textColor = cafe.notes.isEmpty ? .systemGray : .secondaryLabel
            return notesCell
            
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - Table Headers & Layout
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "CAFE INFORMATION"
        case 1: return "EXPERIENCE"
        case 2: return "VISIT DETAILS"
        case 3: return cafe.coordinate != nil ? "LOCATION MAP" : nil
        case 4: return "PERSONAL NOTES"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && cafe.coordinate != nil {
            return 200 //height for map
        }
        if indexPath.section == 4 {
            return UITableView.automaticDimension //calculate height based on content - since notes vary
        }
        return 44 //standard iOS row height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 200
        }
        if indexPath.section == 4 {
            return 80
        }
        return 44
    }
    
    // MARK: - Row Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2, indexPath.row == 1, let coordinate = cafe.coordinate {
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = cafe.name
            //prefill directions to the cafe, allowing users to get directions
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}

// MARK: - CafeFormViewControllerDelegate
extension CafeDetailViewController: CafeFormViewControllerDelegate {
    func didUpdateCafe(_ cafe: Cafe) {
        // Update this detail screen
        self.cafe = cafe
        title = cafe.name
        tableView.reloadData()
        
        // Propagate update back to list view
        delegate?.didUpdateCafe(cafe)
    }
}
