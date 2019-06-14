//
//  NamesListTableViewController.swift
//  Pair Randomizer-IOS26
//
//  Created by winston salcedo on 6/14/19.
//  Copyright © 2019 Evolve Technologies. All rights reserved.
//


import UIKit

class NamesListTableViewController: UITableViewController {
    
    // MARK: - Properties
    var groupedNames: [[Names]] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    // Pull to Refresh
    
    // MARK: - Methods
    // Update views when data changes
    func updateViews () {
        groupedNames = NamesController.shared.groupedNames
        tableView.reloadData()
    }
    
    // MARK: - Actions
    // Randomizes the list of names
    @IBAction func randomizeButtonPressed(_ sender: Any) {
        let flatNames = groupedNames.flatMap { $0 }
        let shuffledNames = NamesController.shared.shuffleNames(names: flatNames)
        groupedNames = shuffledNames.PairedNames(into: 2)
        NamesController.shared.saveToPersistentStore()
        tableView.reloadData()
        
    }
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let flatNames = groupedNames.flatMap { $0 }
            let shuffledNames = NamesController.shared.shuffleNames(names: flatNames)
            groupedNames = shuffledNames.PairedNames(into: 2)
            NamesController.shared.saveToPersistentStore()
            tableView.reloadData()
        }
    }

    // Adds a new name to the array
    @IBAction func addNameButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Name", message: "Add someone new to the list", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Add a name..."
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let textField = alertController.textFields?.first else { print("There was an error in \(#function)"); return }
            guard let name = textField.text else { print("There was an error in \(#function)"); return }
            NamesController.shared.addName(name: name)
            self.updateViews()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        updateViews()
    }
    
    // MARK: - Table view data source
    // Setting the number of section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedNames.count
    }
    
    // Setting the title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Group \(section + 1)"
    }
    
    // Setting the rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedNames[section].count
    }
    
    // Assigning the name to each row of each section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        let name = groupedNames[indexPath.section][indexPath.row].name
        cell.textLabel?.text = name
        return cell
    }
    
    // Removing a name from the array
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            NamesController.shared.removeName(groupNames: groupedNames, section: indexPath.section, row: indexPath.row)
            updateViews()
        }
    }
}
