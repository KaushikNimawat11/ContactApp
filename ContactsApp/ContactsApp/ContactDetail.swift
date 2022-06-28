//  ContactDetail.swift
//  ContactsApp
//  Created by Licious on 30/03/22
import UIKit
class ContactDetail: UIViewController, EditProto {
    
    func editDict(contact: Contact) {
        if let index = contactsArray.firstIndex(where: {$0.contactId == contact.contactId})
        {
            contactsArray[index] = contact
            createDict(contacts: contactsArray)
        }
    }
    
    var contact: Contact!
    func editContact(editContact: Contact) {
        contact = editContact
        editDict(contact: contact)
    }
    
    @IBOutlet var contactImageView: UIImageView!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    var thisContact: Contact!
    @IBOutlet var nameView: UIView!
    @IBOutlet var numberView: UIView!
    @IBOutlet var emailView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactImageView.image = UIImage(named: "ContactImage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        nameView.layer.cornerRadius = 10
        numberView.layer.cornerRadius = 10
        emailView.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if contact != nil {
            thisContact = contact
        }
        fullNameLabel.text = thisContact.firstName + " " + thisContact.lastName
        phoneNumberLabel.text = thisContact.phone
        emailLabel.text = thisContact.email
    }
    
    @IBAction func deleteContact(_ sender: ViewController) {
        if let index = contactsArray.firstIndex(where: {$0.contactId == thisContact.contactId})
        {
            contactsArray.remove(at: index)
            createDict(contacts: contactsArray)
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func didTapEdit() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let editContact: AddContact = mainStoryBoard.instantiateViewController(withIdentifier: "AddContact") as! AddContact
        editContact.thisContact = thisContact
        editContact.isEdit = true
        editContact.editDelegate = self
        let navigationController = UINavigationController(rootViewController: editContact)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}
