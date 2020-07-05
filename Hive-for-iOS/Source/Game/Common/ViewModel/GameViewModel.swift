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
	case onAppear
	case viewContentDidLoad(GameViewContent)
	case viewContentReady
	case viewInteractionsReady

	case presentPlayerHand(Player)
	case presentInformation(GameInformation)
	case selectedFromHand(Piece.Class)
	case tappedPiece(Piece)
	case tappedGamePiece(Piece)

	case gamePieceSnapped(Piece, Position)
	case gamePieceMoved(Piece, Position)
	case movementConfirmed(Movement)
	case cancelMovement

	case openSettings
	case forfeit
	case forfeitConfirmed
	case returnToLobby
	case arViewError(Error)

	case toggleDebug
	case onDisappear
}

class GameViewModel: ViewModel<GameViewAction>, ObservableObject {
	var clientInteractor: ClientInteractor!

	@Published private(set) var presentedPlayerHand: PlayerHand?
	@Published private(set) var presentedGameInformation: GameInformation?
	@Published private(set) var presentedGameAction: GameAction?

	private(set) var loafState = PassthroughSubject<LoafState, Never>()
	private(set) var animateToPosition = PassthroughSubject<Position, Never>()

	struct SelectedPiece {
		let piece: Piece
		let position: Position
	}

	typealias DeselectedPiece = SelectedPiece

	private(set) var selectedPiece = Store<(DeselectedPiece?, SelectedPiece?)>((nil, nil))
	var currentSelectedPiece: SelectedPiece? { selectedPiece.value.1 }

	private(set) var stateStore = Store<State>(State.begin)
	private(set) var debugModeStore = Store<Bool>(false)
	private(set) var gameStateStore: Store<GameState>

	var userId: User.ID!
	var playingAs: Player
	var clientMode: ClientInteractorConfiguration
	private(set) var gameContent: GameViewContent!

	private var connectionOpened = false
	private var reconnectAttempts = 0
	private var reconnecting = false

	var gameState: GameState {
		gameStateStore.value
	}

	var currentState: State {
		stateStore.value
	}

	var inGame: Bool {
		currentState.inGame
	}

	var gameAnchor: Experience.HiveGame? {
		if case let .arExperience(anchor) = gameContent {
			return anchor
		} else {
			return nil
		}
	}

