//
//  MainView.swift
//  SuddenPoopSaver
//
//  Created by 김영빈 on 2023/10/25.
//

import UIKit

final class MainView: UIView {

    let testLabel: UILabel = {
        let testLabel = UILabel()
        testLabel.text = "테스트"
        return testLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTestLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setTestLabel() {
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(testLabel)
        NSLayoutConstraint.activate([
            testLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            testLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            testLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            testLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
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
