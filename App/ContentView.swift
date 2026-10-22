import SwiftUI

struct ContentView: View {

    @State private var title = "重构登录流程"
    @State private var status: TaskStatus = .running
    @State private var stepDone = 0
    @State private var stepTotal = 5
    @State private var tokensIn = 0
    @State private var tokensOut = 0
    @State private var running = false
    @State private var message = ""

    private var manager: LiveActivityManager { .shared }

    private var currentState: StudioTaskAttributes.ContentState {
        StudioTaskAttributes.ContentState(
            status: status,
            stepDone: stepDone,
            stepTotal: stepTotal,
            tokensIn: tokensIn,
            tokensOut: tokensOut,
            summary: ""
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("任务") {
                    TextField("标题", text: $title)
                    LabeledContent("状态", value: statusLabel)
                    LabeledContent("进度", value: "\(stepDone)/\(stepTotal)")
                    LabeledContent("Tokens", value: "\(tokensIn + tokensOut)")
                }

                Section("灵动岛") {
                    Button("启动实时活动") { start() }
                        .disabled(running)
                    Button("推进一步") { advance() }
                        .disabled(!running)
                    Button("标记为需要处理") { setStatus(.waiting) }
                        .disabled(!running)
                    Button("标记为完成") { complete() }
                        .disabled(!running)
                    Button("结束", role: .destructive) { end() }
                        .disabled(!running)
                }

                if !message.isEmpty {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ekko Lite")
        }
    }

    private var statusLabel: String {
        switch status {
        case .running: return "运行中"
        case .waiting: return "需要处理"
        case .completed: return "已完成"
        case .failed: return "失败"
        }
    }

    private func start() {
        do {
            try manager.start(title: title, stepTotal: stepTotal)
            running = true
            message = "已启动。回桌面看灵动岛，或下拉看锁屏。"
        } catch {
            message = error.localizedDescription
        }
    }

    private func advance() {
        stepDone = min(stepDone + 1, stepTotal)
        tokensIn += 120
        tokensOut += 340
        if stepDone >= stepTotal { status = .completed }
        let snapshot = currentState
        Task { await manager.update(snapshot) }
        message = "已更新到 \(stepDone)/\(stepTotal)"
    }

    private func setStatus(_ value: TaskStatus) {
        status = value
        let snapshot = currentState
        Task { await manager.update(snapshot) }
    }

    private func complete() {
        status = .completed
        stepDone = stepTotal
        let snapshot = currentState
        Task { await manager.update(snapshot) }
    }

    private func end() {
        let snapshot = currentState
        Task {
            await manager.end(finalState: snapshot)
            running = false
            message = "已结束"
        }
    }
}

#Preview {
    ContentView()
}
