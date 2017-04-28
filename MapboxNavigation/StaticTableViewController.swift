import UIKit

class TableViewItem: NSObject {
    typealias ActionHandler = () -> ()
    typealias ToggledHandler = (UISwitch) -> ()
    typealias ToggledStateHandler = (UISwitch) -> (Bool)
    var title: String
    var image: UIImage?
    var didSelectHandler: ActionHandler?
    var didToggleHandler: ToggledHandler?
    var toggledStateHandler: ToggledStateHandler?
    
    init(_ title: String) {
        self.title = title
    }
}

typealias TableViewSection = [TableViewItem]

class StaticTableViewController: UITableViewController {

    var data = [TableViewSection]()
    
    let cellReuseIdentifier = "StaticTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! StaticTableViewCell

        let item = data[indexPath.section][indexPath.row]
        cell.titleLabel.text = item.title
        
        cell.iconImageView.image = item.image
        cell.iconImageView.sizeToFit()
        
        let isToggleable = (item.didToggleHandler != nil)
        
        if isToggleable {
            let toggleView = ToggleView()
            toggleView.addTarget(self, action: #selector(didToggle(_:)), for: .valueChanged)
            
            if let handler = item.toggledStateHandler {
                toggleView.isOn = handler(toggleView)
            }
            
            cell.accessoryView = toggleView
        } else {
            cell.accessoryView = nil
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = data[indexPath.section][indexPath.row]
        item.didSelectHandler?()
    }
    
    func didToggle(_ sender: UISwitch) {
        guard let cell = sender.superview as? UITableViewCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let toggleView = cell.accessoryView as? UISwitch else { return }
        
        let item = data[indexPath.section][indexPath.row]
        item.didToggleHandler?(toggleView)
    }
}