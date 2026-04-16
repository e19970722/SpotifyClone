# Token 管理機制

本文件說明 SpotifyClone 中 authentication token 的完整生命週期，包含本位定義、儲存與持久化、注入方式、過期偵測、更新流程，以及銷毀邏輯。

---

## Token 本位

| 本位 | 型別 | 說明 |
|------|------|------|
| `accessToken` | `String?` | 每次 API 請求帶入的 Bearer token |
| `refreshToken` | `String?` | 用來獲取新 access token，避免使用者重新登入 |
| `expiresIn` | `Int` | Access token 的有效秒數（由 Spotify 回傳） |

---

## Token 儲存

### 執行階段 — `UserManager`

`UserManager`（singleton、`@ObservableObject`）是執行階段所有 token 狀態的**唯一協調者**。

**檔案：** `SpotifyClone/Core/User/UserManager.swift`

### `KeychainManager`

安全性較高的 token 存入 iOS Keychain：

| Token | 儲存位置 | Key |
|-------|----------|-----|
| `accessToken` | Keychain（`kSecClassGenericPassword`） | `"access_token"` |
| `refreshToken` | Keychain（`kSecClassGenericPassword`） | `"refresh_token"` |

**檔案：** `SpotifyClone/Core/Keychain/KeychainManager.swift`

### `SpotifyUserDefaults`

過期時間相關資料存入 UserDefaults（suite: `"com.Spotify.Settings"`）：

| 資料 | Key | 型別 |
|------|-----|------|
| `expiryToken` | `"expiry_token"` | `Int?`（原始秒數，由 Spotify 回傳） |
| `tokenExpiryDate` | `"token_expiry_date"` | `Double?`（Unix timestamp，計算後的絕對到期時間） |

**檔案：** `SpotifyClone/Core/SpotifyUserDefaults.swift`

### App 啟動時恢復登入狀態

`UserManager.init()` 啟動後從 Keychain / UserDefaults 讀回 token，依狀態決定處理方式：

| 狀態 | 處理 |
|------|------|
| `tokenExpiryDate` 仍有效（`> now`） | 恢復登入狀態，重新啟動 expiry Timer |
| token 已過期但有 refresh token | 保持登入狀態，立即呼叫 `handleTokenExpired(showLaunchScreen: true)` 更新 |
| 無任何有效憑證 | 清除 Keychain，設為未登入 |

---

## Bearer Token 注入

`SpotifyAPIConfig` 在每次 API 請求建立時讀取當下的 access token：

```swift
// SpotifyClone/Core/Network/SpotifyAPIConfig.swift
static var authHeader: [String: String] {
    guard let token = KeychainManager.shared.read(forKey: .accessToken) else { return [:] }
    return ["Authorization": "Bearer \(token)"]
}
```

Token 在 request 建立當下讀取，因此 refresh 成功後的下一次請求即使用新 token。

> `accessToken` 不存在時，header 回傳空字典 `[:]`，API 請求將以 401 失敗。

---

## 登入流程

### Spotify OAuth 2.0（PKCE）

```
使用者點擊「Login」
        ↓
OAuthManager.loginWithSpotify()
  → 產生 PKCE code verifier / challenge
  → 開啟 ASWebAuthenticationSession
  → scope: user-read-private user-library-read user-read-email
           playlist-read-private playlist-read-collaborative
        ↓
使用者在瀏覽器完成授權
        ↓
App 透過 redirect URI (spotifyclone://callback) 收到 authorization code
        ↓
POST https://accounts.spotify.com/api/token
grant_type = "authorization_code"
        ↓
回傳：SpotifyTokenResponse
  accessToken, refreshToken, expiresIn, tokenType, scope
        ↓
userManager.saveSession(accessToken:, refreshToken:, expiresIn:)
  → 寫入 Keychain
  → 計算 tokenExpiryDate = now + expiresIn - 5 分鐘
  → 存入 SpotifyUserDefaults
  → 啟動 expiry Timer
        ↓
userManager.isLoggedIn = true
→ AppInitialView 切換至 AppTabBarView
→ fetchHomeInfo()（取得使用者資料與播放清單）
```

**檔案：**
- `SpotifyClone/Core/Initialization/OAuth/OAuthManager.swift`
- `SpotifyClone/Core/Initialization/Login/LoginView.swift`

---

## Token 過期偵測

