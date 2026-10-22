import AppIntents
import Foundation

/// 灵动岛上的「批准」按钮。
/// 用 LiveActivityIntent，点击后**不打开 App** 就能直接执行 —— 这是 Ekko 的做法
/// （它的扩展链接了 libswiftIntents.dylib，说明用的是同一套机制）。
struct ApproveTaskIntent: LiveActivityIntent {

    static let title: LocalizedStringResource = "批准"
    static let description = IntentDescription("在灵动岛上直接批准任务，不打开 App")

    @Parameter(title: "Task ID")
    var taskId: String

    init() {}

    init(taskId: String) {
        self.taskId = taskId
    }

    func perform() async throws -> some IntentResult {
        guard let url = URL(string: AppConfig.serverBaseURL + AppConfig.approvePath) else {
            return .result()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: ["task_id": taskId, "action": "approve"]
        )

        // 失败也不阻塞 UI，灵动岛照样能收起
        _ = try? await URLSession.shared.data(for: request)
        return .result()
    }
}
