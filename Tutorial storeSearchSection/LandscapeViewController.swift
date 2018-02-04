//
//  LandscapeViewController.swift
//  Tutorial storeSearchSection
//
//  Created by HuangMing on 2018/1/30.
//  Copyright © 2018年 passtwth. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults: [SearchResult] = []
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask]()
    var search: Search!
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControl.numberOfPages = 0
        
       
        // Do any additional setup after loading the view.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            switch search.state {
            case .loading :
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            case .notSearchedYet:
                break
            case .results(let list):
                tileButton(list)
            }
            
        }
    }
    private func tileButton(_ searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        let viewWidth = scrollView.bounds.size.width
        switch viewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowPerPage = 4
            itemWidth = 92
        default:
            break
        }
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let peddingHorz = (itemWidth - buttonWidth) / 2
        let peddingVert = (itemHeight - buttonHeight) / 2
        
        var row = 0
        var col = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            //button.backgroundColor = UIColor.white
            //button.setTitle("\(index)", for: .normal)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            button.frame = CGRect(x: x + peddingHorz, y: marginY + CGFloat(row) * itemHeight + peddingVert, width: buttonWidth, height: buttonHeight)
            scrollView.addSubview(button)
            downloadImage(for: result, andPlaceOn: button)
            row += 1
            if row == rowPerPage {
                row = 0 ; x += itemWidth ; col += 1
                if col == columnsPerPage {
                    col = 0 ; x += marginX * 2
                }
            }
        }
        let buttonPerPage = rowPerPage * columnsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
        print("pages: \(numPages)")
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
    }
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url, completionHandler: { [weak button] url, res, error in
                if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            })
            task.resume()
            downloads.append(task)
        }
    }
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel()
        }
        
    }
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinner.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    func searchResultsReceived() {
        hideSpinner()
        switch search.state {
        case .loading,.notSearchedYet:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButton(list)
        }
    }
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Nothing Found"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.sizeToFit()
        var rect = label.frame
        rect.size.width = ceil(rect.size.width / 2) * 2
        rect.size.height = ceil(rect.size.height / 2) * 2
        label.frame = rect
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        view.addSubview(label)
        
    }
    @objc func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailVC = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000 ]
                detailVC.searchResult = searchResult
            }
        }
        
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)

        pageControl.currentPage = page
    }
}

