//
//  CalendarWidget.swift
//  AmadooWidget
//
//  달력 위젯 (systemMedium 크기)
//  이번 주 일요일~토요일까지 7일의 일정을 가로로 표시
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct CalendarEntry: TimelineEntry {
    let date: Date
    let weekDates: [Date]  // 이번 주 일요일~토요일 (7일)
    let schedules: [Date: [ScheduleData]]  // [날짜: [일정]]
}

// MARK: - Timeline Provider
struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(
            date: Date(),
            weekDates: [],
            schedules: [:]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        let entry = makeEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let entry = makeEntry()

        // 1시간마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func makeEntry() -> CalendarEntry {
        print("🎯 CalendarWidget: makeEntry() 시작")

        let calendar = Calendar.current
        let today = Date()

        // 이번 주 일요일 찾기
        let weekday = calendar.component(.weekday, from: today)  // 일요일: 1, 토요일: 7
        let daysFromSunday = weekday - 1
        guard let sunday = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            print("❌ CalendarWidget: 일요일 계산 실패")
            return CalendarEntry(date: today, weekDates: [], schedules: [:])
        }

        // 일요일부터 토요일까지 7일
        var weekDates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: sunday) {
                weekDates.append(calendar.startOfDay(for: date))
            }
        }

        // 일정 데이터 가져오기
        print("📆 CalendarWidget: 주간 날짜 생성 완료, 개수 = \(weekDates.count)")

        let dataManager = WidgetDataManager.shared
        guard let firstDate = weekDates.first,
              let lastDate = weekDates.last else {
            print("❌ CalendarWidget: 날짜 범위 오류")
            return CalendarEntry(date: today, weekDates: weekDates, schedules: [:])
        }

        print("📅 CalendarWidget: 일정 데이터 요청 중... (\(firstDate) ~ \(lastDate))")
        let schedules = dataManager.getSchedules(from: firstDate, to: lastDate)
        print("✅ CalendarWidget: 일정 데이터 로드 완료, 총 \(schedules.values.flatMap { $0 }.count)개")

        return CalendarEntry(
            date: today,
            weekDates: weekDates,
            schedules: schedules
        )
    }
}

// MARK: - Widget View
struct CalendarWidgetView: View {
    let entry: CalendarEntry

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("이번 주 일정")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Text(formattedDate())
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)

            // 주간 일정 그리드
            WeekCalendarView(
                weekDates: entry.weekDates,
                schedules: entry.schedules,
                today: entry.date
            )
            .padding(.horizontal, 4)
            .padding(.bottom, 12)
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
        .widgetURL(URL(string: "amadoo://calendar"))
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return formatter.string(from: entry.date)
    }
}

// MARK: - Week Calendar View
struct WeekCalendarView: View {
    let weekDates: [Date]
    let schedules: [Date: [ScheduleData]]
    let today: Date

    private let dayNames = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let columnWidth = totalWidth / 7

            HStack(spacing: 0) {
                ForEach(weekDates.indices, id: \.self) { index in
                    if index < weekDates.count {
                        let date = weekDates[index]
                        let isToday = Calendar.current.isDate(date, inSameDayAs: today)

                        DayColumn(
                            date: date,
                            dayName: dayNames[index],
                            schedules: schedules[date] ?? [],
                            isToday: isToday,
                            isSunday: index == 0,
                            isSaturday: index == 6,
                            width: columnWidth
                        )
                    }
                }
            }
            .frame(width: totalWidth, alignment: .center)
        }
    }
}

// MARK: - Day Column
struct DayColumn: View {
    let date: Date
    let dayName: String
    let schedules: [ScheduleData]
    let isToday: Bool
    let isSunday: Bool
    let isSaturday: Bool
    let width: CGFloat

    private let scheduleRowHeight: CGFloat = 16
    private let scheduleRowSpacing: CGFloat = 3

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    private var headerColor: Color {
        if isSunday {
            return .red
        } else if isSaturday {
            return .blue
        } else {
            return .primary
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 날짜 헤더 (고정 높이로 가로 정렬 보장)
            VStack(spacing: 2) {
                Text(dayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(headerColor)
                    .frame(height: 12)

                Text("\(dayNumber)")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                    .foregroundColor(isToday ? .white : headerColor)
                    .frame(width: 24, height: 24)
                    .background(isToday ? Color.fromHex("E6DFF1") : Color.clear)
                    .clipShape(Circle())
            }
            .frame(width: width, height: 44, alignment: .center)
            .padding(.bottom, 6)

            // 일정 목록 (고정된 3개 Row)
            VStack(alignment: .leading, spacing: scheduleRowSpacing) {
                // 1번째 줄
                Group {
                    if schedules.count > 0 {
                        ScheduleBlock(schedule: schedules[0], width: width)
                    } else {
                        Color.clear
                    }
                }
                .frame(height: scheduleRowHeight)

                // 2번째 줄
                Group {
                    if schedules.count > 1 {
                        ScheduleBlock(schedule: schedules[1], width: width)
                    } else {
                        Color.clear
                    }
                }
                .frame(height: scheduleRowHeight)

                // 3번째 줄
                Group {
                    if schedules.count > 2 {
                        ScheduleBlock(schedule: schedules[2], width: width)
                    } else {
                        Color.clear
                    }
                }
                .frame(height: scheduleRowHeight)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)

            Spacer(minLength: 0)
        }
        .frame(width: width)
    }
}

// MARK: - Schedule Block
struct ScheduleBlock: View {
    let schedule: ScheduleData
    let width: CGFloat

    var body: some View {
        Group {
            if schedule.isPeriod {
                // 기간 일정: 컬럼 전체 너비 사용 (연결되어 보이도록)
                if schedule.isStart {
                    // 시작일: 제목 표시, 좌측만 둥근 모서리, 우측은 직선
                    Text(schedule.title)
                        .font(.system(size: 8))
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.fromHex(schedule.color))
                        .cornerRadius(3, corners: [.topLeft, .bottomLeft])
                } else if schedule.isEnd {
                    // 종료일: 제목 없음, 우측만 둥근 모서리, 좌측은 직선
                    Color.fromHex(schedule.color)
                        .cornerRadius(3, corners: [.topRight, .bottomRight])
                } else {
                    // 중간일: 제목 없음, 모서리 없이 직선 (막대 연결)
                    Color.fromHex(schedule.color)
                }
            } else {
                // 단일 일정: Period 일정과 완전히 동일한 구조
                Text(schedule.title)
                    .font(.system(size: 8))
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.fromHex(schedule.color))
                    .cornerRadius(3)
            }
        }
        .frame(width: width, height: 16, alignment: .leading)
    }
}

// MARK: - Widget Configuration
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("주간 달력")
        .description("이번 주의 일정을 한눈에 확인하세요.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Helper Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct CalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let today = Date()

        let weekDates = (0..<7).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day, to: today)
        }

        let sampleSchedules: [Date: [ScheduleData]] = [
            weekDates[0]: [
                ScheduleData(title: "회의", color: "FF6B6B", isPeriod: false, isStart: true, isEnd: true),
                ScheduleData(title: "프로젝트", color: "4ECDC4", isPeriod: true, isStart: true, isEnd: false)
            ],
            weekDates[1]: [
                ScheduleData(title: "프로젝트", color: "4ECDC4", isPeriod: true, isStart: false, isEnd: false),
                ScheduleData(title: "운동", color: "95E1D3", isPeriod: false, isStart: true, isEnd: true)
            ]
        ]

        CalendarWidgetView(
            entry: CalendarEntry(
                date: today,
                weekDates: weekDates,
                schedules: sampleSchedules
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
