//
//  LeaderboardResponsiveConstants.swift
//  CardGameByMahu
//
//  Created by GitHub Copilot on 2026. 05. 19..
//

import SwiftUI

enum LeaderboardResponsiveMetrics {
    static let desktopBreakpoint: CGFloat = 650
    static let maxContentWidth: CGFloat = 1200

    static let rowHorizontalPadding: CGFloat = 16
    static let rowHorizontalPaddingMax: CGFloat = 30
    static let rowVerticalPadding: CGFloat = 10
    static let rowVerticalPaddingMax: CGFloat = 18
    static let headerVerticalPadding: CGFloat = 12
    static let headerVerticalPaddingMax: CGFloat = 20

    static let tableSpacing: CGFloat = 12
    static let tableSpacingMax: CGFloat = 22
    static let headerLabelSpacing: CGFloat = 4
    static let headerLabelSpacingMax: CGFloat = 12

    static let rankColumnWidth: CGFloat = 60
    static let rankColumnWidthMax: CGFloat = 78
    static let scoreColumnWidth: CGFloat = 80
    static let scoreColumnWidthMax: CGFloat = 106
    static let accuracyColumnWidth: CGFloat = 90
    static let accuracyColumnWidthMax: CGFloat = 126
    static let timeColumnWidth: CGFloat = 80
    static let timeColumnWidthMax: CGFloat = 106
    static let actionsColumnWidth: CGFloat = 60
    static let actionsColumnWidthMax: CGFloat = 78

    static let headerFontSize: CGFloat = 12
    static let headerFontSizeMax: CGFloat = 21
    static let rowPrimaryFontSize: CGFloat = 15
    static let rowPrimaryFontSizeMax: CGFloat = 25
    static let rowSecondaryFontSize: CGFloat = 14
    static let rowSecondaryFontSizeMax: CGFloat = 24
    static let dateFontSize: CGFloat = 12
    static let dateFontSizeMax: CGFloat = 21
    static let iconFontSize: CGFloat = 14
    static let iconFontSizeMax: CGFloat = 23
    static let arrowFontSize: CGFloat = 10
    static let arrowFontSizeMax: CGFloat = 19

    static func progress(for width: CGFloat) -> CGFloat {
        guard width > desktopBreakpoint else { return 0 }
        let clampedWidth = min(width, maxContentWidth)
        let range = maxContentWidth - desktopBreakpoint
        guard range > 0 else { return 0 }
        return min(max((clampedWidth - desktopBreakpoint) / range, 0), 1)
    }

    static func interpolate(min: CGFloat, max: CGFloat, width: CGFloat) -> CGFloat {
        min + (max - min) * progress(for: width)
    }

    static func columnWidth(base: CGFloat, max: CGFloat, width: CGFloat) -> CGFloat {
        interpolate(min: base, max: max, width: width)
    }

    static func fontSize(base: CGFloat, max: CGFloat, width: CGFloat) -> CGFloat {
        interpolate(min: base, max: max, width: width)
    }

    static func spacing(base: CGFloat, max: CGFloat, width: CGFloat) -> CGFloat {
        interpolate(min: base, max: max, width: width)
    }

    static func padding(base: CGFloat, max: CGFloat, width: CGFloat) -> CGFloat {
        interpolate(min: base, max: max, width: width)
    }
}
