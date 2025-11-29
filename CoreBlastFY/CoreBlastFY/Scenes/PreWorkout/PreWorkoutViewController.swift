//
//  PreWorkoutViewController.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 1/25/20.
//  Copyright (c) 2020 Riccardo Washington. All rights reserved.
//

import UIKit
import MediaPlayer

protocol PreWorkoutDisplayLogic: AnyObject {
    func displayPreWorkoutViewModel(viewModel: PreWorkout.FetchUser.ViewModel)
}

class PreWorkoutViewController: UIViewController, PreWorkoutDisplayLogic
{
    var interactor: (PreWorkoutBusinessLogic& PreWorkoutDataStore)?
    var router: (NSObjectProtocol & PreWorkoutRoutingLogic & PreWorkoutDataPassing)?
    
    var displayedPreWorkoutData: PreWorkout.FetchUser.ViewModel.UserDetails?
    var firstWorkout: String?
    var videoURL: URL?
    
    // MARK: Views
    
    private var preworkoutView: PreWorkoutView?
    private var loadingView: LoadingView?
    private var loadingSpinner: UIActivityIndicatorView?
    private var exerciseLoadingView: ExercisesLoadingView?
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Routing
    
    func routeToWorkoutScene() {
        // Check if user has hit the workout limit and needs subscription
        if shouldShowPaywall() {
            showHardPaywall()
            return
        }
        
        router?.routeToWorkoutScene()
    }
    
    private func shouldShowPaywall() -> Bool {
        let completedWorkouts = UserDefaults.standard.integer(forKey: "completedWorkoutsCount")
        let hasSubscribed = UserDefaults.standard.bool(forKey: "hasSubscribed")
        let isPremium = StoreManager.shared.isPremium
        
        return completedWorkouts >= 3 && !hasSubscribed && !isPremium
    }
    
    private func showHardPaywall() {
        let subscriptionView = HostingViewController(view: SubscriptionView() { [weak self] success in
            if success {
                UserDefaults.standard.set(true, forKey: "hasSubscribed")
                // User subscribed, now they can start the workout
                self?.dismiss(animated: true) {
                    self?.router?.routeToWorkoutScene()
                }
            } else {
                // Hard paywall - user must subscribe
                self?.dismiss(animated: true) {
                    self?.showSubscriptionRequiredAlert()
                }
            }
        })
        
        subscriptionView.modalPresentationStyle = .fullScreen
        present(subscriptionView, animated: true)
    }
    