### 過期時間計算

每次 `saveSession()` / `persistTokens()` 執行時，計算並儲存絕對到期時間點 `tokenExpiryDate`：

```
saveSession() / persistTokens()
        ↓
tokenExpiryDate = Date() + TimeInterval(expiresIn) - 300 秒（5 分鐘緩衝）
        ↓
├── SpotifyUserDefaults.shared.tokenExpiryDate = expiryDate（Unix timestamp）
└── scheduleExpiryTimer(at: expiryDate)（啟動一次性 Timer）
```

提前 5 分鐘是為了預留 refresh 的緩衝時間，避免 token 在請求途中才到期。`Date` 以 UTC 為基準，不受時區影響。

### 觸發機制

| 層級 | 觸發來源 | 涵蓋場景 |
|------|----------|----------|
| 啟動時檢查 | `UserManager.init()` | App 已被終止，token 在離線期間到期 |
| 一次性 Timer | 在 `tokenExpiryDate` 到點觸發 | App 在**前景**時 token 到期 |
| 進後景停止 | `UIApplication.didEnterBackgroundNotification` | 停止 Timer，避免背景無效觸發 |
| 回前景檢查 | `UIApplication.didBecomeActiveNotification` | App 回前景時若 token 已過期 |

**進後景與回前景的行為：**
App 進後景時主動呼叫 `stopTokenTimer()` 停止 Timer。回到前景時，`didBecomeActiveNotification` 觸發 `checkTokenExpiry(showLaunchScreen: true)`：
- 若 token **已過期** → 立即更新，顯示 LaunchScreen
- 若 token **仍有效** → 以 `timeIntervalSinceNow` 重新計算剩餘時間，重新啟動 Timer

兩個觸發路徑都走統一入口 `checkTokenExpiry()`，透過比對 `tokenExpiryDate` 確認是否真正過期後才進入 `handleTokenExpired()`：

```
Timer 到期              ──▶  checkTokenExpiry()                    ──▶  handleTokenExpired()
回前景 Notification     ──▶  checkTokenExpiry(showLaunchScreen: true)  ──▶  handleTokenExpired(showLaunchScreen: true)
```

### 防止過期 Token 發 API（`isRefreshingToken`）

Token refresh 從啟動到完成之間有時間差。若 refresh 尚未完成，畫面已渲染並發出 API，將使用過期 token 導致 401。

`handleTokenExpired(showLaunchScreen:)` 在特定情境下設 `isRefreshingToken = true`，`AppInitialView` 在此期間顯示黑色 `ProgressView` 以阻擋所有 API 呼叫。

| 呼叫來源 | showLaunchScreen | 行為 |
|---------|-----------------|------|
| 啟動時（`restoreSession`） | `true` | 顯示 ProgressView，等待更新完成 |
| 回前景（`didBecomeActiveNotification`） | `true` | 顯示 ProgressView，等待更新完成 |
| Timer 到期（前景使用中） | `false`（預設） | 靜默更新，不中斷使用者 |

Refresh 完成（成功或失敗）後，一律重設 `isRefreshingToken = false`。

---

### 防止重複觸發

當 token **剛好在使用者進後景時到期**，Timer 觸發與 notification 可能幾乎同時觸發，導致兩個 `handleTokenExpired()` 並行執行。若兩個 async Task 都完整跑完，可能發生：

- 兩次 refresh API 請求都帶同一個 refresh token
- 伺服器採用 rotating refresh token（一次性使用）時，第二個請求被拒絕
- catch error → `forceLogout()` → 使用者被誤登出

**兩層防護：**

**第一層 — `checkTokenExpiry()` 比對時間**
Timer 不直接呼叫 `handleTokenExpired()`，而是先經過 `checkTokenExpiry()` 確認 `Date() >= tokenExpiryDate`，避免 Timer 略早觸發造成誤判。

**第二層 — `Task.checkCancellation()`**
每次呼叫 `handleTokenExpired()` 時，先 cancel 上一個 Task，新 Task 在網路請求返回後立即呼叫 `try Task.checkCancellation()`。被 cancel 的 Task 收到 API 結果後靜默退出，不寫入 token、不觸發登出。

```swift
refreshTokenTask?.cancel()
refreshTokenTask = Task {
    let result = try await OAuthManager.instance.refreshAccessToken(refreshToken: rt)
    try Task.checkCancellation()   // 被 cancel 的 Task 在此靜默退出
    await MainActor.run { persistTokens(result: result); isRefreshingToken = false }
}
```

