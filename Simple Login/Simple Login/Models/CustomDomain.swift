//
//  CustomDomain.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import UIKit

final class CustomDomain: Decodable {
    let id: Int
    let name: String
    let creationTimestamp: TimeInterval
    let aliasCount: Int
    let isVerified: Bool

    lazy var countAttributedString: NSAttributedString = {
        var plainString = ""
        plainString += "\(aliasCount) "
        plainString += aliasCount > 1 ? "aliases" : "alias"

        let attributedString = NSMutableAttributedString(string: plainString)
        attributedString.addAttributes(
            [.foregroundColor: SLColor.titleColor, .font: UIFont.systemFont(ofSize: 12, weight: .medium)],
            range: NSRange(plainString.startIndex..., in: plainString))

        let matchRanges = RegexHelpers.matchRanges(of: "[0-9]{1,}", inString: plainString)
        matchRanges.forEach { range in
            attributedString.addAttributes(
                [
                    .foregroundColor: SLColor.textColor,
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium)
                ],
                range: range)
        }

        return attributedString
    }()

    lazy var creationTimestampString: String = {
        let date = Date(timeIntervalSince1970: creationTimestamp)
        let preciseDateAndTime = kPreciseDateFormatter.string(from: date)
        let (value, unit) = date.distanceFromNow()
        return "Created on \(preciseDateAndTime) (\(value) \(unit) ago)"
    }()

    lazy var catchAllDescriptionString: NSAttributedString = {
        // swiftlint:disable line_length
        let text = """
            This feature allows you to create aliases on the fly. Simply use anything@\(name) next time you need an email address.
            The alias will be created the first time it receives an email.
            """
        // swiftlint:enable line_length
        let attributedString = NSMutableAttributedString(string: text)

        attributedString.addAttributes(
            [.foregroundColor: SLColor.secondaryTitleColor, .font: UIFont.systemFont(ofSize: 14)],
            range: NSRange(text.startIndex..., in: text))

        if let onTheFlyRange = text.range(of: "on the fly") {
            attributedString.addAttribute(.font,
                                          value: UIFont.boldSystemFont(ofSize: 14),
                                          range: NSRange(onTheFlyRange, in: text))
        }

        if let emailRange = text.range(of: "anything@\(name)") {
            attributedString.addAttribute(.backgroundColor,
                                          value: UIColor.systemYellow,
                                          range: NSRange(emailRange, in: text))
            attributedString.addAttribute(.font,
                                          value: UIFont.boldSystemFont(ofSize: 14),
                                          range: NSRange(emailRange, in: text))
        }

        return attributedString
    }()

    // swiftlint:disable type_name
    private enum Key: String, CodingKey {
        case id = "id"
        case name = "domain"
        case creationTimestamp = "creation_timestamp"
        case aliasCount = "nb_alias"
        case isVerified = "verified"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.creationTimestamp = Date().timeIntervalSince1970
        self.aliasCount = try container.decode(Int.self, forKey: .aliasCount)
        self.isVerified = try container.decode(Bool.self, forKey: .isVerified)
    }
}
