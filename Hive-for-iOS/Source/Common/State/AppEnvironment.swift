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
		let session = configuredNetworkSession()
		let api = configuredAPI(session: session)
		let client = configuredClient()
		let keychain = configuredKeychain()

		let repositories = configuredRepositories(keychain: keychain, api: api, client: client)
		let interactors = configuredInteractors(repositories: repositories, appState: appState)

		let container = AppContainer(appState: appState, interactors: interactors)
		return AppEnvironment(container: container)
	}

	private static func configuredNetworkSession() -> URLSession {
		let configuration = URLSessionConfiguration.default
		return URLSession(configuration: configuration)
	}

	private static func configuredAPI(session: URLSession) -> HiveAPI {
		HiveAPI(session: session)
	}

	private static func configuredClient() -> HiveGameClient {
		HiveGameClient()
	}

	private static func configuredKeychain() -> Keychain {
		Keychain(service: "ca.josephroque.hive-for-ios")
	}

	private static func configuredRepositories(
		keychain: Keychain,
		api: HiveAPI,
		client: HiveGameClient
	) -> RepositoryContainer {
		let accountRepository = LiveAccountRepository(keychain: keychain, api: api)
		let matchRepository = LiveMatchRepository(api: api)
		let userRepository = LiveUserRepository(api: api)

		return RepositoryContainer(
			accountRepository: accountRepository,
			matchRepository: matchRepository,
			userRepository: userRepository,
			client: client
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
			client: repositories.client,
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
		let client: HiveGameClient
	}
}