> ⚠️ `Task.cancel()` 只設 cancellation flag，不會中斷 `withCheckedThrowingContinuation` 內的 URLSession 網路請求，因此兩個 Task 仍可能都發出 API 請求，但只有最後建立的 Task 才會寫入結果。

### 過期後的處理流程

`handleTokenExpired()` 是唯一的過期處理入口，只嘗試靜默更新，失敗或無 refresh token 時強制登出，不顯示任何 alert。

```
handleTokenExpired()
        ↓
├── refreshToken == nil？
│       └── forceLogout() → 導回登入頁
│
└── OAuthManager.instance.refreshAccessToken(refreshToken)
        ↓
        ├── 成功 → 更新 accessToken / refreshToken / expiresIn
        │          persistTokens() → 計算新 tokenExpiryDate、重新啟動 Timer
        │          isRefreshingToken = false
        │          （使用者維持登入）
        │
        └── 失敗 / Task 被 cancel
                └── forceLogout()
                        → clearTokensFromKeychain()
                            → tokenTimer 停止
                            → Keychain 項目刪除
                            → SpotifyUserDefaults.expiryToken = nil
                            → SpotifyUserDefaults.tokenExpiryDate = nil
                        → defaultUser = nil
                        → isLoggedIn = false
                        → AppInitialView 重新渲染 → LoginView（無 alert）
```

---

## 登出與 Token 銷毀

```
使用者觸發登出
        ↓
UserManager.logout()
        ↓
clearTokensFromKeychain()
  → stopTokenTimer()
  → KeychainManager.shared.delete(.accessToken)
  → KeychainManager.shared.delete(.refreshToken)
  → SpotifyUserDefaults.shared.expiryToken = nil
  → SpotifyUserDefaults.shared.tokenExpiryDate = nil
        ↓
defaultUser = nil
isLoggedIn = false
→ AppInitialView 切換至 LoginView
```

> 本專案目前登出為本機清除，未呼叫 Spotify token revocation endpoint。

---

## 錯誤處理摘要

| 場景 | 行為 |
|------|------|
| Token 正常到期（前景 Timer） | 靜默更新，不顯示 ProgressView |
| 啟動時或回前景時 token 過期 | `isRefreshingToken = true` → 顯示 ProgressView → 更新完成後恢復 |
| 更新成功 | 新 token 寫入 Keychain，Timer 重新啟動，使用者維持登入 |
| 更新失敗（網路或伺服器錯誤） | `forceLogout()` → `isLoggedIn = false` → 導回登入頁（無 alert） |
| 到期時無 refresh token | 直接 `forceLogout()`，不發 API |
| API 回傳 401 | 無自動處理，由各 ViewModel / View 自行處理 |
| 請求時 `accessToken` 為 nil | `authHeader` 回傳空字典 `[:]` |
| 帶有效 token 重啟 App | `UserManager.init()` 自動恢復登入狀態 |
| 重啟 App 但 token 已過期 | 若有 refresh token 則更新，否則導回登入頁 |
| 重啟 App 且無任何 token | `isLoggedIn = false`，使用者看到登入頁 |

---

## 關鍵檔案

| 檔案 | 職責 |
|------|------|
| `SpotifyClone/Core/User/UserManager.swift` | Token 執行時狀態、Keychain 存取、Timer 啟動、過期與 refresh 邏輯 |
| `SpotifyClone/Core/Keychain/KeychainManager.swift` | Keychain 存取（save / read / delete） |
| `SpotifyClone/Core/Initialization/OAuth/OAuthManager.swift` | OAuth 2.0 PKCE 授權流程、`refreshAccessToken()` |
| `SpotifyClone/Core/SpotifyUserDefaults.swift` | 儲存 `expiryToken` 與 `tokenExpiryDate` |
| `SpotifyClone/Core/Network/SpotifyAPIConfig.swift` | 將 Bearer token 注入所有 API 請求 |
| `SpotifyClone/Core/Initialization/Login/LoginView.swift` | 觸發 OAuth、呼叫 `saveSession()` |
| `SpotifyClone/Core/Initialization/AppInitialView.swift` | 依 `isLoggedIn` / `isRefreshingToken` 控制根視圖切換 |
