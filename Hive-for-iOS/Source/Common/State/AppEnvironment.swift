//
//  AppEnvironment.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-05-02.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Foundation
import Combine
import KeychainAccess

struct AppEnvironment {
	let container: AppContainer
}

extension AppEnvironment {
	static func bootstrap() -> AppEnvironment {
		let appState = Store(AppState())
		let configuration = networkSessionConfiguration()
		let api = configuredAPI(configuration: configuration)
		let onlineClient = configuredOnlineClient(configuration: configuration)
		let localClient = configuredLocalClient()
		let keychain = configuredKeychain()

		let repositories = configuredRepositories(
			keychain: keychain,
			api: api,
			onlineClient: onlineClient,
			localClient: localClient
		)
		let interactors = configuredInteractors(repositories: repositories, appState: appState)

		let container = AppContainer(appState: appState, interactors: interactors)
		return AppEnvironment(container: container)
	}

	private static func networkSessionConfiguration() -> URLSessionConfiguration {
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = [
			"User-Agent": "Hive for iOS+\(AppInfo.fullSemanticVersion)" +
				"/HiveEngine+\(AppInfo.packageVersion("HiveEngine"))",
		]
		return configuration
	}

	private static func configuredAPI(configuration: URLSessionConfiguration) -> HiveAPI {
		HiveAPI(configuration: configuration)
	}

	private static func configuredOnlineClient(configuration: URLSessionConfiguration) -> GameClient {
		OnlineGameClient(configuration: configuration)
	}

	private static func configuredLocalClient() -> GameClient {
		LocalGameClient()
	}

	private static func configuredKeychain() -> Keychain {
		Keychain(service: "ca.josephroque.hive-for-ios")
	}

	private static func configuredRepositories(
		keychain: Keychain,
		api: HiveAPI,
		onlineClient: GameClient,
		localClient: GameClient
	) -> RepositoryContainer {
		let accountRepository = LiveAccountRepository(keychain: keychain, api: api)
		let matchRepository = LiveMatchRepository(api: api)
		let userRepository = LiveUserRepository(api: api)

		return RepositoryContainer(
			accountRepository: accountRepository,
			matchRepository: matchRepository,
			userRepository: userRepository,
			clients: (onlineClient, localClient)
		)
	}

	private static func configuredInteractors(
		repositories: RepositoryContainer,
		appState: Store<AppState>
	) -> AppContainer.Interactors {
		let accountInteractor = LiveAccountInteractor(
			repository: repositories.accountRepository,
			appState: appState
		)

		let matchInteractor = LiveMatchInteractor(
			repository: repositories.matchRepository,
			appState: appState
		)

		let userInteractor = LiveUserInteractor(
			repository: repositories.userRepository,
			appState: appState
		)

		let clientInteractor = LiveClientInteractor(
			clients: LiveClientInteractor.Clients(
				online: repositories.clients.online,
				local: repositories.clients.local
			),
			appState: appState
		)

		return AppContainer.Interactors(
			accountInteractor: accountInteractor,
			matchInteractor: matchInteractor,
			userInteractor: userInteractor,
			clientInteractor: clientInteractor
		)
	}
}

private extension AppEnvironment {
	struct RepositoryContainer {
		let accountRepository: AccountRepository
		let matchRepository: MatchRepository
		let userRepository: UserRepository
		let clients: (online: GameClient, local: GameClient)
	}
}
