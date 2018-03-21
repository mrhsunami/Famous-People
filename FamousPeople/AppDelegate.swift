import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func applicationDidFinishLaunching(_ application: UIApplication) {
    
    // Uses NSUserDefault to track whether data has ben added or not
    let isPreloaded = UserDefaults.standard.bool(forKey: "initial_data_added_to_database")
    if !isPreloaded {
      UserDefaults.standard.set(true, forKey: "initial_data_added_to_database")
      let databaseManager = SQLDatabaseManager()
      databaseManager.openDatabase()
      databaseManager.setupData() //this fills out the tables with default values
    
    }
  }

}

