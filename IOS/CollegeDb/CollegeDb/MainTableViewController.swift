import UIKit

class MainTableViewController: UITableViewController {
    
    let operations = ["Add a student", "Find a student", "Update a student", "Delete a student"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Database Operations"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = operations[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StudentViewController") as? StudentViewController {
            vc.operationType = operations[indexPath.row]  // ✅ Pass selected operation
            navigationController?.pushViewController(vc, animated: true)
        } else {
            print("❌ Error: Could not instantiate StudentViewController")
        }
    }

}
