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
		let keychain = configuredKeychain()

		let repositories = configuredRepositories(keychain: keychain, api: api)
		let interactors = configuredInteractors(repositories: repositories, appState: appState)

		let container = AppContainer(appState: appState, interactors: interactors)
		return AppEnvironment(container: container)
	}

	private static func configuredNetworkSession() -> NetworkSession {
		let configuration = URLSessionConfiguration.default
		return URLSession(configuration: configuration)
	}

	private static func configuredAPI(session: NetworkSession) -> HiveAPI {
		HiveAPI(session: session)
	}

	private static func configuredKeychain() -> Keychain {
		Keychain(service: "ca.josephroque.hive-for-ios")
	}

	private static func configuredRepositories(keychain: Keychain, api: HiveAPI) -> RepositoryContainer {
		let accountRepository = LiveAccountRepository(keychain: keychain, api: api)
		return RepositoryContainer(accountRepository: accountRepository)
	}

	private static func configuredInteractors(
		repositories: RepositoryContainer,
		appState: Store<AppState>
	) -> AppContainer.Interactors {
		let accountInteractor = LiveAccountInteractor(
			repository: repositories.accountRepository,
			appState: appState
		)

		return AppContainer.Interactors(accountInteractor: accountInteractor)
	}
}

private extension AppEnvironment {
	struct RepositoryContainer {
		let accountRepository: AccountRepository
	}
}