    private func showSubscriptionRequiredAlert() {
        let alert = UIAlertController(
            title: "Subscription Required",
            message: "You've completed your 3 free workouts! Subscribe to unlock unlimited access to all workouts and features.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default) { [weak self] _ in
            self?.showHardPaywall()
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func removeLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
    private func displayLoadingView() {
        loadingView = LoadingView(frame: .zero, nextExercise: firstWorkout ?? "", secondsOfRest: interactor?.workout?.secondsOfRest ?? 10, videoURL: videoURL, isFirstWorkout: true)
        view.addSubview(loadingView!)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        preworkoutView?.alpha = 0
        preworkoutView?.isHidden = true
        loadingView!.translatesAutoresizingMaskIntoConstraints = false
        loadingView!.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingView!.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loadingView!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loadingView!.runTimer { [weak self] in
            self?.removeLoadingView()
            self?.routeToWorkoutScene()
        }
    }
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObservers()
        interactor?.exercises = ExerciseStorage.exercises
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        setupCustomWorkoutIcon()
        self.navigationController?.navigationBar.isHidden = false
        fetchUserInfo()
        interactor?.fetchWorkout(request: WorkoutInfo.FetchWorkout.Request(exercises: interactor!.exercises))
        setFirstWorkout()
        
        self.tabBarController?.tabBar.isHidden = false
        
        customWorkoutIcon.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove custom buttons when leaving this view controller
        removeCustomNavigationElements()
    }
    
    private func removeCustomNavigationElements() {
        customWorkoutIcon.removeFromSuperview()
        tipIcon.removeFromSuperview()
        
        // Also clear any bar button items we might have set
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = PreWorkoutInteractor()
        let presenter = PreWorkoutPresenter()
        let router = PreWorkoutRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.preWorkoutDataStore = interactor
        setupNavigationBar()
        
    }
    
    private func setFirstWorkout() {
        let firstWorkout = interactor?.workout?.exercisesToReturn.first
        self.firstWorkout = firstWorkout?.name.capitalized
        self.videoURL = firstWorkout?.videoURL
       
    }
        
    private let tipIcon = UIButton(type: .detailDisclosure)
    
    private let customWorkoutIcon = UIButton(title: "Custom Workout")
    
    private func setupCustomWorkoutIcon() {
        let image = UIImage(systemName: "plus")
        customWorkoutIcon.setImage(image, for: .normal)
        customWorkoutIcon.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        customWorkoutIcon.backgroundColor = UIColor.goatBlack.withAlphaComponent(0.5)
        customWorkoutIcon.imageView?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        customWorkoutIcon.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        customWorkoutIcon.layer.cornerRadius = 12
        customWorkoutIcon.tintColor = .goatBlue
        customWorkoutIcon.addTarget(self, action: #selector(customWorkout), for: .touchDown)
        customWorkoutIcon.contentVerticalAlignment = .fill
        customWorkoutIcon.contentHorizontalAlignment = .fill
        
        addCustomWorkoutIcon()
        
    }
    
    private func setupTipIcon() {
        tipIcon.tintColor = .goatBlue
        tipIcon.addTarget(self, action: #selector(showTip), for: .touchDown)
        tipIcon.contentVerticalAlignment = .fill
        tipIcon.contentHorizontalAlignment = .fill
        
        addTipIcon()
    }
    
    private func addTipIcon() {
        if !(navigationController?.navigationBar.subviews.contains(tipIcon))!  {
            navigationController?.navigationBar.addSubview(tipIcon)
            tipIcon.centerYInSuperview()
            tipIcon.trailingAnchor.constraint(equalTo:  (navigationController?.navigationBar.trailingAnchor)!, constant: -8).isActive = true
            tipIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            tipIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        
    }
    
    private func addCustomWorkoutIcon() {
        if !(navigationController?.navigationBar.subviews.contains(customWorkoutIcon))!  {
            navigationController?.navigationBar.addSubview(customWorkoutIcon)
            customWorkoutIcon.centerYInSuperview()
            customWorkoutIcon.trailingAnchor.constraint(equalTo:  (navigationController?.navigationBar.trailingAnchor)!, constant: -8).isActive = true
        }
    }
    
    @objc private func customWorkout() {
        
        let destination = CustomWorkoutViewController()
        navigationController?.pushViewController(destination, animated: true)
        customWorkoutIcon.isHidden = true
       // self.show(destination, sender: nil)
    
    }
    
    
    @objc private func showTip() {
        AlertController.createAlert(errorMessage: "Warming up or jogging for 10 minutes prior to workout will greatly increase productivity of workout!", title: "Workout Tip", viewController: self)
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(workoutComplete), name: workoutCompleteNotification2, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWorkoutVC), name: exerciseLoadedNotification, object: nil)
    }
    
    @objc private func workoutComplete() {
        navigationController?.popToViewController(self, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setNeedsDisplay()
        AlertController.createAlert(errorMessage: "Keep up the hard work!\nConsistency is key!", title: "Congratulations 💪", viewController: self, actionTitle: "🎯")
    }
    
    @objc private func showWorkoutVC() {
        fetchUserInfo()
        DispatchQueue.main.async { [weak self] in
            self?.exerciseLoadingView?.removeFromSuperview()
            self?.exerciseLoadingView = nil
            self?.preworkoutView?.isUserInteractionEnabled = true
            self?.view.setNeedsLayout()
        }
    }
    
    
   // private let musicButton = UIButton(type: .detailDisclosure)
    //UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playMusic))
    
//    private func setupMusicButton() {
//        musicButton.tintColor = .goatBlue
//        musicButton.addTarget(self, action: #selector(playMusic), for: .touchDown)
//        addMusicButton()
//
//    }
//
    
    
    private func removeItemsFromNavBar() {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationController?.navigationBar.setNeedsDisplay()
            
        }
    }
    
//    private func addMusicButton() {
//        if !(navigationController?.navigationBar.subviews.contains(musicButton))!  {
//            navigationController?.navigationBar.addSubview(musicButton)
//            musicButton.centerYInSuperview()
//            musicButton.leadingAnchor.constraint(equalTo:  (navigationController?.navigationBar.leadingAnchor)!, constant: 8).isActive = true
//            musicButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
//            musicButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
//        }
//        //        if navigationItem.leftBarButtonItem == nil {
//        //            navigationItem.leftBarButtonItem = musicButton
//        //
//        //        }
//    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Workout"
        view.backgroundColor = .black
    }
    
    @objc private func startWorkout() {
        router?.routeToExercisePreview()
    }
    
    private func setupPreWorkoutUI(viewModel: PreWorkout.FetchUser.ViewModel) {
        
        if let pwv = preworkoutView, view.subviews.contains(pwv) {
            preworkoutView?.removeFromSuperview()
            preworkoutView = nil
        }
        preworkoutView = PreWorkoutView(viewModel: viewModel)
        guard let preworkoutView = preworkoutView else { return }
        view.addSubview(preworkoutView)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(startWorkout))
        preworkoutView.addGestureRecognizer(gesture)
        
        preworkoutView.preWorkoutViewController = self
        preworkoutView.translatesAutoresizingMaskIntoConstraints = false
        preworkoutView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        preworkoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        preworkoutView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        preworkoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        //TO DO: - use reusable version
        //        if let user = UserAPI.user, user.totalPoints > user.la
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.preworkoutView?.totalPointsLevel.transform = CGAffineTransform(scaleX: 5, y: 5)
            self?.preworkoutView?.totalPointsLevel.transform = .identity
        }
        
