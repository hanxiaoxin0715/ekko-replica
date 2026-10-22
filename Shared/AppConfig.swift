import Foundation

/// App 与 Widget 扩展共用的配置。
/// 两个 target 都编译这个文件，所以不需要 App Group（免费签名也能跑）。
enum AppConfig {
    /// 你的 Ekko 服务端地址。改成自己局域网里的 IP + 端口。
    /// 自托管默认端口：npm 版 8648，Docker 版 6060。
    static let serverBaseURL = "http://192.168.1.10:8648"

    /// 点灵动岛上的「批准」时请求的路径。
    /// 换成你服务端真实的审批接口即可。
    static let approvePath = "/api/demo/approve"

    static let urlScheme = "ekkolite"
}
