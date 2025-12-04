//
//  BrowseViewController.swift
//  CoreBlast
//
//  Created by Claude on 12/1/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var categories: [WorkoutCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Browse"
        view.backgroundColor = .black
        
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(WorkoutCategoryCell.self, forCellWithReuseIdentifier: WorkoutCategoryCell.identifier)
        collectionView.register(BrowseSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BrowseSectionHeader.identifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadCategories() {
        categories = WorkoutCategoryManager.getAllCategories()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension BrowseViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return WorkoutCategorySection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = WorkoutCategorySection(rawValue: section) else { return 0 }
        return categories.filter { $0.section == sectionType }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkoutCategoryCell.identifier, for: indexPath) as! WorkoutCategoryCell
        
        guard let sectionType = WorkoutCategorySection(rawValue: indexPath.section) else { return cell }
        let sectionCategories = categories.filter { $0.section == sectionType }
        
        if indexPath.item < sectionCategories.count {
            cell.configure(with: sectionCategories[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BrowseSectionHeader.identifier, for: indexPath) as! BrowseSectionHeader
            
            if let sectionType = WorkoutCategorySection(rawValue: indexPath.section) {
                header.configure(with: sectionType.title)
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BrowseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let interItemSpacing: CGFloat = 16
        let availableWidth = collectionView.frame.width - (padding * 2) - interItemSpacing
        let itemWidth = availableWidth / 2
        let itemHeight: CGFloat = 160
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = WorkoutCategorySection(rawValue: indexPath.section) else { return }
        let sectionCategories = categories.filter { $0.section == sectionType }
        
        if indexPath.item < sectionCategories.count {
            let category = sectionCategories[indexPath.item]
            navigateToCategory(category)
        }
    }
    
    private func navigateToCategory(_ category: WorkoutCategory) {
        let workoutListVC = WorkoutListViewController(category: category)
        navigationController?.pushViewController(workoutListVC, animated: true)
    }
}