        if ExerciseStorage.exercises.count <= 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.exerciseLoadingView = ExercisesLoadingView()
                self.preworkoutView?.addSubview(self.exerciseLoadingView!)
                self.exerciseLoadingView?.fillSuperview()
                self.preworkoutView?.isUserInteractionEnabled = false
            }
        }
        
    }
    
    // MARK: Do something
    
    func displayPreWorkoutViewModel(viewModel: PreWorkout.FetchUser.ViewModel) {
        let viewModel = viewModel
        setupPreWorkoutUI(viewModel: viewModel)
    }
    
    private func displayLoadingSpinner() {
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner?.color = .lightGray
        loadingSpinner?.startAnimating()
        view.addSubview(loadingSpinner!)
        
        loadingSpinner?.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingSpinner?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    private func removeLoadingSpinner() {
        loadingSpinner?.stopAnimating()
        loadingSpinner?.removeFromSuperview()
        loadingSpinner = nil
    }
    
    private func fetchUserInfo() {
        let request = PreWorkout.FetchUser.Request()
        interactor?.fetchUserInfo(request: request)
    }
}

//extension PreWorkoutViewController: MPMediaPickerControllerDelegate {
//
//    @objc func playMusic(_ sender: UIButton) {
//        print("button tapped")
//        sender.isUserInteractionEnabled = false
//        let controller = MPMediaPickerController(mediaTypes: .music)
//        controller.overrideUserInterfaceStyle = .dark
//        controller.delegate = self
//        controller.allowsPickingMultipleItems = true
//        controller.popoverPresentationController?.sourceView = sender
//        sender.isUserInteractionEnabled = true
//        present(controller, animated: true)
//    }
//
//    func mediaPicker(_ mediaPicker: MPMediaPickerController,
//                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//
////        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
//        musicPlayer.setQueue(with: .songs())
//        musicPlayer.prepareToPlay()
//        mediaPicker.dismiss(animated: true)
//        musicPlayer.play()
//    }
//
//    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
//        mediaPicker.dismiss(animated: true)
//    }
//}
