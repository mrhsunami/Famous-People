import UIKit

class FamousPeopleViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  let sqlManager = SQLDatabaseManager()
  var famousPeopleRows: [[String:String]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Opens a database file. Creates one if not found.
    sqlManager.openDatabase()
    
    // Runs getAllPeople method and assigns results to class property.
    if let results = sqlManager.getAllPeople() {
      famousPeopleRows = results
    }
    
  }
  
  func searchForPeople(withName name: String) {
    if let results = sqlManager.getAllPeople(withNameLike: name) {
      famousPeopleRows = results
      self.tableView.reloadData()
    }
  }
}

extension FamousPeopleViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return famousPeopleRows.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "nameAndBirthday")!
    let row = famousPeopleRows[indexPath.row]
    let keys = Array(row.keys).sorted { $0 < $1 }
    var cellNameLabelText = ""
    
    var birthdateLabelText = ""
    if let firstName = row[keys[1]], let lastName = row[keys[2]], let birthdate = row[keys[0]] {
      cellNameLabelText = "\(firstName) \(lastName)"
      birthdateLabelText = "Born: \(birthdate)"
    }
    cell.textLabel?.text = cellNameLabelText
    cell.detailTextLabel?.text = birthdateLabelText
    
    return cell
  }
}

extension FamousPeopleViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    guard let name = searchBar.text else {
      return
    }
    searchForPeople(withName: name)
  }
}
