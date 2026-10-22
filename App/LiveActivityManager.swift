import ActivityKit
import Foundation

/// 灵动岛 / 锁屏活动的生命周期管理。
/// 对应 Ekko 的 UTS 插件 ekkoLiveActivity 里的
/// startActivity / updateActivity / endActivity。
@MainActor
final class LiveActivityManager {

    static let shared = LiveActivityManager()

    private var activity: Activity<StudioTaskAttributes>?

    private init() {}

    /// 系统是否允许实时活动（设置 → 灵动岛 里的开关）
    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    var isRunning: Bool { activity != nil }

    /// 启动一个活动
    func start(title: String,
               agent: String = "Ekko Agent",
               stepTotal: Int = 5) throws {
        guard areActivitiesEnabled else {
            throw LiveActivityError.notAuthorized
        }
        // 同一时间只保留一个，避免叠一堆
        if let existing = activity {
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
            activity = nil
        }

        let attributes = StudioTaskAttributes(
            taskId: UUID().uuidString,
            title: title,
            agent: agent
        )
        let state = StudioTaskAttributes.ContentState(
            status: .running,
            stepDone: 0,
            stepTotal: stepTotal,
            summary: "开始执行"
        )

        activity = try Activity.request(
            attributes: attributes,
            content: .init(state: state, staleDate: Date().addingTimeInterval(120)),
            pushType: nil
        )
    }

    /// 更新内容（本地更新；远程推送需要付费开发者账号）
    func update(_ state: StudioTaskAttributes.ContentState) async {
        guard let activity else { return }
        await activity.update(
            .init(state: state, staleDate: Date().addingTimeInterval(120))
        )
    }

    /// 结束并让灵动岛收起
    func end(finalState: StudioTaskAttributes.ContentState? = nil) async {
        guard let activity else { return }
        if let finalState {
            await activity.end(
                .init(state: finalState, staleDate: nil),
                dismissalPolicy: .default
            )
        } else {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}

enum LiveActivityError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "实时活动被关闭了。去 设置 → Ekko Lite → 实时活动 打开。"
        }
    }
}
