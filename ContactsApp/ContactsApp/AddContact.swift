//  AddContact.swift
//  ContactsApp
//  Created by Licious on 26/03/22.
import UIKit

protocol ContactProto: AnyObject {
    func addContact(newContact: Contact)
}
protocol EditProto: AnyObject {
    func editContact(editContact: Contact)
}
class AddContact: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var contactImage: UIImageView!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var emailField: UITextField!
    
    var isEdit: Bool = false
    var thisContact: Contact?
    weak var addDelegate: ContactProto?
    weak var editDelegate: EditProto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveContact))
        
        if isEdit == true {
            title = "Edit Contact"
        }
        else {
            title = "New Contact"
        }
        phoneNumField.delegate = self
        contactImage.image = UIImage(named: "ContactImage")
        firstNameField.text = thisContact?.firstName
        lastNameField.text = thisContact?.lastName
        phoneNumField.text = thisContact?.phone
        emailField.text = thisContact?.email
    }
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardObserver()
    }
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func saveContact() {
        var name: String!
        if (firstNameField.text=="" && lastNameField.text=="" && phoneNumField.text=="") {
            let alert = UIAlertController(title: "Required!!", message: "Enter either first name, last name or phone number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            if let firstTxt = firstNameField.text, !firstTxt.isEmpty {
                name = firstTxt
            } else if let firstTxt = lastNameField.text, !firstTxt.isEmpty {
                name = firstTxt
            } else if let firstTxt = phoneNumField.text, !firstTxt.isEmpty {
                name = firstTxt
            }
        }
        if let emailTxt = emailField.text, !emailTxt.isEmpty, isValidEmail(emailTxt) == false {
            let alert = UIAlertController(title: "Invalid", message: "Enter Valid Email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            let newContact = Contact(contactId: nextContactId, firstName: firstNameField.text ?? "", lastName: lastNameField.text ?? "", phone: phoneNumField.text ?? "", email: emailField.text ?? "", name: name)
            let editContact = Contact(contactId: thisContact?.contactId ?? 1, firstName: firstNameField.text ?? "", lastName: lastNameField.text ?? "", phone: phoneNumField.text ?? "", email: emailField.text ?? "", name: name)
           
            if isEdit == true {
                editDelegate?.editContact(editContact: editContact)
            } else {
                addDelegate?.addContact(newContact: newContact)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+"]
            return Set(string).isSubset(of: nums)
    }
}


extension UIViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotifications(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    func removeKeyboardObserver(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func keyboardNotifications(notification: NSNotification) {
        var txtFieldY : CGFloat = 0.0
        let spaceBetweenTxtFieldAndKeyboard : CGFloat = 5.0

        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        if let activeTextField = UIResponder.currentFirst() as? UITextField ?? UIResponder.currentFirst() as? UITextView {
            frame = self.view.convert(activeTextField.frame, from:activeTextField.superview)
            txtFieldY = frame.origin.y + frame.size.height
        }
        if let userInfo = notification.userInfo {
            
            let keyBoard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let keyBoardY = keyBoard!.origin.y
            let keyBoardHeight = keyBoard!.size.height

            var viewY: CGFloat = 0.0
            
            if keyBoardY >= UIScreen.main.bounds.size.height {
                viewY = 0.0
            } else {
                if txtFieldY >= keyBoardY {
                    viewY = (txtFieldY - keyBoardY) + spaceBetweenTxtFieldAndKeyboard

                    if viewY > keyBoardHeight { viewY = keyBoardHeight }
                }
            }
            self.view.frame.origin.y = -viewY
        }
    }
}
extension UIResponder {
    static weak var responder: UIResponder?
    static func currentFirst() -> UIResponder? {
        responder = nil
        UIApplication.shared.sendAction(#selector(trap), to: nil, from: nil, for: nil)
        return responder
    }
    @objc private func trap() {
        UIResponder.responder = self
    }
}
