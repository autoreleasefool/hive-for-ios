//
//  GameViewModel.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-01-24.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import SwiftUI
import Combine
import HiveEngine
import Loaf

enum GameViewAction: BaseViewAction {
	case onAppear(User.ID?, ClientInteractor, Preferences)
	case viewContentDidLoad(GameViewContent)
	case viewContentReady
	case viewInteractionsReady

	case presentInformation(GameInformation)
	case closeInformation(withFeedback: Bool)

	case openHand(Player)
	case selectedFromHand(Player, Piece.Class)
	case enquiredFromHand(Piece.Class)
	case tappedPiece(Piece)
	case tappedGamePiece(Piece)

	case toggleEmojiPicker
	case pickedEmoji(Emoji)

	case gamePieceSnapped(Piece, Position)
	case gamePieceMoved(Piece, Position)
	case movementConfirmed(Movement)
	case cancelMovement

	case hasMovedInBounds
	case hasMovedOutOfBounds
	case returnToGameBounds

	case replayLastMove
	case dismissReplayTooltip
	case openGameSettings
	case openAppSettings
	case forfeit
	case forfeitConfirmed
	case returnToLobby
	case arViewError(Error)

	case toggleDebug
	case onDisappear
}

enum GameAction: BaseAction {
	case showAppSettings
	case endGame
}

class GameViewModel: ViewModel<GameViewAction>, ObservableObject {
	private(set) var preferences = Preferences() // TODO: use passed in value
	private(set) var clientInteractor: ClientInteractor!
	private(set) var userId: User.ID?
	private var match: Match

	@Published var gameState: GameState
	@Published var debugMode = false
	@Published var isOutOfBounds = false

	@Published var selectedPiece: (deselected: SelectedPiece?, selected: SelectedPiece?) = (nil, nil)

	@Published var isShowingEmojiPicker = false

	@Published var presentedGameEvent: GameEvent?
	@Published var presentedGameInformation: GameInformation? {
		didSet {
			if case .playerMustPass = oldValue {
				postViewAction(.movementConfirmed(.pass))
			}
		}
	}

	private(set) var loafState = PassthroughSubject<LoafState, Never>()
	private(set) var animateToPosition = PassthroughSubject<Position, Never>()
	private(set) var animatedEmoji = PassthroughSubject<Emoji, Never>()

	private(set) var gameContent: GameViewContent!

	var clientMode: ClientInteractorConfiguration = .online
	private var connectionOpened = false
	private var reconnectAttempts = 0
	private var reconnecting = false

	private var isLastOrientationPortrait: Bool = false

	let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
	let actionFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
	let promptFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

	private let actions = PassthroughSubject<GameAction, Never>()
	var actionsPublisher: AnyPublisher<GameAction, Never> {
		actions.eraseToAnyPublisher()
	}

	var inGame: Bool {
		fatalError("GameViewModel subclasses should override")
	}

	var hasGameEnded: Bool {
		fatalError("GameViewModel subclasses should override")
	}

	var isSpectating: Bool {
		fatalError("GameViewModel subclasses should override")
	}

	#if AR_AVAILABLE
	var gameAnchor: Experience.HiveGame? {
		if case let .arExperience(anchor) = gameContent {
			return anchor
		} else {
			return nil
		}
	}
	#endif