	var presentingPlayerHand: Binding<Bool> {
		Binding(
			get: { [weak self] in self?.presentedPlayerHand != nil },
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.presentedPlayerHand = nil
			}
		)
	}

	var presentingGameInformation: Binding<Bool> {
		Binding(
			get: { [weak self] in self?.presentedGameInformation != nil },
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.presentedGameInformation = nil
			}
		)
	}

	var presentingGameAction: Binding<Bool> {
		Binding(
			get: { [weak self] in self?.presentedGameAction != nil },
			set: { [weak self] newValue in
				guard !newValue else { return }
				self?.presentedGameAction?.onClose?()
				self?.presentedGameAction = nil
			}
		)
	}

	var shouldHideHUDControls: Bool {
		presentingPlayerHand.wrappedValue || presentingGameInformation.wrappedValue || presentingGameAction.wrappedValue
	}

	private var selectedPieceDefaultPosition: Position {
		let positions = gameState.stacks.keys
		let startX = positions.first?.x ?? 0
		let minX = positions.reduce(startX, { minX, position in min(minX, position.x) })
		let x = minX - 2
		let z = x < 0 ? -x / 2 : Int((Double(-x) / 2.0).rounded(.down))
		return Position(x: x, y: -x - z, z: z)
	}

	private var viewContentReady = false
	private var viewInteractionsReady = false

	init(initialState: GameState, playingAs: Player, mode: ClientInteractorConfiguration) {
		self.gameStateStore = .init(initialState)
		self.playingAs = playingAs
		self.clientMode = mode
	}

	override func postViewAction(_ viewAction: GameViewAction) {
		switch viewAction {
		case .onAppear:
			openConnection()
		case .viewContentDidLoad(let content):
			setupView(content: content)
		case .viewContentReady:
			viewContentReady = true
			setupNewGame()
		case .viewInteractionsReady:
			viewInteractionsReady = true
			setupNewGame()

		case .presentPlayerHand(let player):
			presentedPlayerHand = PlayerHand(player: player, state: gameState)
		case .presentInformation(let information):
			presentedGameInformation = information
		case .selectedFromHand(let pieceClass):
			selectFromHand(pieceClass)
		case .tappedPiece(let piece):
			tappedPiece(piece)
		case .tappedGamePiece(let piece):
			tappedPiece(piece, showStack: true)
		case .gamePieceSnapped(let piece, let position):
			updatePosition(of: piece, to: position, shouldMove: false)
		case .gamePieceMoved(let piece, let position):
			debugLog("Moving \(piece) to \(position)")
			updatePosition(of: piece, to: position, shouldMove: true)
		case .movementConfirmed(let movement):
			debugLog("Sending move \(movement)")
			apply(movement: movement)
		case .cancelMovement:
			pickUpHand()

		case .openSettings:
			#warning("TODO: open game settings")
		case .forfeit:
			promptForfeit()
		case .forfeitConfirmed:
			forfeitGame()
		case .returnToLobby:
			shutDownGame()
		case .arViewError(let error):
			loafState.send(LoafState(error.localizedDescription, state: .error))

		case .toggleDebug:
			debugModeStore.send(!debugModeStore.value)
		case .onDisappear:
			cleanUp()
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

	private func cleanUp() {
		clientInteractor.close(clientMode)
	}

	private func setupNewGame() {
		guard !inGame && viewContentReady && viewInteractionsReady else { return }
		if gameState.currentPlayer == playingAs {
			transition(to: .playerTurn)
		} else {
			transition(to: .opponentTurn)
		}

		// Let the computer know it's time to play, if offline
		if case .local = clientMode {
			clientInteractor.send(.local, .readyToPlay)
		}
	}

	private func setupView(content: GameViewContent) {
		if gameContent == nil {
			self.gameContent = content
			transition(to: .gameStart)
		}
	}

	private func selectFromHand(_ pieceClass: Piece.Class) {
		guard inGame else { return }
		if presentedPlayerHand?.player == playingAs {
			placeFromHand(pieceClass)
		} else {
			enquireFromHand(pieceClass)
		}
		presentedPlayerHand = nil
	}

	private func placeFromHand(_ pieceClass: Piece.Class) {
		guard inGame else { return }
		if let piece = gameState.firstUnplayed(of: pieceClass, inHand: playingAs) {
			let position = selectedPieceDefaultPosition
			selectedPiece.send((
				selectedPiece.value.1,
				SelectedPiece(
					piece: piece,
					position: position
				)
			))
			animateToPosition.send(position)
		}
	}

	private func enquireFromHand(_ pieceClass: Piece.Class) {
		guard inGame else { return }
		presentedGameInformation = .pieceClass(pieceClass)
	}

	private func tappedPiece(_ piece: Piece, showStack: Bool = false) {
		if showStack {
			let position = self.position(of: piece)
			guard let stack = gameState.stacks[position] else {
				presentedGameInformation = .piece(piece)
				return
			}

			let (_, stackCount) = self.positionInStack(of: piece)
			if stackCount > 1 {
				let stackAddition = stackCount > stack.count ? [selectedPiece.value.1?.piece].compactMap { $0 } : []
				presentedGameInformation = .stack(stack + stackAddition)
				return
			}
		}
		presentedGameInformation = .piece(piece)
	}

	private func pickUpHand() {
		gameState.unitsInHand[playingAs]?.forEach {
			updatePosition(of: $0, to: nil, shouldMove: true)
		}
	}

	private func forfeitGame() {
		guard inGame else { return }

		clientInteractor.send(clientMode, .forfeit)
		transition(to: .forfeit)
	}

	private func endGame() {
		guard inGame else { return }
		transition(to: .gameEnd)
	}

	private func shutDownGame() {
		transition(to: .shutDown)
	}

	private func promptForfeit() {
		guard inGame else { return }

		let popoverSheet = PopoverSheetConfig(
			title: "Forfeit match?",
			message: "This will count as a loss in your statistics. Are you sure?",
			buttons: [
				PopoverSheetConfig.ButtonConfig(
					title: "Forfeit",
					type: .destructive
				) { [weak self] in
					self?.postViewAction(.forfeitConfirmed)
					self?.presentedGameAction = nil
				},
				PopoverSheetConfig.ButtonConfig(
					title: "Cancel",
					type: .cancel
				) { [weak self] in
					self?.presentedGameAction = nil
				},
			]
		)

		presentedGameAction = GameAction(config: popoverSheet, onClose: nil)
	}

	private func updatePosition(of piece: Piece, to position: Position?, shouldMove: Bool) {
		guard inGame else { return }
		guard let targetPosition = position else {
			selectedPiece.send((selectedPiece.value.1, nil))
			return
		}

		guard shouldMove else {
			selectedPiece.send((selectedPiece.value.1, SelectedPiece(piece: piece, position: targetPosition)))
			return
		}

		guard let movement = gameState.availableMoves.first(where: {
			$0.movedUnit == piece && $0.targetPosition == targetPosition
		}) else {
			debugLog("Did not find \"\(piece) to \(targetPosition)\" in \(gameState.availableMoves)")
			return
		}

		selectedPiece.send((selectedPiece.value.1, SelectedPiece(piece: piece, position: targetPosition)))

		let currentPosition = gameState.position(of: piece)?.description ?? "in hand"

		let popoverSheet = PopoverSheetConfig(
			title: "Move \(piece.class.description)?",
			message: "From \(currentPosition) to \(targetPosition.description)",
			buttons: [
				PopoverSheetConfig.ButtonConfig(
					title: "Move",
					type: .default
				) { [weak self] in
					self?.postViewAction(.movementConfirmed(movement))
					self?.presentedGameAction = nil
				},
				PopoverSheetConfig.ButtonConfig(
					title: "Cancel",
					type: .cancel
				) { [weak self] in
					self?.postViewAction(.cancelMovement)
					self?.presentedGameAction = nil
				},
			]
		)

		presentedGameAction = GameAction(config: popoverSheet) { [weak self] in
			self?.postViewAction(.cancelMovement)
		}
	}

	private func apply(movement: Movement) {
		guard let relativeMovement = movement.relative(in: gameState) else {
			#warning("TODO: present an error here when the move is invalid")
			return
		}

		transition(to: .sendingMovement(movement))
		clientInteractor.send(clientMode, .movement(relativeMovement))
	}

	private func updateGameState(to newState: GameState) {
		guard inGame else { return }
		self.gameStateStore.send(newState)

		let previousState = gameState
		let opponent = playingAs.next
		guard let previousUpdate = newState.updates.last,
			previousUpdate != previousState.updates.last else {
			return
		}

		let wasOpponentMove = previousUpdate.player == opponent

		if newState.isEndGame {
			endGame()
		} else {
			transition(to: wasOpponentMove ? .playerTurn : .opponentTurn)
		}

		guard wasOpponentMove else { return }

		let message: String
		let image: UIImage
		switch previousUpdate.movement {
		case .pass:
			message = "\(opponent) passed"
			image = ImageAsset.Movement.pass
		case .move(let unit, _), .yoink(_, let unit, _):
			if unit.owner == opponent {
				message = "\(opponent) moved their \(unit.class)"
				image = ImageAsset.Movement.move
			} else {
				message = "\(opponent) yoinked your \(unit.class)"
				image = ImageAsset.Movement.yoink
			}
		case .place(let unit, _):
			message = "\(opponent) placed their \(unit.class)"
			image = ImageAsset.Movement.place
		}

		loafState.send(LoafState(
			message,
			state: .custom(Loaf.Style(
				backgroundColor: UIColor(.background),
				textColor: UIColor(.text),
				icon: image)
			)) { [weak self] dismissalReason in
				guard let self = self,
					dismissalReason == .tapped,
					let position = previousUpdate.movement.targetPosition else { return }
				self.animateToPosition.send(position)
			}
		)
	}
}

// MARK: - GameClient

extension GameViewModel {
	private func handleGameClientError(_ error: GameClientError) {
		print("Client did not connect: \(error)")

		guard reconnectAttempts < OnlineGameClient.maxReconnectAttempts else {
			loafState.send(LoafState("Failed to reconnect", state: .error))
			transition(to: .gameEnd)
			return
		}

		reconnecting = true
		reconnectAttempts += 1

		switch presentedGameInformation {
		case .reconnecting: break
		default: presentedGameInformation = .reconnecting(reconnectAttempts)
		}

		openConnection()
	}

	private func onClientConnected() {
		reconnecting = false
		reconnectAttempts = 0
		debugLog("Connected to client.")

		switch presentedGameInformation {
		case .reconnecting: presentedGameInformation = nil
		default: break
		}
	}

	private func handleGameClientEvent(_ event: GameClientEvent) {
		switch event {
		case .connected, .alreadyConnected:
			onClientConnected()
		case .closed(let reason, let code):
			debugLog("Connection to client closed: \(reason) (\(String(describing: code)))")
			self.connectionOpened = false
		case .message(let message):
			handleGameClientMessage(message)
		}
	}

	private func handleGameClientMessage(_ message: GameServerMessage) {
		switch message {
		case .gameState(let state):
			updateGameState(to: state)
		case .gameOver(let winner):
			endGame()
			presentedGameInformation = .gameEnd(EndState(
				winner: winner == nil
					? nil
					: (
						winner == userId
							? playingAs
							: playingAs.next
					),
				playingAs: playingAs
			))
		case .error, .forfeit, .message, .playerJoined, .playerLeft, .playerReady, .setOption:
			#warning("TODO: handle remaining messages in game")
			debugLog("Received message: \(message)")
		}
	}
}

// MARK: - Position

extension GameViewModel {
	/// Returns the position in the stack and the total number of pieces in the stack
	func positionInStack(of piece: Piece) -> (Int, Int) {
		let position = self.position(of: piece)
		if let stack = gameState.stacks[position] {
			let selectedPieceInStack: Bool
			let selectedPieceOnStack: Bool
			let selectedPieceFromStack: Bool
			if let selectedPiece = currentSelectedPiece {
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
	func position(of piece: Piece) -> Position {
		if currentSelectedPiece?.piece == piece,
			let selectedPosition = currentSelectedPiece?.position {
			return selectedPosition
		} else if let gamePosition = gameState.position(of: piece) {
			return gamePosition
		} else {
			return .origin
		}
	}
}

// MARK: - State

extension GameViewModel {
	enum State: Equatable {
		case begin
		case gameStart
		case playerTurn
		case opponentTurn
		case sendingMovement(Movement)
		case gameEnd
		case forfeit
		case shutDown

		var inGame: Bool {
			switch self {
			case .begin, .gameStart, .gameEnd, .forfeit, .shutDown: return false
			case .playerTurn, .opponentTurn, .sendingMovement: return true
			}
		}
	}

	func transition(to nextState: State) {
		guard canTransition(from: currentState, to: nextState) else { return }
		stateStore.send(nextState)
	}

	private func canTransition(from currentState: State, to nextState: State) -> Bool {
		switch (currentState, nextState) {

		// Forfeit and shutDown are final states
		case (.forfeit, _): return false
		case (.shutDown, _): return false

		// Forfeiting possible at any time
		case (_, .forfeit): return true

		// View can be dismissed at any time
		case (_, .shutDown): return true

		// Game can be ended at any time
		case (_, .gameEnd): return true

		// Beginning the game always transitions to the start of a game
		case (.begin, .gameStart): return true
		case (.begin, _): return false
		case (_, .begin): return false
		case (_, .gameStart): return false

		// The start of a game leads to a player's turn or an opponent's turn
		case (.gameStart, .playerTurn), (.gameStart, .opponentTurn): return true
		case (.gameStart, _): return false

		// The player must send moves
		case (.playerTurn, .sendingMovement): return true
		case (.playerTurn, _): return false

		// A played move leads to a new turn
		case (.sendingMovement, .opponentTurn): return true
		case (.opponentTurn, .playerTurn): return true
		case (.opponentTurn, _): return false

		case (.sendingMovement, _), (_, .sendingMovement): return false
		case (_, .playerTurn), (_, .opponentTurn): return false

		}
	}
}

// MARK: - Strings

extension GameViewModel {
	var displayState: String {
		switch currentState {
		case .playerTurn:
			return "Your turn"
		case .sendingMovement:
			return "Sending movement..."
		case .opponentTurn:
			return "Opponent's turn"
		case .gameEnd:
			return gameState.displayWinner ?? ""
		case .begin, .forfeit, .gameStart, .shutDown:
			return ""
		}
	}
}

// MARK: - Logging

extension GameViewModel {
	func debugLog(_ message: String) {
		guard debugModeStore.value else { return }
		print("HIVE_DEBUG: \(message)")
	}
}
