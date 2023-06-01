import Messages
import UIKit
import SwiftUI

class MessagesViewController: MSMessagesAppViewController {
    var controller = UIViewController()
    var gameType: GameType = .urobo
    var zegzugMenuShowing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    private func presentVC(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let gameType = GameType(rawValue: conversation.selectedMessage?.summaryText ?? "") ?? gameType
        if presentationStyle == .compact {
            if gameType == .zegzug && zegzugMenuShowing {
                controller = instantiateZegzugMenuVC()
            } else {
                controller = instantiateMenuVC()
            }
        } else {
            switch gameType {
            case .urobo:
                controller = instantiateUroboVC()
            case .zegzug:
                controller = instantiateZegzugVC(with: ZegzugState(message: conversation.selectedMessage) ?? ZegzugState())
            }
        }

        show(controller: controller)
    }

    private func show(controller: UIViewController) {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        controller.didMove(toParent: self)
    }

    private func instantiateMenuVC() -> UIViewController {
        let viewModel = MenuViewModel()
        viewModel.delegate = self
        return UIHostingController(rootView: MenuScreen(viewModel: viewModel))
    }

    private func instantiateUroboVC() -> UIViewController {
        let viewModel = UroboGameViewModel()
        return UIHostingController(rootView: UroboGameScreen(viewModel: viewModel))
    }

    private func instantiateZegzugVC(with state: ZegzugState) -> UIViewController {
        let viewModel = ZegzugGameViewModel(state: state)
        viewModel.delegate = self
        return UIHostingController(rootView: ZegzugGameView(viewModel: viewModel))
    }

    private func instantiateZegzugMenuVC() -> UIViewController {
        let viewModel = ZegzugGameViewModel(state: ZegzugState())
        viewModel.delegate = self
        let menu = ZegzugMenu(viewModel: viewModel) { [weak self] in
            guard let self else { return }
            show(controller: instantiateMenuVC())
        }
        return UIHostingController(rootView: menu)
    }
}

// MARK: Conversation handling
extension MessagesViewController {
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.

        // Use this method to configure the extension and restore previously stored state.
        presentVC(for: conversation, with: presentationStyle)
    }

    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.

        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.

        // Use this method to trigger UI updates in response to the message.
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.

        // Use this to clean up state related to the deleted message.
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.

        // Use this method to prepare for the change in presentation style.
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.

        // Use this method to finalize any behaviors associated with the change in presentation style.

        guard let conversation = activeConversation else {
            fatalError("Expected the active conversation")
        }

        presentVC(for: conversation, with: presentationStyle)
    }
}

extension MessagesViewController: MenuViewModelDelegate {
    func startUrobo() {
        self.gameType = .urobo
        requestPresentationStyle(.expanded)
    }

    func startZegZug() {
        gameType = .zegzug
        zegzugMenuShowing = true

        controller = instantiateZegzugMenuVC()
        show(controller: controller)
    }
}

extension MessagesViewController: ZegzugGameViewModelDelegate {
    func endTurn(with state: ZegzugState, isInitial: Bool) {
        dismiss()

        let conversation = activeConversation
        let session = conversation?.selectedMessage?.session ?? MSSession()

        var components = URLComponents()
        components.queryItems = state.queryItems

        let layout = MSMessageTemplateLayout()
        // TODO: set layout.image
        if state.didWin {
            layout.caption = "\(state.sender?.num.rawValue.capitalized ?? "A") player won!"
        } else if isInitial {
            layout.caption = "Let's play ZegZug!"
        } else {
            layout.caption = "Opponent moved. Your turn!"
        }

        let message = MSMessage(session: session)
        message.url = components.url!
        message.layout = layout
        message.summaryText = GameType.zegzug.name

        conversation?.insert(message) { error in
            if let error {
                print("Error sending message: \(error)")
            }
        }
    }
}
