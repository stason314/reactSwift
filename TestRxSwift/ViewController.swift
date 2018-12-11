//
//  ViewController.swift
//  TestRxSwift
//
//  Created by Stanislav on 10/12/2018.
//  Copyright © 2018 Bytepace. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let cities = ["Omsk", "Novosib", "Moscow"]
    private var shownData = [String]()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBinds()
    }
    
    private func setup() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: kTestTextTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: kTestTextTableViewCellIdentifier)
        
        // Use them like regular Swift objects
        let city = City()
        city.name = "ОМСК"
        
        // Get the default Realm
        let config = Realm.Configuration(objectTypes: [City.self])
        let realm = try! Realm(configuration: config)
        
        // Query Realm for all dogs less than 2 years old
        let puppies = realm.objects(City.self).filter(NSPredicate(format: "name CONTAINS[cd] %@", "оМ"))
//        let puppies = realm.objects(City.self).filter("name contains 'Ом'")
        puppies.count // => 0 because no dogs have been added to the Realm yet
        
        // Persist your data easily
        try! realm.write {
            realm.add(city)
        }
        
        // Queries are updated in realtime
        print(puppies.count) // => 1
        
        // Query and update from any thread
//        DispatchQueue(label: "background").async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let theDog = realm.objects(Сity.self).filter("age == 1").first
//                try! realm.write {
//                    theDog!.age = 3
//                }
//            }
//        }

    }
    
    private func setupBinds() {
        searchBar.rx
            .text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                self.shownData = self.cities.filter({ $0.hasPrefix(query) })
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dequeueTestCell(for: indexPath)
    }
    
    private func dequeueTestCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kTestTextTableViewCellIdentifier) as? TestTextTableViewCell else { fatalError() }
        cell.textLabel?.text = shownData[indexPath.row]
        return cell
    }
    
}

