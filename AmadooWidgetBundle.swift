//
//  AmadooWidgetBundle.swift
//  AmadooWidget
//
//  Created by 시모니의 맥북 on 12/9/25.
//

import WidgetKit
import SwiftUI

@main
struct AmadooWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimetableWidget()
        CalendarWidget()
    }
}
