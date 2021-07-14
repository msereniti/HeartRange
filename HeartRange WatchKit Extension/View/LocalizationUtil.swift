//
//  LocalizationUtil.swift
//  HeartRange WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 7/24/21.
//

import SwiftUI

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        
        let language = locale.languageCode
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}
