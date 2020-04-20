//
//  Store.swift
//  Hive-for-iOS
//
//  Created by Joseph Roque on 2020-04-20.
//  Copyright © 2020 Joseph Roque. All rights reserved.
//

import Combine

typealias Store<Value> = CurrentValueSubject<Value, Never>
