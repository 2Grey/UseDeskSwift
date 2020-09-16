//
//  UDArticlesView.swift

import Foundation
import UIKit

class UDArticlesView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    
    weak var usedesk: UseDeskSDK?
    var url: String?
    var arrayArticles: [ArticleTitle] = []
    var searchArticles: SearchArticle?
    var isSearch: Bool = false
    var collection_ids: Int = 0
    var category_ids: Int = 0
    var navigationView = UIView()
    var isViewDidLayout: Bool = false
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: chatButtonText, style: .done, target: self, action: #selector(self.actionChat))
        self.navigationView = UIView(frame: navigationController?.navigationBar.bounds ?? .zero)
        self.navigationItem.titleView = self.navigationView

        self.searchBar = UISearchBar()
        self.searchBar.placeholder = searchBarPlaceholderText
        self.searchBar.tintColor = searchBarTintColor
        self.searchBar.delegate = self
        self.navigationView.addSubview(self.searchBar)
        
        tableView.register(UINib(nibName: "UDArticleViewCell", bundle: nil), forCellReuseIdentifier: "UDArticleViewCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !self.isViewDidLayout {
            self.searchBar.frame = navigationItem.titleView?.frame ?? CGRect.zero
            self.isViewDidLayout = true
        }
    }
    
    // MARK: - User actions

    @objc func actionChat() {
        guard let usedesk = usedesk, let config = usedesk.config else { return }

        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        usedesk.startWithoutGUICompanyID(with: config) { [weak self] success, error in
            guard let wSelf = self else { return }

            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC = DialogflowView()
                    dialogflowVC.usedesk = wSelf.usedesk
                    dialogflowVC.isFromBase = true
                    wSelf.navigationController?.pushViewController(dialogflowVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                })
            } else {
                if error == "noOperators" {
                    let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
                    if let url = wSelf.url {
                        offlineVC.url = url
                    }
                    offlineVC.usedesk = wSelf.usedesk
                    wSelf.navigationController?.pushViewController(offlineVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                }
            }
        }
    }
    
    // MARK: - TableView

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            if let searchArticles = self.searchArticles {
                return searchArticles.articles.count
            } else {
                return 0
            }
        } else {
            return self.arrayArticles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDArticleViewCell", for: indexPath) as! UDArticleViewCell
        if isSearch {
            if let searchArticles = self.searchArticles {
                cell.textView.text = searchArticles.articles[indexPath.row].title
                cell.viewsLabel.text = "\(searchArticles.articles[indexPath.row].views) просмотров"
            } else {
                cell.textView.text = ""
            }
        } else {
            cell.textView.text = arrayArticles[indexPath.row].title
            cell.viewsLabel.text = "\(arrayArticles[indexPath.row].views) просмотров"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var id: Int = 0
        if isSearch {
            id = (searchArticles?.articles[indexPath.row].id)!
        } else {
            id = arrayArticles[indexPath.row].id
        }
        usedesk?.addViewsArticle(articleID: id, count: 1, connectionStatus: { success, error in
            
        })
        
        usedesk?.getArticle(articleID: id, connectionStatus: { [weak self] success, article, error in
            guard let wSelf = self else { return }
            if success {
                let articleVC = UDArticleView(nibName: "UDArticle", bundle: nil)
                articleVC.usedesk = wSelf.usedesk
                articleVC.article = article
                articleVC.url = wSelf.url
                wSelf.navigationController?.pushViewController(articleVC, animated: true)
            }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    // MARK: - SearchBar

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
            }
            usedesk?.getSearchArticles(collection_ids: [collection_ids], category_ids: [category_ids], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) { [weak self] success, searchArticle, error in
                guard let wSelf = self else { return }
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
                if success {
                    wSelf.searchArticles = searchArticle
                    wSelf.isSearch = true
                    wSelf.tableView.reloadData()
                } else {
                    wSelf.isSearch = false
                    wSelf.tableView.reloadData()
                }
            }
        } else {
            isSearch = false
            tableView.reloadData()
        }
    }
}
