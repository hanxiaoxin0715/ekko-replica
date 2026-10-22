import ActivityKit
import Foundation

/// 任务状态枚举 —— 对应 Ekko 扩展里的 5 个本地化 key：
/// live_activity.status.running / waiting / completed / failed / stale
public enum TaskStatus: String, Codable, Hashable, Sendable {
    case running
    case waiting
    case completed
    case failed
}

/// 复刻 Ekko 的 ActivityAttributes 结构。
/// 名字沿用它的 StudioTaskAttributes，方便对照。
public struct StudioTaskAttributes: ActivityAttributes {

    /// 会随推送/更新变化的部分
    public struct ContentState: Codable, Hashable {
        public var status: TaskStatus
        public var stepDone: Int
        public var stepTotal: Int
        public var tokensIn: Int
        public var tokensOut: Int
        public var summary: String

        public init(status: TaskStatus = .running,
                    stepDone: Int = 0,
                    stepTotal: Int = 5,
                    tokensIn: Int = 0,
                    tokensOut: Int = 0,
                    summary: String = "") {
            self.status = status
            self.stepDone = stepDone
            self.stepTotal = stepTotal
            self.tokensIn = tokensIn
            self.tokensOut = tokensOut
            self.summary = summary
        }

        /// 对应 live_activity.metrics.steps
        public var stepsText: String { "\(stepDone)/\(stepTotal) 步" }

        /// 对应 live_activity.metrics.io
        public var ioText: String { "↑\(tokensIn) ↓\(tokensOut)" }

        /// 对应 live_activity.metrics.tokens
        public var tokensText: String { "\(tokensIn + tokensOut) tokens" }
    }

    /// 整个活动生命周期内不变的部分
    public var taskId: String
    public var title: String
    public var agent: String

    public init(taskId: String, title: String, agent: String) {
        self.taskId = taskId
        self.title = title
        self.agent = agent
    }
}
