//
//  TimetableWidget.swift
//  AmadooWidget
//
//  시간표 위젯 (systemLarge 크기)
//  월~금요일의 시간표를 앱 화면과 동일하게 표시
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct TimetableEntry: TimelineEntry {
    let date: Date
    let timetables: [Int: [TimetableData]]  // [요일: [시간표]]
    let startHour: Int
    let endHour: Int
}

// MARK: - Timeline Provider
struct TimetableProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimetableEntry {
        TimetableEntry(
            date: Date(),
            timetables: [:],
            startHour: 9,
            endHour: 16
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimetableEntry) -> Void) {
        let entry = makeEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimetableEntry>) -> Void) {
        let entry = makeEntry()

        // 30분마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func makeEntry() -> TimetableEntry {
        print("🎯 TimetableWidget: makeEntry() 시작")

        let dataManager = WidgetDataManager.shared
        let timetables = dataManager.getAllTimetables()
        let startHour = dataManager.startHour
        let endHour = dataManager.endHour

        print("📊 TimetableWidget: 시간표 데이터 로드 완료")
        print("   - 시작 시간: \(startHour)시")
        print("   - 종료 시간: \(endHour)시")
        print("   - 총 시간표 개수: \(timetables.values.flatMap { $0 }.count)개")

        return TimetableEntry(
            date: Date(),
            timetables: timetables,
            startHour: startHour,
            endHour: endHour
        )
    }
}

// MARK: - Widget View
struct TimetableWidgetView: View {
    let entry: TimetableEntry

    var body: some View {
        VStack(spacing: 0) {
            // 헤더: 타이틀
            Text("시간표")
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 6)

            // 시간표 그리드
            TimetableGridView(
                timetables: entry.timetables,
                startHour: entry.startHour,
                endHour: entry.endHour
            )
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
        .widgetURL(URL(string: "amadoo://timetable"))
    }
}

// MARK: - Timetable Grid View
struct TimetableGridView: View {
    let timetables: [Int: [TimetableData]]
    let startHour: Int
    let endHour: Int

    private let dayNames = ["월", "화", "수", "목", "금"]
    private let timeColumnWidth: CGFloat = 45
    private let headerHeight: CGFloat = 30

    // 시간 배열 (1시간 단위)
    private var hours: [Int] {
        return Array(startHour...endHour)
    }

    // 총 시간 수
    private var totalHours: Int {
        return endHour - startHour
    }

    // 30분 단위 시간 슬롯 (내부 계산용)
    private var timeSlots: [(hour: Int, minute: Int)] {
        var slots: [(Int, Int)] = []
        for hour in startHour...endHour {
            slots.append((hour, 0))
            slots.append((hour, 30))
        }
        return slots
    }

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - timeColumnWidth
            let columnWidth = availableWidth / 5

            // 가용 높이 계산: 전체 높이 - 헤더
            let availableHeight = geometry.size.height - headerHeight

            // 1시간당 높이 = 가용 높이 / 총 시간 수
            let hourHeight = availableHeight / CGFloat(totalHours)

            HStack(spacing: 0) {
                // 왼쪽: 시간 라벨 컬럼
                VStack(spacing: 0) {
                    // 상단 빈 공간 (요일 헤더 높이만큼)
                    Color.clear
                        .frame(height: headerHeight)

                    // 시간 라벨들 (스크롤 제거 - 모두 표시)
                    VStack(spacing: 0) {
                        ForEach(startHour..<endHour, id: \.self) { hour in
                            ZStack {
                                Color.fromHex("E6DFF1")

                                Text(String(format: "%02d:00", hour))
                                    .font(.system(size: 11))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .padding(.top, 4)
                            }
                            .frame(height: hourHeight)
                            .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }
                }
                .frame(width: timeColumnWidth)
                .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                .clipped()

                // 오른쪽: 시간표 그리드
                VStack(spacing: 0) {
                    // 요일 헤더
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { dayIndex in
                            Text(dayNames[dayIndex])
                                .font(.system(size: 12, weight: .semibold))
                                .frame(width: columnWidth, height: headerHeight)
                                .background(Color.fromHex("E6DFF1"))
                                .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }

                    // 시간표 셀들 (스크롤 제거)
                    HStack(alignment: .top, spacing: 0) {
                        // 각 요일별 컬럼
                        ForEach(0..<5, id: \.self) { dayIndex in
                            TimetableDayColumn(
                                dayIndex: dayIndex,
                                timetables: timetables[dayIndex] ?? [],
                                startHour: startHour,
                                endHour: endHour,
                                hourHeight: hourHeight,
                                columnWidth: columnWidth
                            )
                        }
                    }
                }
                .cornerRadius(10, corners: [.topRight, .bottomRight])
                .clipped()
            }
        }
    }
}

