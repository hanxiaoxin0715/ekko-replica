import ActivityKit
import SwiftUI
import WidgetKit

/// 复刻 Ekko 的 StudioTaskLiveActivity 扩展。
/// 对应关系：
///   ActivityConfiguration(for:content:dynamicIsland:)  ← 锁屏 + 灵动岛
///   DynamicIsland(expanded:compactLeading:compactTrailing:minimal:)  ← 四区域全自定义
///   .keylineTint / .activityBackgroundTint / .activitySystemActionForegroundColor
struct StudioTaskLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudioTaskAttributes.self) { context in
            LockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.agent, systemImage: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.stepsText)
                        .font(.caption2.monospacedDigit())
                        .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline)
                        .lineLimit(1)
                        // 可选增强（Ekko 用了这个）：
                        // .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        StatusPill(text: statusText(context),
                                   tint: tint(for: context.state.status))
                        Spacer()
                        if context.state.status == .waiting && !context.isStale {
                            Button(intent: ApproveTaskIntent(taskId: context.attributes.taskId)) {
                                Label("批准", systemImage: "checkmark.circle.fill")
                                    .font(.caption2)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: icon(for: context.state.status))
                    .foregroundStyle(tint(for: context.state.status))
            } compactTrailing: {
                Text("\(context.state.stepDone)/\(context.state.stepTotal)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(tint(for: context.state.status))
            } minimal: {
                Image(systemName: icon(for: context.state.status))
                    .foregroundStyle(tint(for: context.state.status))
            }
            .keylineTint(.orange)
            .widgetURL(URL(string: "\(AppConfig.urlScheme)://task/\(context.attributes.taskId)"))
        }
    }
}

// MARK: - 锁屏视图

private struct LockScreenView: View {
    let context: ActivityViewContext<StudioTaskAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                Text(context.attributes.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(context.state.stepsText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(context.state.stepDone),
                         total: Double(max(context.state.stepTotal, 1)))
                .tint(tint(for: context.state.status))

            HStack(spacing: 12) {
                StatusPill(text: statusText(context),
                           tint: tint(for: context.state.status))
                Spacer()
                Text(context.state.ioText)
                Text(context.state.tokensText)
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        .padding(14)
    }
}

// MARK: - 状态胶囊

private struct StatusPill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.22), in: Capsule())
            .foregroundStyle(tint)
    }
}

// MARK: - 状态映射

private func statusText(_ context: ActivityViewContext<StudioTaskAttributes>) -> String {
    if context.isStale { return "进度暂未同步" }
    switch context.state.status {
    case .running: return "运行中"
    case .waiting: return "需要处理"
    case .completed: return "已完成"
    case .failed: return "失败"
    }
}

private func tint(for status: TaskStatus) -> Color {
    switch status {
    case .running: return .orange
    case .waiting: return .yellow
    case .completed: return .green
    case .failed: return .red
    }
}

private func icon(for status: TaskStatus) -> String {
    switch status {
    case .running: return "bolt.horizontal.circle.fill"
    case .waiting: return "hand.raised.circle.fill"
    case .completed: return "checkmark.circle.fill"
    case .failed: return "xmark.circle.fill"
    }
}