	var presentingGameInformation: Binding<Bool> {
		Binding(
			get: { [weak self] in self?.presentedGameInformation != nil },
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.presentedGameInformation = nil
			}
		)
	}

	var presentingGameEvent: Binding<Bool> {
		Binding(
			get: { [weak self] in self?.presentedGameEvent != nil },
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.presentedGameEvent?.onClose?()
				self?.presentedGameEvent = nil
			}
		)
	}

	var shouldHideHUDControls: Bool {
		presentingGameInformation.wrappedValue || presentingGameEvent.wrappedValue
	}

	private(set) var viewContentReady = false
	private(set) var viewInteractionsReady = false

	init(setup: Game.Setup) {
		self.match = setup.match
		self.gameState = setup.state
	}

	override func postViewAction(_ viewAction: GameViewAction) {
		switch viewAction {
		case .onAppear(let userId, let clientInteractor, let preferences):
			self.userId = userId
			self.clientInteractor = clientInteractor
			self.preferences = preferences
			openConnection()
			setupNotifications()
		case .viewContentDidLoad(let content):
			setupView(content: content)
		case .viewContentReady:
			viewContentReady = true
			setupNewGame()
		case .viewInteractionsReady:
			viewInteractionsReady = true
			setupNewGame()

		case .presentInformation(let information):
			presentedGameInformation = information
			hideEmojiPicker()
		case .closeInformation(let withFeedback):
			if withFeedback {
				actionFeedbackGenerator.impactOccurred()
			}
			presentingGameInformation.wrappedValue = false

		case .enquiredFromHand(let pieceClass):
			enquireFromHand(pieceClass)
		case .tappedPiece(let piece):
			tappedPiece(piece)
		case .tappedGamePiece(let piece):
			tappedPiece(piece, showStack: true)

		case .openGameSettings:
			openGameSettings()
		case .openAppSettings:
			actions.send(.showAppSettings)

		case .toggleEmojiPicker:
			promptFeedbackGenerator.impactOccurred()
			isShowingEmojiPicker.toggle()
		case .pickedEmoji(let emoji):
			pickedEmoji(emoji)

		case .returnToLobby:
			exitToLobby()
		case .arViewError(let error):
			loafState.send(LoafState(error.localizedDescription, style: .error()))

		case .hasMovedInBounds:
			isOutOfBounds = false
		case .hasMovedOutOfBounds:
			isOutOfBounds = true
		case .returnToGameBounds:
			isOutOfBounds = false
			animateToPosition.send(.origin)

		case .replayLastMove:
			replayLastMove()
		case .dismissReplayTooltip:
			preferences.hasDismissedReplayTooltip = true
			objectWillChange.send()

		case .onDisappear:
			cleanUp()

		// Not used in common GameViewModel
		case .forfeit, .forfeitConfirmed, .toggleDebug, .gamePieceSnapped, .gamePieceMoved,
				 .movementConfirmed, .cancelMovement, .selectedFromHand, .openHand:
			break
		}
	}

	// MARK: State transitions

	func setupNewGame() {
		fatalError("GameViewModel subclasses should override")
	}

	func showEndGame(withWinner winner: Player?) {
		fatalError("GameViewModel subclasses should override")
	}

	func showForfeit(byPlayer player: Player) {
		fatalError("GameViewModel subclasses should override")
	}

	func endGame() {
		fatalError("GameViewModel subclasses should override")
	}

	func updateGameState(to newState: GameState) {
		fatalError("GameViewModel subclasses should override")
	}

	func setupView(content: GameViewContent) {
		if gameContent == nil {
			self.gameContent = content
		}
	}

	private func openConnection() {
		guard !connectionOpened else { return }
		connectionOpened = true
		clientInteractor.reconnect(clientMode)
			.sink(
				receiveCompletion: { [weak self] in
					if case let .failure(error) = $0 {
						self?.handleGameClientError(error)
					}
				}, receiveValue: { [weak self] in
					self?.handleGameClientEvent($0)
				}
			)
			.store(in: self)
	}

	private func setupNotifications() {
		isLastOrientationPortrait = UIDevice.current.orientation.isPortrait
		NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
			.sink { [weak self] _ in
				guard self?.preferences.isMoveToCenterOnRotateEnabled == true else {
					return
				}
				let isNewOrientationPortrait = UIDevice.current.orientation.isPortrait
				guard self?.isLastOrientationPortrait != isNewOrientationPortrait else {
					return
				}

				self?.isLastOrientationPortrait = isNewOrientationPortrait
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self?.postViewAction(.returnToGameBounds)
				}
			}
			.store(in: self)
	}

	private func cleanUp() {
		clientInteractor.close(clientMode)
	}

	func exitToLobby() {
		actions.send(.endGame)
	}

	// MARK: Interactions

	func clearSelectedPiece() {
		selectedPiece = (selectedPiece.selected, nil)
	}

	func enquireFromHand(_ pieceClass: Piece.Class) {
		guard inGame else { return }
		actionFeedbackGenerator.impactOccurred()
		presentedGameInformation = .pieceClass(pieceClass)
	}

	private func tappedPiece(_ piece: Piece, showStack: Bool = false) {
		promptFeedbackGenerator.impactOccurred()
		if showStack {
			let position = self.position(of: piece, in: gameState)
			guard let stack = gameState.stacks[position] else {
				presentedGameInformation = .pieceClass(piece.class)
				return
			}

			let (_, stackCount) = self.positionInStack(of: piece, in: gameState)
			if stackCount > 1 {
				let stackAddition = stackCount > stack.count ? [selectedPiece.selected?.piece].compactMap { $0 } : []
				presentedGameInformation = .stack(stack + stackAddition)
				return
			}
		}
		presentedGameInformation = .pieceClass(piece.class)
	}

	private func openGameSettings() {
		promptFeedbackGenerator.impactOccurred()
		presentedGameInformation = .settings
	}

	// MARK: UI

	var displayState: String {
		""
	}

	func handImage(for player: Player) -> UIImage {
		return ImageAsset.Icon.handFilled
	}

	private func replayLastMove() {
		guard let lastUpdate = gameState.updates.last else { return }
		presentMovement(from: lastUpdate.player, movement: lastUpdate.movement)
	}

	func presentMovement(from player: Player, movement: Movement) {
		let message: String
		let image: UIImage
		switch movement {
		case .pass:
			message = "\(player) passed"
			image = ImageAsset.Movement.pass
		case .move(let unit, _), .yoink(_, let unit, _):
			if unit.owner == player {
				message = "\(player) moved their \(unit.class)"
				image = ImageAsset.Movement.move
			} else {
				message = "\(player) yoinked your \(unit.class)"
				image = ImageAsset.Movement.yoink
			}
		case .place(let unit, _):
			message = "\(player) placed their \(unit.class)"
			image = ImageAsset.Movement.place
		}

		loafState.send(
			LoafState(
				message,
				style: LoafState.Style(
					backgroundColor: .backgroundLight,
					textColor: .textRegular,
					icon: image
				)
			) { [weak self] dismissalReason in
				guard let self = self,
					dismissalReason == .tapped,
					let position = movement.targetPosition else { return }
				self.animateToPosition.send(position)
			}
		)
	}

	// MARK: Emoji

	private func hideEmojiPicker() {
		if isShowingEmojiPicker {
			isShowingEmojiPicker = false
		}
	}

	private func pickedEmoji(_ emoji: Emoji) {
		guard EmojiManager.shared.canSend(emoji: emoji) else { return }

		hideEmojiPicker()
		promptFeedbackGenerator.impactOccurred()
		animatedEmoji.send(emoji)
		clientInteractor.send(clientMode, .message(emoji.serialize())) { _ in }
		EmojiManager.shared.didSend(emoji: emoji)
	}

	private func handleMessage(_ message: String, from id: UUID) {
		guard id != self.userId,
					(preferences.isSpectatorEmotesEnabled || match.opponent?.id == id),
					let emoji: Emoji = Balloon.from(message: message) ?? Confetti.from(message: message),
					EmojiManager.shared.canReceive(emoji: emoji) else { return }

		animatedEmoji.send(emoji)
		EmojiManager.shared.didReceive(emoji: emoji)
	}

	// MARK: Spectators

	func announceSpectator(_ name: String, joined: Bool) {
		guard !isSpectating, preferences.isSpectatorNotificationsEnabled else { return }
		if joined {
			loafState.send(LoafState("\(name) is now spectating", style: .success(), duration: .short))
		} else {
			loafState.send(LoafState("\(name) stopped spectating", style: .info(), duration: .short))
		}
	}

	// MARK: GameClient

	func handleGameClientError(_ error: GameClientError) {
		switch error {
		case .usingOfflineAccount, .notPrepared, .missingURL:
			break
		case .failedToConnect:
			attemptToReconnect(error: error)
		case .webSocketError(let error):
			attemptToReconnect(error: error)
		}
	}

	func attemptToReconnect(error: Error?) {
		logger.debug("Client did not connect: \(String(describing: error))")

		guard reconnectAttempts < OnlineGameClient.maxReconnectAttempts else {
			loafState.send(LoafState("Failed to reconnect", style: .error()))
			exitToLobby()
			return
		}

		reconnecting = true
		reconnectAttempts += 1
		presentedGameInformation = .reconnecting(reconnectAttempts)

		openConnection()
	}

	func onClientConnected() {
		reconnecting = false
		reconnectAttempts = 0
		logger.debug("Connected to client.")

		switch presentedGameInformation {
		case .reconnecting:
			postViewAction(.closeInformation(withFeedback: true))
		case .pieceClass, .playerHand, .stack, .rule, .gameEnd, .settings, .playerMustPass, .none:
			break
		}
	}

	func handleGameClientEvent(_ event: GameClientEvent) {
		switch event {
		case .connected, .alreadyConnected:
			onClientConnected()
			self.connectionOpened = false
		case .message(let message):
			handleGameServerMessage(message)
		}
	}

	func handleGameServerMessage(_ message: GameServerMessage) {
		switch message {
		case .gameState(let state):
			updateGameState(to: state)
		case .gameOver(let winner):
			endGame()
			promptFeedbackGenerator.impactOccurred()
			showEndGame(withWinner: player(forUser: winner))
		case .forfeit(let user):
			endGame()
			promptFeedbackGenerator.impactOccurred()
			showForfeit(byPlayer: player(forUser: user) ?? .white)

		case .message(let id, let message):
			handleMessage(message, from: id)

		case .spectatorJoined(let name):
			announceSpectator(name, joined: true)
		case .spectatorLeft(let name):
			announceSpectator(name, joined: false)

		case .error(let error):
			logger.error("Recieved error: \(error)")
			handleGameServerError(error)
		case .playerJoined, .playerLeft, .playerReady, .setOption:
			logger.error("Received invalid message: \(message)")
		}
	}

	func handleGameServerError(_ error: GameServerError) {
		switch error.code {
		case
			.failedToEndMatch,
			.failedToStartMatch,
			.optionNonModifiable,
			.optionValueNotUpdated,
			.unknownError:
			loafState.send(LoafState("Unknown server error", style: .error()))
		case .invalidCommand:
			loafState.send(LoafState("Invalid command", style: .error()))
		case .invalidMovement:
			loafState.send(LoafState("Invalid movement. Try again", style: .warning()))
		case .notPlayerTurn:
			loafState.send(LoafState("It's not your turn", style: .info()))
		}
	}
}

