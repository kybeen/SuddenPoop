//
//  MainViewController.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import UIKit

final class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brown
    }
}

// MARK: - Preview canvas 세팅
import SwiftUI

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainViewController
    
    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
    }
}

@available(iOS 13.0.0, *)
struct MainViewPreview: PreviewProvider {
    static var previews: some View {
        MainViewControllerRepresentable()
    }
}
