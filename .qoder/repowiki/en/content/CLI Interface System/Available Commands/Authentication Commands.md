# Authentication Commands

<cite>
**Referenced Files in This Document**
- [auth.py](file://quark_client/cli/commands/auth.py)
- [login.py](file://quark_client/auth/login.py)
- [api_login.py](file://quark_client/auth/api_login.py)
- [simple_login.py](file://quark_client/auth/simple_login.py)
- [qr_code.py](file://quark_client/utils/qr_code.py)
- [main.py](file://quark_client/cli/main.py)
- [client.py](file://quark_client/client.py)
- [config.py](file://quark_client/config.py)
- [exceptions.py](file://quark_client/exceptions.py)
- [utils.py](file://quark_client/cli/utils.py)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)

## Introduction
This document provides comprehensive documentation for authentication-related CLI commands in the Quark Pan CLI. It covers the login command with QR code authentication flow, cookie-based login methods, session persistence, logout functionality, and session cleanup. It also explains command syntax, parameter options, authentication timeout handling, error scenarios, practical examples, troubleshooting, and security considerations for automated authentication scripts.

## Project Structure
The authentication functionality is organized across CLI commands, authentication modules, utilities, and client integration:

- CLI commands for authentication are defined under the CLI commands package.
- Authentication logic is encapsulated in dedicated modules for API login, simple login, and cookie management.
- Utilities support QR code rendering and client utilities.
- The client integrates authentication with API operations.

```mermaid
graph TB
subgraph "CLI Layer"
A["auth.py<br/>Authentication commands"]
B["main.py<br/>Main CLI entry"]
C["utils.py<br/>CLI utilities"]
end
subgraph "Auth Modules"
D["login.py<br/>QuarkAuth manager"]
E["api_login.py<br/>QR code login flow"]
F["simple_login.py<br/>Manual login flow"]
end
subgraph "Utilities"
G["qr_code.py<br/>QR rendering"]
H["config.py<br/>Config & defaults"]
end
subgraph "Client Integration"
I["client.py<br/>QuarkClient"]
J["exceptions.py<br/>Custom exceptions"]
end
A --> D
A --> I
D --> E
D --> F
E --> G
I --> D
B --> A
B --> C
C --> I
D --> H
E --> J
F --> J
```

**Diagram sources**
- [auth.py:1-188](file://quark_client/cli/commands/auth.py#L1-L188)
- [login.py:1-301](file://quark_client/auth/login.py#L1-L301)
- [api_login.py:1-521](file://quark_client/auth/api_login.py#L1-L521)
- [simple_login.py:1-249](file://quark_client/auth/simple_login.py#L1-L249)
- [qr_code.py:1-46](file://quark_client/utils/qr_code.py#L1-L46)
- [main.py:1-609](file://quark_client/cli/main.py#L1-L609)
- [client.py:1-405](file://quark_client/client.py#L1-L405)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)
- [utils.py:1-273](file://quark_client/cli/utils.py#L1-L273)

**Section sources**
- [auth.py:1-188](file://quark_client/cli/commands/auth.py#L1-L188)
- [main.py:1-609](file://quark_client/cli/main.py#L1-L609)

## Core Components
- CLI authentication commands: login, logout, status, info.
- Authentication managers: QuarkAuth for cookie management and login orchestration, APILogin for QR-based login, SimpleLogin for manual login.
- Client integration: QuarkClient wraps authentication and API operations.
- Utilities: QR code rendering and CLI helpers.

Key responsibilities:
- Login command orchestrates method selection and displays feedback.
- QuarkAuth manages cookie persistence and validation.
- APILogin handles QR generation, status polling, and token management.
- SimpleLogin provides manual cookie input and validation.
- Logout clears stored credentials.
- Status checks login state and storage usage.

**Section sources**
- [auth.py:13-188](file://quark_client/cli/commands/auth.py#L13-L188)
- [login.py:15-301](file://quark_client/auth/login.py#L15-L301)
- [api_login.py:20-521](file://quark_client/auth/api_login.py#L20-L521)
- [simple_login.py:16-249](file://quark_client/auth/simple_login.py#L16-L249)
- [client.py:18-405](file://quark_client/client.py#L18-L405)

## Architecture Overview
The authentication flow integrates CLI commands, authentication managers, and client utilities. The CLI commands delegate to QuarkClient, which coordinates QuarkAuth. Depending on the selected method, QuarkAuth invokes APILogin (QR-based) or SimpleLogin (manual). Cookies are persisted locally and reused until expiration.

```mermaid
sequenceDiagram
participant User as "User"
participant CLI as "auth.py"
participant Client as "QuarkClient"
participant Auth as "QuarkAuth"
participant API as "APILogin"
participant QR as "qr_code.py"
participant FS as "Local Storage"
User->>CLI : "quarkpan auth login [--method|--force]"
CLI->>Client : "get_client(auto_login=False)"
Client->>Auth : "login(force_relogin, method)"
Auth->>FS : "_load_cookies()"
alt "Saved cookies valid"
FS-->>Auth : "cookies"
Auth-->>Client : "cookie_string"
else "No valid cookies"
Auth->>API : "_api_login()" or "_simple_login()"
API->>API : "get_qr_code()"
API->>QR : "display_qr_from_url(url)"
API->>API : "wait_for_login(token)"
API->>FS : "_save_login_result() -> cookies"
API-->>Auth : "cookie_string"
Auth-->>Client : "cookie_string"
end
Client-->>CLI : "login success/failure"
CLI-->>User : "status and messages"
```

**Diagram sources**
- [auth.py:13-92](file://quark_client/cli/commands/auth.py#L13-L92)
- [client.py:50-74](file://quark_client/client.py#L50-L74)
- [login.py:107-259](file://quark_client/auth/login.py#L107-L259)
- [api_login.py:467-521](file://quark_client/auth/api_login.py#L467-L521)
- [qr_code.py:40-46](file://quark_client/utils/qr_code.py#L40-L46)

## Detailed Component Analysis

### CLI Authentication Commands
- Command group: auth_app with subcommands login, logout, status, info.
- Options:
  - login: --force/-f, --method/-m, --api, --simple.
  - logout: no options.
  - status: no options.
  - info: no options.
- Behavior:
  - login: checks existing session, selects method, executes login, validates and prints account info.
  - logout: checks login state, performs logout, clears local cookies.
  - status: checks login state, prints storage usage.
  - info: prints help and examples.

```mermaid
flowchart TD
Start(["auth login"]) --> CheckForce["Check --force"]
CheckForce --> LoadCookies["Load saved cookies"]
LoadCookies --> HasCookies{"Valid cookies?"}
HasCookies --> |Yes| ReturnCookies["Return cookie string"]
HasCookies --> |No| SelectMethod["Select method (--api/--simple/auto)"]
SelectMethod --> ExecLogin["Execute login via QuarkAuth"]
ExecLogin --> SaveCookies["Save cookies to file"]
SaveCookies --> Verify["Verify login and fetch storage info"]
Verify --> Done(["Success"])
```

**Diagram sources**
- [auth.py:13-92](file://quark_client/cli/commands/auth.py#L13-L92)
- [login.py:107-259](file://quark_client/auth/login.py#L107-L259)

**Section sources**
- [auth.py:13-188](file://quark_client/cli/commands/auth.py#L13-L188)

### QuarkAuth Manager
Responsibilities:
- Cookie persistence: save/load cookies to JSON file with timestamps and expiry.
- Validation: check cookie presence and required keys (__pus, __kps, __uid).
- Login orchestration: auto, API, or simple login methods.
- Logout: remove stored cookies.

Key methods:
- login(force_relogin, method): orchestrates login flow.
- get_cookies(force_relogin): returns valid cookie string.
- is_logged_in(): checks validity.
- logout(): clears stored cookies.

```mermaid
classDiagram
class QuarkAuth {
+int timeout
+Path config_dir
+Path cookies_file
+login(force_relogin, method) str
+get_cookies(force_relogin) str
+is_logged_in() bool
+logout() void
-_load_cookies() Dict
-_save_cookies(cookies) void
-_is_cookies_expired(data) bool
-_validate_cookies(cookies) bool
-_auto_login() str
-_api_login() str
-_simple_login() str
}
```

**Diagram sources**
- [login.py:15-301](file://quark_client/auth/login.py#L15-L301)

**Section sources**
- [login.py:15-301](file://quark_client/auth/login.py#L15-L301)

### API Login (QR Code Flow)
- QR generation: calls external API to obtain token and constructs QR URL.
- QR display: renders ASCII QR code in terminal or prints URL fallback.
- Status polling: periodically checks service ticket status with exponential-like intervals.
- Timeout handling: configurable timeout with countdown display.
- Token management: extracts cookies after successful login and saves them.

```mermaid
sequenceDiagram
participant CLI as "auth.py"
participant API as "APILogin"
participant QR as "qr_code.py"
participant Net as "HTTPX Client"
participant FS as "Local Storage"
CLI->>API : "login()"
API->>Net : "GET getTokenForQrcodeLogin"
Net-->>API : "qr_token, qr_url"
API->>QR : "display_qr_from_url(qr_url)"
loop Polling
API->>Net : "GET getServiceTicketByQrcodeToken"
Net-->>API : "status ok/not ok/pending"
end
API->>Net : "GET account/info with st"
Net-->>API : "user info (cookies set)"
API->>FS : "save login_result.json and cookies"
API-->>CLI : "cookie_string"
```

**Diagram sources**
- [api_login.py:94-521](file://quark_client/auth/api_login.py#L94-L521)
- [qr_code.py:40-46](file://quark_client/utils/qr_code.py#L40-L46)

**Section sources**
- [api_login.py:20-521](file://quark_client/auth/api_login.py#L20-L521)
- [qr_code.py:1-46](file://quark_client/utils/qr_code.py#L1-L46)

### Simple Login (Manual Flow)
- Manual guidance: prints step-by-step instructions to obtain cookies from browser developer tools.
- Input validation: ensures required cookie keys are present.
- Persistence: saves cookie data to JSON file with timestamp.
- Reuse: loads saved cookies if not expired.

```mermaid
flowchart TD
Start(["SimpleLogin.login"]) --> LoadSaved["Load saved cookies"]
LoadSaved --> SavedValid{"Valid?"}
SavedValid --> |Yes| ReturnSaved["Return saved cookie string"]
SavedValid --> |No| ManualGuide["Print manual guide"]
ManualGuide --> InputLoop["Input cookie string"]
InputLoop --> Validate["Validate format and keys"]
Validate --> Valid{"Valid?"}
Valid --> |Yes| Save["Save to cookies.json"]
Save --> ReturnCookie["Return cookie string"]
Valid --> |No| Retry["Prompt retry"]
Retry --> InputLoop
```

**Diagram sources**
- [simple_login.py:28-249](file://quark_client/auth/simple_login.py#L28-L249)

**Section sources**
- [simple_login.py:16-249](file://quark_client/auth/simple_login.py#L16-L249)

### Client Integration
- QuarkClient delegates authentication to QuarkAuth and updates API client cookies.
- Methods: login, logout, is_logged_in, get_storage_info.
- Integration with CLI utilities for status reporting.

```mermaid
classDiagram
class QuarkClient {
+QuarkAPIClient api_client
+login(force_relogin, use_qr, method) str
+logout() void
+is_logged_in() bool
+get_storage_info() Dict
}
class QuarkAuth {
+login(force_relogin, method) str
+logout() void
+is_logged_in() bool
}
QuarkClient --> QuarkAuth : "uses"
```

**Diagram sources**
- [client.py:18-405](file://quark_client/client.py#L18-L405)
- [login.py:15-301](file://quark_client/auth/login.py#L15-L301)

**Section sources**
- [client.py:18-405](file://quark_client/client.py#L18-L405)

## Dependency Analysis
- CLI commands depend on QuarkClient and CLI utilities.
- QuarkAuth depends on configuration directory and exceptions.
- APILogin depends on HTTPX client, QR utilities, and exceptions.
- SimpleLogin depends on configuration directory and exceptions.
- Client depends on QuarkAuth and API client.

```mermaid
graph TB
CLI["auth.py"] --> Client["client.py"]
Client --> Auth["login.py"]
Auth --> API["api_login.py"]
Auth --> Simple["simple_login.py"]
API --> QR["qr_code.py"]
Client --> Config["config.py"]
Auth --> Exceptions["exceptions.py"]
API --> Exceptions
Simple --> Exceptions
CLI --> Utils["utils.py"]
```

**Diagram sources**
- [auth.py:1-188](file://quark_client/cli/commands/auth.py#L1-L188)
- [client.py:1-405](file://quark_client/client.py#L1-L405)
- [login.py:1-301](file://quark_client/auth/login.py#L1-L301)
- [api_login.py:1-521](file://quark_client/auth/api_login.py#L1-L521)
- [simple_login.py:1-249](file://quark_client/auth/simple_login.py#L1-L249)
- [qr_code.py:1-46](file://quark_client/utils/qr_code.py#L1-L46)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)
- [utils.py:1-273](file://quark_client/cli/utils.py#L1-L273)

**Section sources**
- [auth.py:1-188](file://quark_client/cli/commands/auth.py#L1-L188)
- [client.py:1-405](file://quark_client/client.py#L1-L405)
- [login.py:1-301](file://quark_client/auth/login.py#L1-L301)
- [api_login.py:1-521](file://quark_client/auth/api_login.py#L1-L521)
- [simple_login.py:1-249](file://quark_client/auth/simple_login.py#L1-L249)
- [qr_code.py:1-46](file://quark_client/utils/qr_code.py#L1-L46)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)
- [utils.py:1-273](file://quark_client/cli/utils.py#L1-L273)

## Performance Considerations
- QR polling interval: the polling loop checks status every few seconds; adjust timeout to balance responsiveness and network usage.
- Cookie persistence: loading and saving cookies is lightweight; ensure filesystem access is fast.
- Network requests: APILogin uses HTTPX with reasonable timeouts; avoid excessive retries to prevent rate limiting.
- Terminal rendering: QR ASCII rendering is CPU-light; fallback to URL printing reduces overhead.

[No sources needed since this section provides general guidance]

## Troubleshooting Guide
Common issues and resolutions:
- Login fails with invalid credentials or expired cookies:
  - Use --force to force re-login.
  - Try --simple for manual cookie input.
- QR code does not appear or scanning fails:
  - Ensure network connectivity and browser availability.
  - Use fallback URL printed when ASCII QR rendering fails.
- Authentication timeout:
  - Increase timeout setting for APILogin if needed.
  - Re-run login command.
- Session not recognized:
  - Run status to verify login state.
  - Clear cookies via logout and re-login.
- Automated scripts:
  - Prefer --simple with pre-obtained cookies for reliability.
  - Store cookies securely and manage expiry.

**Section sources**
- [auth.py:82-91](file://quark_client/cli/commands/auth.py#L82-L91)
- [api_login.py:347-406](file://quark_client/auth/api_login.py#L347-L406)
- [simple_login.py:28-94](file://quark_client/auth/simple_login.py#L28-L94)

## Conclusion
The authentication subsystem provides robust, user-friendly login options with QR-based and manual flows, persistent cookie management, and clear CLI feedback. The design separates concerns between CLI commands, authentication managers, and utilities, enabling maintainable and extensible authentication workflows. For production automation, prefer manual cookie input and secure storage to minimize reliance on interactive flows.