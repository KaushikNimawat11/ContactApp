//  ViewController.swift
//  ContactsApp
//  Created by Licious on 26/03/22.

import UIKit
struct Contact {
    var contactId: Int
    var firstName: String!
    var lastName: String!
    var phone: String!
    var email: String!
    var name: String!
    
}
var contactsDict = [String:[Contact]]()
var contactsArray = [Contact]()
var filteredContacts = [Contact]()
var sectionTitle = [String]()
var countId = 0
var nextContactId: Int {
    countId += 1
    return countId
}

func createDict(contacts: [Contact]) {
    contactsDict.removeAll()
    for contact in contacts {
    var contactKey: String!
    if !contact.firstName.isEmpty {
        let firstIndex = contact.firstName.index(contact.firstName.startIndex, offsetBy: 1)
        contactKey = String(contact.firstName[..<firstIndex])
    } else if !contact.lastName.isEmpty {
        let firstIndex = contact.lastName.index(contact.lastName.startIndex, offsetBy: 1)
        contactKey = String(contact.lastName[..<firstIndex])
    } else if !contact.phone.isEmpty {
        let firstIndex = contact.phone.index(contact.phone.startIndex, offsetBy: 1)
        contactKey = String(contact.phone[..<firstIndex])
    }
    
    contactKey = contactKey.capitalized
    let chr = Character(contactKey)
    if (!(chr >= "A" && chr <= "Z")) {
        contactKey = "#"
    }
    
    if var contactValues = contactsDict[contactKey] {
        contactValues.append(contact)
        contactsDict[contactKey] = contactValues
    } else {
        contactsDict[contactKey] = [contact]
    }
    contactsDict[contactKey]?.sort(){$0.name < $1.name}
    sectionTitle = [String](contactsDict.keys)
    sectionTitle.sort()
    }
}
class ViewController: UIViewController, UISearchResultsUpdating {
    
    @IBOutlet var tableView: UITableView!
    let searchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        createDummyData()
        
    }
    
    func createDummyData() {
        let contact1 = Contact(contactId: nextContactId, firstName: "samarth", lastName: "", phone: "92334", email: nil, name: "samarth")
        let contact2 = Contact(contactId: nextContactId, firstName: "hardik", lastName: "nimawat", phone: "944", email: nil, name: "hardik")
        let contact3 = Contact(contactId: nextContactId, firstName: "kaushik", lastName: "nimawat", phone: "123", email: nil, name: "kaushik")
        contactsArray.append(contact1)
        contactsArray.append(contact2)
        contactsArray.append(contact3)
        createDict(contacts: contactsArray)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        filteredContacts = []
        
        if searchText == "" {
            filteredContacts = contactsArray
        } else {
            filteredContacts = contactsArray.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        createDict(contacts: filteredContacts)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndex, animated: animated)
        }
        self.tableView.reloadData()
    }
    @objc func didTapAdd() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let addContact: AddContact = mainStoryBoard.instantiateViewController(withIdentifier: "AddContact") as! AddContact
        addContact.isEdit = false
        addContact.addDelegate = self
        let navigationController = UINavigationController(rootViewController: addContact)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, ContactProto {
    
    func addContact(newContact: Contact) {
        contactsArray.append(newContact)
        createDict(contacts: contactsArray)
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactKey = sectionTitle[section]
        guard let contactValues = contactsDict[contactKey] else {return 0}
        return contactValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contactKey = sectionTitle[indexPath.section]
        if let contactValues = contactsDict[contactKey] {
            cell.textLabel?.text = contactValues[indexPath.row].name
        }
          return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactDetail: ContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetail") as! ContactDetail
        let sectionKey = sectionTitle[indexPath.section]
        let contact: Contact = (contactsDict[sectionKey]?[indexPath.row])!
        contactDetail.thisContact = contact
        self.navigationController?.pushViewController(contactDetail, animated: true)
    }
}