// MARK: - Timetable Day Column
struct TimetableDayColumn: View {
    let dayIndex: Int
    let timetables: [TimetableData]
    let startHour: Int
    let endHour: Int
    let hourHeight: CGFloat
    let columnWidth: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 배경 그리드 (1시간 단위)
            VStack(spacing: 0) {
                ForEach(startHour..<endHour, id: \.self) { _ in
                    Color.white
                        .frame(height: hourHeight)
                        .border(Color.gray.opacity(0.2), width: 0.5)
                }
            }

            // 시간표 블록들
            ForEach(timetables) { timetable in
                if let yOffset = getYOffset(for: timetable),
                   let height = getBlockHeight(for: timetable) {
                    TimetableBlockView(
                        timetable: timetable,
                        yOffset: yOffset,
                        height: height
                    )
                }
            }
        }
        .frame(width: columnWidth)
    }

    // 시간표 블록의 Y 위치 계산
    private func getYOffset(for timetable: TimetableData) -> CGFloat? {
        guard let (hour, minute) = timetable.parseTime(timetable.startTime) else {
            return nil
        }

        // startHour부터의 시간 차이 계산
        let hourDiff = hour - startHour
        let minuteFraction = CGFloat(minute) / 60.0

        // Y 위치 = (시간 차이 + 분 비율) * 1시간당 높이
        return (CGFloat(hourDiff) + minuteFraction) * hourHeight
    }

    // 시간표 블록의 높이 계산
    private func getBlockHeight(for timetable: TimetableData) -> CGFloat? {
        guard let (startHour, startMinute) = timetable.parseTime(timetable.startTime),
              let (endHour, endMinute) = timetable.parseTime(timetable.endTime) else {
            return nil
        }

        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let totalMinutes = endMinutes - startMinutes

        // 높이 = (총 분 / 60분) * 1시간당 높이
        return (CGFloat(totalMinutes) / 60.0) * hourHeight
    }
}

// MARK: - Timetable Block View
struct TimetableBlockView: View {
    let timetable: TimetableData
    let yOffset: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Text(timetable.title)
                .font(.system(size: 9, weight: .medium))
                .lineLimit(2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            if let memo = timetable.memo, !memo.isEmpty {
                Text(memo)
                    .font(.system(size: 8))
                    .lineLimit(1)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.fromHex(timetable.color))
        .cornerRadius(6)
        .padding(2)
        .frame(height: height)
        .offset(y: yOffset)
    }
}

// MARK: - Widget Configuration
struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimetableProvider()) { entry in
            TimetableWidgetView(entry: entry)
        }
        .configurationDisplayName("시간표")
        .description("월~금요일의 시간표를 한눈에 확인하세요.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Preview
struct TimetableWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTimetables: [Int: [TimetableData]] = [
            0: [
                TimetableData(
                    dayOfWeek: 0,
                    startTime: "09:00",
                    endTime: "10:30",
                    title: "수학",
                    memo: "1강의실",
                    color: "FF6B6B"
                ),
                TimetableData(
                    dayOfWeek: 0,
                    startTime: "10:30",
                    endTime: "12:00",
                    title: "영어",
                    memo: nil,
                    color: "4ECDC4"
                )
            ]
        ]

        TimetableWidgetView(
            entry: TimetableEntry(
                date: Date(),
                timetables: sampleTimetables,
                startHour: 9,
                endHour: 16
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