// MARK: - Player

extension GameViewModel {
	private func player(forUser user: UUID?) -> Player? {
		guard let user = user else { return nil }
		if match.optionSet.contains(.hostIsWhite) == true {
			return user == match.host?.id ? .white : .black
		} else {
			return user == match.host?.id ? .black : .white
		}
	}
}

// MARK: - Selected Piece

extension GameViewModel {
	struct SelectedPiece {
		let piece: Piece
		let position: Position
	}
}

// MARK: - Position

extension GameViewModel {
	/// Returns the position in the stack and the total number of pieces in the stack
	func positionInStack(of piece: Piece, in gameState: GameState) -> (Int, Int) {
		let position = self.position(of: piece, in: gameState)
		if let stack = gameState.stacks[position] {
			let selectedPieceInStack: Bool
			let selectedPieceOnStack: Bool
			let selectedPieceFromStack: Bool
			if let selectedPiece = selectedPiece.selected {
				selectedPieceInStack = stack.contains(selectedPiece.piece)
				selectedPieceOnStack = !selectedPieceInStack && selectedPiece.position == position
				selectedPieceFromStack = selectedPieceInStack && selectedPiece.position != position
			} else {
				selectedPieceInStack = false
				selectedPieceOnStack = false
				selectedPieceFromStack = false
			}

			let additionalStackPieces = selectedPieceOnStack ? 1 : (selectedPieceFromStack ? -1 : 0)
			let stackCount = stack.count + additionalStackPieces

			if let indexInStack = stack.firstIndex(of: piece) {
				return (indexInStack + 1, stackCount)
			} else {
				return (stackCount, stackCount)
			}
		} else {
			return (1, 1)
		}
	}

	/// Returns the current position of the piece, accounting for the selected piece, and it's in game position
	func position(of piece: Piece, in gameState: GameState) -> Position {
		if selectedPiece.selected?.piece == piece,
			let selectedPosition = selectedPiece.selected?.position {
			return selectedPosition
		} else if let gamePosition = gameState.position(of: piece) {
			return gamePosition
		} else {
			return .origin
		}
	}
}
