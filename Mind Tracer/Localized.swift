//
//  Localized.swift
//  Mind Tracer
//
//  Created by Tatsuya Moriguchi on 8/2/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import Foundation

extension String {
    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
}
