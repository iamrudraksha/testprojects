//
//  IdeasListViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 23.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Modified by Volkov Alexander on 22.09.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
The type of the ideas list

- All: all ideas ordered by date
- New: only new ides
- My:  only my ideas
- Random:  all ideas randomly ordered
*/
enum IdeasListType {
    case All, New, My, Random
    
    /**
    Get string for UI
    
    - returns: the type title
    */
    func toString() -> String {
        switch self {
        case .All, .Random:
            return "ALL_IDEAS".localized()
        case .New:
            return "NEW_IDEAS".localized()
        case .My:
            return "MY_IDEAS".localized()
        }
    }
    
    /**
    Get message text for "Nothing found" state
    
    - returns: the message text
    */
    func getNothingFoundText() -> String {
        switch self {
        case .New:
            return "NO_NEW_IDEAS".localized()
        case .My:
            return "YOU_HAVE_NO_IDEAS".localized()
        default:
            return "NO_IDEAS".localized()
        }
    }
}

/// flag: true - need to reload the list from server after appear, false - just reload the table
var IdeasListViewControllerNeedToReload = false

/**
* Ideas List screen
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - support of changes in data source
* 1.2:
* - keyboard issue fix
*/
class IdeasListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
    IdeaDetailsContainerViewControllerDelegate {
    
    
    /*
    OPTION: true - will mark all ideas in the list as not new, false - will do nothing
    You can set this option to false to verify the widget on the home page - it will reflect the number of new ideas.
    */
    let OPTION_MARK_IDEAS_AS_NOT_NEW_WHEN_GO_BACK = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingFoundLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /// a list of ideas to show
    var ideas = [Idea]() {
        didSet {
            if self.ideas.count == 0 {
                self.nothingFoundLabel.hidden = false
                if self.searchString?.trim().isEmpty ?? true {
                    self.nothingFoundLabel.text = self.listType.getNothingFoundText()
                }
                else {
                    self.nothingFoundLabel.text = "NOTHING_FOUND".localized()
                }
            }
            else {
                self.nothingFoundLabel.hidden = true
            }
        }
    }
    
    var listType = IdeasListType.All
    
    /// the string to search
    var searchString: String?
    
    /// the search field
    var searchTextField: UITextField?
    
    /// flag: true - need to show search after next appear, false - do default actions
    var needToShowSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigation()
        initTable()
        initBackButtonFromChild()
        loadData()
    }
    
    /**
    Reload data and listen keyboard events
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Init navigation bar
        if needToShowSearch {
            showSearch(true)
        }
        else {
            initNavigation()
        }
        
        // Reload data
        if IdeasListViewControllerNeedToReload {
            IdeasListViewControllerNeedToReload = false
            loadData()
        }
        else {
            tableView.reloadData()
        }
    }
    
    /**
    Initialize navigation bar
    */
    func initNavigation() {
        initNavigationBarTitle(listType.toString().uppercaseString)
        initRightButtons([("iconPlus", "submitIdeaAction:"), ("iconSearch", "searchAction:")])
    }
    
    /**
    Initialize table
    */
    func initTable() {
        nothingFoundLabel.hidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInsetAndMarginsToZero()
    }
    
    /**
    Load ideas
    */
    func loadData() {
        loadingIndicator.startAnimating()
        IdeasDataSource.sharedInstance.getIdeas(forseReload: true, callback: { (var list: [Idea]) -> () in
            
            self.loadingIndicator.stopAnimating()
            
            // Filter with list type
            switch self.listType {
            case .New:
               list = Idea.filterNewIdeas(list)
            case .My:
                list = Idea.filterMyIdeas(list)
            default: break
            }
            
            var sorted: [Idea]!
            // Random sort
            if self.listType == .Random {
                sorted = list.sort({ (i1: Idea, i2: Idea) -> Bool in
                    return Bool.random()
                })
            }
            // Sort by date descending
            else {
                sorted = list.sort({ $0.created.compare($1.created) == NSComparisonResult.OrderedDescending })
            }
            if let str = self.searchString?.lowercaseString {
                if !str.trim().isEmpty {
                    sorted = sorted.filter({ $0.title.lowercaseString.contains(str)
                        || $0.text.lowercaseString.contains(str) })
                }
            }
            self.ideas = sorted
            self.tableView.reloadData()
            
        }) { (error: RestError, res: RestResponse?) -> () in
            self.loadingIndicator.stopAnimating()
            error.showError()
        }
    }
    
    /**
    Mark all ideas from the list as not new
    */
    override func backButtonAction() {
        if OPTION_MARK_IDEAS_AS_NOT_NEW_WHEN_GO_BACK {
            IdeasDataSource.sharedInstance.markIdeasAsNotNew(self.ideas)
        }
        searchTextField?.resignFirstResponder()
        super.backButtonAction()
    }

    // MARK: Button actions
    
    /**
    "Search" button action handler
    
    - parameter sender: the button
    */
    func searchAction(sender: AnyObject) {
        showSearch(true)
    }
    
    /**
    Show/hide search field
    
    - parameter needToShow: flag: true - need to show search field, false - hide
    */
    func showSearch(needToShow: Bool) {
        needToShowSearch = needToShow
        if needToShow {
            searchTextField = self.navigationController?.setNavigationForSearching("Search actions", delegate: self)
            searchTextField?.returnKeyType = .Search
            if let str = searchString {
                searchTextField?.text = str
            }
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Cancel".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: "cancelSearch:")]
            searchTextField?.becomeFirstResponder()
        }
        else {
            searchString = nil
            initNavigation()
        }
    }
    
    /**
    Remove search field and show all ideas
    
    - parameter sender: the button
    */
    func cancelSearch(sender: AnyObject) {
        searchString = nil
        self.searchTextField?.text = searchString
        self.loadData()
        showSearch(false)
    }
    
    /**
    Dismiss keyboard of user tap on the screen.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        searchTextField?.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    /**
    "Plus" button action handler
    
    - parameter sender: the button
    */
    func submitIdeaAction(sender: AnyObject) {
        openSubmitIdeaScreen()
    }
    
    // MARK: IdeaDetailsContainerViewControllerDelegate
    
    /**
    Get next idea from given
    
    - parameter referenceIdea: the reference idea
    
    - returns: the next idea
    */
    func getNextIdea(referenceIdea: Idea) -> Idea? {
        var useNextIdea = false
        for idea in ideas {
            if useNextIdea {
                return idea
            }
            if idea.id == referenceIdea.id {
                useNextIdea = true
            }
        }
        return nil
    }
    
    /**
    Get previous idea from given
    
    - parameter referenceIdea: the reference idea
    
    - returns: the previous idea
    */
    func getPreviousIdea(referenceIdea: Idea) -> Idea? {
        var previousIdea: Idea?
        for idea in ideas {
            if idea.id == referenceIdea.id {
                return previousIdea
            }
            previousIdea = idea
        }
        return nil
    }
    
    /**
    Show search field
    */
    func showSearch() {
        needToShowSearch = true
    }
    
    // MARK: UITextFieldDelegate (Search field)
    
    /**
    Update search results when text is changed
    
    - parameter textField: the textField
    - parameter range:     the range to replace the string
    - parameter string:    the string to replace in the range
    
    - returns: true
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            var text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            text = text.lowercaseString
            updateSearchResultsWithText(text)
            return true
    }
    
    /**
    Dismiss keyboard
    
    - parameter textField: the search text field
    
    - returns: true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextField?.resignFirstResponder()
        return true
    }
    
    /**
    Update search results
    
    - parameter textField:  the search text field
    */
    func textFieldDidEndEditing(textField: UITextField) {
        updateSearchResultsWithText(textField.text!)
    }
    
    /**
    Updates table to show search results
    
    - parameter string: the search string
    */
    func updateSearchResultsWithText(string: String) {
        self.searchString = string
        loadData()
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    /**
    Number of cells (corresponds to the number of ideas)
    
    - parameter tableView: the tableView
    - parameter section:   the section index (zero)
    
    - returns: the number of cells
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    /**
    Create a cell for given indexPath
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: the cell
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IdeasTableViewCell", forIndexPath: indexPath) as! IdeasTableViewCell
        cell.idea = ideas[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    /**
    Idea selection handler
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath that is selected
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let idea = ideas[indexPath.row]
        if let vc = create(IdeaDetailsContainerViewController.self) {
            vc.idea = idea
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}

/**
*  Idea formatters
*/
struct IdeaFormatters {
    static var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "MMM dd"
        return f
    }()
}

/**
* Cell for an idea
*
* @author Alexander Volkov
* @version 1.0
*/
class IdeasTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ideaLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var newView: UIView!
    
    /// Related idea object. Updates UI when set.
    var idea: Idea! {
        didSet {
            ideaLabel.text = idea.title
            if let name = idea.submitter {
                userNameLabel.text = name
            }
            else {
                userNameLabel.text = "Anonymous".localized()
            }
            
            isNew = idea.isNew
            timeLabel.text = idea.getDateString()
        }
    }
    
    /// updates UI to reflect the idea novelty
    var isNew: Bool = false {
        didSet {
            newView.hidden = !isNew
        }
    }
    
    /// fix table separator
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
    
    /**
    Make "New" label to have round corners
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        newView.layer.cornerRadius = 5
        newView.layer.masksToBounds = true
    }
}