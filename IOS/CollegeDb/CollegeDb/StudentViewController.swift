import UIKit
import SQLite3

class StudentViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var programTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!  // Ensure this is properly connected in Storyboard

    var db: OpaquePointer?
    var operationType: String? // This is passed from MainTableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = operationType ?? "Operation"

        print("✅ viewDidLoad started")

        if actionButton == nil {
            print("❌ actionButton is nil!")
        } else {
            print("✅ actionButton is connected!")
            actionButton.setTitle(operationType, for: .normal) // This line may be causing the crash
        }
    }


    func setupDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("okcollege.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Error opening database")
        } else {
            print("✅ Database opened successfully at \(fileURL.path)")
        }

        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS students (
            id TEXT PRIMARY KEY, 
            name TEXT, 
            program TEXT, 
            grade TEXT
        )
        """
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("❌ Error creating table")
        } else {
            print("✅ Table created successfully")
        }
    }


    @IBAction func performOperation(_ sender: UIButton) {
        print("🚀 Button clicked! Operation: \(operationType ?? "Unknown")")

        guard let operation = operationType else {
            print("❌ operationType is nil")
            return
        }

        switch operation {
            case "Add a student":
                print("🔹 Adding student...")
                saveStudent()
            case "Find a student":
                print("🔹 Finding student...")
                findStudent()
            case "Update a student":
                print("🔹 Updating student...")
                updateStudent()
            case "Delete a student":
                print("🔹 Deleting student...")
                deleteStudent()
            default:
                print("❌ Invalid operation selected")
        }
    }

    


    func saveStudent() {
        print("✅ Student added successfully2")
        let insertQuery = "INSERT INTO students (id, name, program, grade) VALUES (?, ?, ?, ?)"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, idTextField.text, -1, nil)
            sqlite3_bind_text(stmt, 2, nameTextField.text, -1, nil)
            sqlite3_bind_text(stmt, 3, programTextField.text, -1, nil)
            sqlite3_bind_text(stmt, 4, gradeTextField.text, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Student added successfully")
            }
        }
        sqlite3_finalize(stmt)
    }

    func findStudent() {
        let selectQuery = "SELECT name, program, grade FROM students WHERE id = ?"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, selectQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, idTextField.text, -1, nil)

            if sqlite3_step(stmt) == SQLITE_ROW {
                let name = sqlite3_column_text(stmt, 0)
                let program = sqlite3_column_text(stmt, 1)
                let grade = sqlite3_column_text(stmt, 2)

                nameTextField.text = name != nil ? String(cString: name!) : "Unknown"
                programTextField.text = program != nil ? String(cString: program!) : "Unknown"
                gradeTextField.text = grade != nil ? String(cString: grade!) : "0.0"

                print("✅ Student found: \(nameTextField.text ?? "Unknown"), \(programTextField.text ?? "Unknown"), \(gradeTextField.text ?? "0.0")")
            } else {
                print("❌ Student not found!")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to prepare SQL statement! Error: \(errorMessage)")
        }
        sqlite3_finalize(stmt)
    }


    func updateStudent() {
        let updateQuery = "UPDATE students SET name = ?, program = ?, grade = ? WHERE id = ?"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, updateQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, nameTextField.text, -1, nil)
            sqlite3_bind_text(stmt, 2, programTextField.text, -1, nil)
            sqlite3_bind_text(stmt, 3, gradeTextField.text, -1, nil)
            sqlite3_bind_text(stmt, 4, idTextField.text, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Student updated successfully")
            }
        }
        sqlite3_finalize(stmt)
    }

    func deleteStudent() {
        let deleteQuery = "DELETE FROM students WHERE id = ?"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, idTextField.text, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Student deleted successfully")
                nameTextField.text = ""
                programTextField.text = ""
                gradeTextField.text = ""
            }
        }
        sqlite3_finalize(stmt)
    }
}
