# API Integration Layer

<cite>
**Referenced Files in This Document**
- [api_client.py](file://quark_client/core/api_client.py)
- [client.py](file://quark_client/client.py)
- [config.py](file://quark_client/config.py)
- [exceptions.py](file://quark_client/exceptions.py)
- [api_login.py](file://quark_client/auth/api_login.py)
- [file_service.py](file://quark_client/services/file_service.py)
- [index.ts](file://frontend/src/api/index.ts)
- [quark.ts](file://frontend/src/api/quark.ts)
- [router.py](file://backend/app/api/v1/router.py)
- [auth.py](file://backend/app/api/v1/auth.py)
- [files.py](file://backend/app/api/v1/files.py)
- [Login.vue](file://frontend/src/views/Login.vue)
- [Files.vue](file://frontend/src/views/Files.vue)
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
10. [Appendices](#appendices)

## Introduction
This document describes the API integration layer that connects the frontend Vue application to the backend FastAPI service, which in turn communicates with the Quark Cloud Drive API. It focuses on the client architecture, request/response handling, error management, authentication token handling, interceptors, and response transformation. It also covers service wrappers for Quark API interactions, data fetching patterns, caching strategies, security considerations, rate limiting, offline fallbacks, and guidelines for extending the API layer.

## Project Structure
The API integration spans three layers:
- Backend FastAPI service exposes REST endpoints and delegates to a Quark service wrapper.
- Frontend Axios client encapsulates HTTP requests and response normalization.
- Quark Python client provides a high-level abstraction over the Quark API with authentication and service abstractions.

```mermaid
graph TB
subgraph "Frontend"
FE_API["Axios Client<br/>frontend/src/api/index.ts"]
FE_QUARK["API Definitions<br/>frontend/src/api/quark.ts"]
FE_LOGIN["Login View<br/>frontend/src/views/Login.vue"]
FE_FILES["Files View<br/>frontend/src/views/Files.vue"]
end
subgraph "Backend"
BE_ROUTER["FastAPI Router<br/>backend/app/api/v1/router.py"]
BE_AUTH["Auth Endpoints<br/>backend/app/api/v1/auth.py"]
BE_FILES["Files Endpoints<br/>backend/app/api/v1/files.py"]
end
subgraph "Quark Client"
QC_CORE["QuarkAPIClient<br/>quark_client/core/api_client.py"]
QC_CLIENT["QuarkClient Facade<br/>quark_client/client.py"]
QC_FILE_SERVICE["FileService<br/>quark_client/services/file_service.py"]
QC_CONFIG["Config & Headers<br/>quark_client/config.py"]
QC_EXC["Exceptions<br/>quark_client/exceptions.py"]
QC_AUTH["APILogin<br/>quark_client/auth/api_login.py"]
end
FE_QUARK --> FE_API
FE_API --> BE_ROUTER
BE_ROUTER --> BE_AUTH
BE_ROUTER --> BE_FILES
BE_AUTH --> QC_AUTH
BE_FILES --> QC_FILE_SERVICE
QC_CLIENT --> QC_CORE
QC_FILE_SERVICE --> QC_CORE
QC_CORE --> QC_CONFIG
QC_CORE --> QC_EXC
```

**Diagram sources**
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [quark.ts:1-125](file://frontend/src/api/quark.ts#L1-L125)
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:1-107](file://backend/app/api/v1/auth.py#L1-L107)
- [files.py:1-150](file://backend/app/api/v1/files.py#L1-L150)
- [api_client.py:1-209](file://quark_client/core/api_client.py#L1-L209)
- [client.py:1-405](file://quark_client/client.py#L1-L405)
- [file_service.py:1-893](file://quark_client/services/file_service.py#L1-L893)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)
- [api_login.py:1-521](file://quark_client/auth/api_login.py#L1-L521)

**Section sources**
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [quark.ts:1-125](file://frontend/src/api/quark.ts#L1-L125)
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:1-107](file://backend/app/api/v1/auth.py#L1-L107)
- [files.py:1-150](file://backend/app/api/v1/files.py#L1-L150)
- [api_client.py:1-209](file://quark_client/core/api_client.py#L1-L209)
- [client.py:1-405](file://quark_client/client.py#L1-L405)
- [file_service.py:1-893](file://quark_client/services/file_service.py#L1-L893)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)
- [api_login.py:1-521](file://quark_client/auth/api_login.py#L1-L521)

## Core Components
- Frontend Axios client: Centralized HTTP client with request/response interceptors and baseURL configuration.
- Backend FastAPI routers: Expose REST endpoints for auth and files, delegating to a service layer.
- Quark Python client: Provides a facade (QuarkClient) and service abstractions (FileService, ShareService, etc.) over the Quark API.
- QuarkAPIClient: Low-level HTTP client handling authentication, request building, retries, timeouts, and response parsing.
- Authentication: APILogin manages QR-based login flow and extracts cookies for subsequent API calls.
- Exceptions: Unified exception hierarchy for API, network, authentication, and domain-specific errors.

Key responsibilities:
- Request/response normalization and error propagation
- Authentication token handling via cookies
- Service abstraction for file operations
- Interceptors for request/response transformation
- Configurable timeouts and default headers

**Section sources**
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [quark.ts:1-125](file://frontend/src/api/quark.ts#L1-L125)
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:1-107](file://backend/app/api/v1/auth.py#L1-L107)
- [files.py:1-150](file://backend/app/api/v1/files.py#L1-L150)
- [client.py:18-405](file://quark_client/client.py#L18-L405)
- [api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)
- [api_login.py:20-521](file://quark_client/auth/api_login.py#L20-L521)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)

## Architecture Overview
The frontend communicates with the backend via REST endpoints. The backend validates requests and invokes the Quark service wrapper, which performs the actual calls to the Quark API. The Quark client handles authentication, request construction, and response parsing, raising domain-specific exceptions on failure.

```mermaid
sequenceDiagram
participant FE as "Frontend View<br/>Login.vue"
participant AX as "Axios Client<br/>frontend/src/api/index.ts"
participant API as "FastAPI Router<br/>backend/app/api/v1/router.py"
participant AUTH as "Auth Endpoints<br/>backend/app/api/v1/auth.py"
participant SVC as "Quark Service Wrapper<br/>backend/app/services/quark_service.py"
participant QAC as "QuarkAPIClient<br/>quark_client/core/api_client.py"
FE->>AX : GET /api/v1/auth/qrcode
AX->>API : GET /auth/qrcode
API->>AUTH : GET /auth/qrcode
AUTH->>SVC : get_qrcode()
SVC->>QAC : build and send request
QAC-->>SVC : QR code data
SVC-->>AUTH : QRCodeResponse
AUTH-->>API : QRCodeResponse
API-->>AX : QRCodeResponse
AX-->>FE : QRCodeResponse
FE->>AX : POST /api/v1/auth/check-login
AX->>API : POST /auth/check-login
API->>AUTH : POST /auth/check-login
AUTH->>SVC : check_login_status(token)
SVC->>QAC : check login status
QAC-->>SVC : status result
SVC-->>AUTH : CheckLoginResponse
AUTH-->>API : CheckLoginResponse
API-->>AX : CheckLoginResponse
AX-->>FE : CheckLoginResponse
```

**Diagram sources**
- [Login.vue:84-176](file://frontend/src/views/Login.vue#L84-L176)
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:18-75](file://backend/app/api/v1/auth.py#L18-L75)
- [api_client.py:80-183](file://quark_client/core/api_client.py#L80-L183)

## Detailed Component Analysis

### Frontend Axios Client and API Definitions
- Axios client is configured with baseURL, timeout, and default headers.
- Request interceptor is present but currently a no-op; it can be extended for adding auth tokens or correlation IDs.
- Response interceptor normalizes responses by extracting data, enabling uniform handling in views.
- API definitions encapsulate endpoint contracts and typed request/response shapes for auth and files.

Practical usage in components:
- Login.vue generates QR codes, renders them, and polls for login status using authAPI.
- Files.vue fetches file lists, handles loading states, and triggers actions like delete and download.

```mermaid
sequenceDiagram
participant View as "Files.vue"
participant API as "filesAPI<br/>frontend/src/api/quark.ts"
participant AX as "Axios Client<br/>frontend/src/api/index.ts"
participant BE as "Backend Files Endpoint<br/>backend/app/api/v1/files.py"
View->>API : listFiles(folderId, page, size)
API->>AX : GET /api/v1/files/list?folder_id=...&page=...&size=...
AX->>BE : GET /files/list
BE-->>AX : FileListResponse
AX-->>API : response.data
API-->>View : normalized data
```

**Diagram sources**
- [Files.vue:89-104](file://frontend/src/views/Files.vue#L89-L104)
- [quark.ts:77-124](file://frontend/src/api/quark.ts#L77-L124)
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [files.py:19-35](file://backend/app/api/v1/files.py#L19-L35)

**Section sources**
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [quark.ts:1-125](file://frontend/src/api/quark.ts#L1-L125)
- [Files.vue:89-104](file://frontend/src/views/Files.vue#L89-L104)
- [Login.vue:84-176](file://frontend/src/views/Login.vue#L84-L176)

### Backend Endpoints and Service Delegation
- Router aggregates health checks and sub-routers for auth and files.
- Auth endpoints expose QR generation, login status polling, login, status, and logout.
- Files endpoints expose list, create folder, delete, rename, move, search, storage info, and download URL retrieval.
- Each endpoint validates responses and raises HTTP exceptions on failure, ensuring consistent error propagation.

```mermaid
flowchart TD
Start(["Incoming Request"]) --> Route["Route to Auth/Files Router"]
Route --> AuthCheck{"Auth Endpoint?"}
AuthCheck --> |Yes| AuthHandler["Auth Handler"]
AuthCheck --> |No| FilesHandler["Files Handler"]
AuthHandler --> ServiceCall["Call Quark Service Wrapper"]
FilesHandler --> ServiceCall
ServiceCall --> QuarkAPI["Quark API via QuarkAPIClient"]
QuarkAPI --> Normalize["Normalize Response"]
Normalize --> Return["Return JSON Response"]
```

**Diagram sources**
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:18-95](file://backend/app/api/v1/auth.py#L18-L95)
- [files.py:19-149](file://backend/app/api/v1/files.py#L19-L149)
- [api_client.py:80-183](file://quark_client/core/api_client.py#L80-L183)

**Section sources**
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:18-95](file://backend/app/api/v1/auth.py#L18-L95)
- [files.py:19-149](file://backend/app/api/v1/files.py#L19-L149)

### QuarkAPIClient: HTTP Abstraction and Error Management
- Initializes HTTP client with timeout, default headers, and redirect handling.
- Ensures authentication by obtaining cookies when none are provided.
- Builds standardized request parameters and headers, including a timestamp and fixed delta.
- Implements robust request dispatching for GET/POST with JSON/form data support.
- Handles HTTP status codes, JSON parsing, and API-level status fields, raising appropriate exceptions.
- Provides convenience methods for GET/POST and lifecycle management via context manager.

```mermaid
classDiagram
class QuarkAPIClient {
+cookies
+auto_login
-_client
-_auth
+__init__(cookies, auto_login)
-_init_client()
-_ensure_authenticated()
-_get_timestamp() int
-_build_params(**kwargs) Dict
-_build_headers(extra_headers) Dict
-_make_request(method, url, params, data, json_data, headers, base_url) Dict
+get(url, params, **kwargs) Dict
+post(url, data, json_data, **kwargs) Dict
+close() void
+__enter__() QuarkAPIClient
+__exit__(exc_type, exc_val, exc_tb) void
}
```

**Diagram sources**
- [api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

**Section sources**
- [api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

### QuarkClient and Service Wrappers
- QuarkClient acts as a facade, composing QuarkAPIClient and service instances (files, upload, download, shares, name resolver).
- Services encapsulate domain-specific operations and delegate to QuarkAPIClient.
- FileService demonstrates typical patterns: parameter assembly, API invocation, response normalization, and error translation.

```mermaid
classDiagram
class QuarkClient {
+api_client : QuarkAPIClient
+files : FileService
+upload : FileUploadService
+download : FileDownloadService
+shares : ShareService
+batch_shares : BatchShareService
+name_resolver : NameResolver
+login(force_relogin, use_qr, method) str
+logout() void
+is_logged_in() bool
+list_files(folder_id, **kwargs) Dict
+get_file_info(file_id) Dict
+search_files(keyword, **kwargs) Dict
+get_download_url(file_id) str
+download_file(file_id, save_path, **kwargs) str
+create_folder(name, parent_id) Dict
+delete_files(ids) Dict
+rename_file(id, name) Dict
+move_files(ids, target_id) Dict
+get_storage_info() Dict
+close() void
}
class FileService {
+list_files(folder_id, page, size, sort_field, sort_order) Dict
+get_file_info(file_id) Dict
+create_folder(name, parent_id) Dict
+delete_files(ids) Dict
+rename_file(id, name) Dict
+search_files(keyword, page, size, sort_field, sort_order) Dict
+get_folder_tree(folder_id, max_depth) Dict
+get_storage_info() Dict
+list_files_with_details(...) Dict
+search_files_advanced(...) Dict
+get_file_path(file_id) str
+move_files(ids, target_id, exclude_fids) Dict
+resolve_path(path, current_dir_id) Tuple
+find_files_by_pattern(pattern, dir_id) List
+get_download_urls(ids) Dict
+download_file(path, save_dir, progress_callback) str
+download_folder(path, save_dir, progress_callback) str
}
QuarkClient --> QuarkAPIClient : "uses"
QuarkClient --> FileService : "composes"
```

**Diagram sources**
- [client.py:18-405](file://quark_client/client.py#L18-L405)
- [file_service.py:13-893](file://quark_client/services/file_service.py#L13-L893)
- [api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

**Section sources**
- [client.py:18-405](file://quark_client/client.py#L18-L405)
- [file_service.py:13-893](file://quark_client/services/file_service.py#L13-L893)

### Authentication Token Handling and Login Flow
- APILogin orchestrates QR-based login: obtains QR token and URL, displays QR, polls for login completion, and extracts cookies.
- QuarkAPIClient consumes cookies to authenticate subsequent requests.
- Frontend Login.vue integrates with backend auth endpoints to generate QR codes and poll for login status.

```mermaid
sequenceDiagram
participant FE as "Login.vue"
participant AX as "Axios Client"
participant AUTH as "Auth Endpoints"
participant SVC as "Quark Service"
participant QAC as "QuarkAPIClient"
FE->>AX : GET /auth/qrcode
AX->>AUTH : GET /auth/qrcode
AUTH->>SVC : get_qrcode()
SVC->>QAC : request QR token
QAC-->>SVC : QR token + URL
SVC-->>AUTH : QRCodeResponse
AUTH-->>AX : QRCodeResponse
AX-->>FE : QRCodeResponse
loop Poll until logged in
FE->>AX : POST /auth/check-login
AX->>AUTH : POST /auth/check-login
AUTH->>SVC : check_login_status(token)
SVC->>QAC : check status
QAC-->>SVC : status
SVC-->>AUTH : CheckLoginResponse
AUTH-->>AX : CheckLoginResponse
AX-->>FE : CheckLoginResponse
end
```

**Diagram sources**
- [Login.vue:84-176](file://frontend/src/views/Login.vue#L84-L176)
- [auth.py:18-52](file://backend/app/api/v1/auth.py#L18-L52)
- [api_login.py:467-507](file://quark_client/auth/api_login.py#L467-L507)
- [api_client.py:47-53](file://quark_client/core/api_client.py#L47-L53)

**Section sources**
- [api_login.py:20-521](file://quark_client/auth/api_login.py#L20-L521)
- [api_client.py:47-53](file://quark_client/core/api_client.py#L47-L53)
- [Login.vue:84-176](file://frontend/src/views/Login.vue#L84-L176)
- [auth.py:18-52](file://backend/app/api/v1/auth.py#L18-L52)

### Request/Response Handling and Interceptors
- Frontend response interceptor extracts response.data, simplifying view logic.
- Backend endpoints return strongly typed responses; HTTP exceptions propagate structured errors.
- QuarkAPIClient parses JSON, checks HTTP and API statuses, and raises domain-specific exceptions.

```mermaid
flowchart TD
Req["HTTP Request"] --> AXI["Axios Interceptor"]
AXI --> BE["Backend Endpoint"]
BE --> SVC["Service Wrapper"]
SVC --> QC["QuarkAPIClient"]
QC --> Parse["Parse JSON + Validate Status"]
Parse --> Resp["Normalized Response"]
Resp --> AXO["Axios Response Interceptor"]
AXO --> View["Component"]
```

**Diagram sources**
- [index.ts:11-27](file://frontend/src/api/index.ts#L11-L27)
- [files.py:19-35](file://backend/app/api/v1/files.py#L19-L35)
- [api_client.py:158-177](file://quark_client/core/api_client.py#L158-L177)

**Section sources**
- [index.ts:11-27](file://frontend/src/api/index.ts#L11-L27)
- [files.py:19-35](file://backend/app/api/v1/files.py#L19-L35)
- [api_client.py:158-177](file://quark_client/core/api_client.py#L158-L177)

### Practical Examples: Component Usage, Loading States, and Error Boundaries
- Login.vue:
  - Generates QR code, renders QR canvas, polls for login status, and navigates on success.
  - Uses loading/error states and clears intervals on unmount.
- Files.vue:
  - Fetches file lists with loading indicators, handles navigation, and performs destructive actions with confirmation dialogs.
  - Displays messages for success and error outcomes.

Guidelines:
- Always set loading booleans around async operations.
- Extract and display user-friendly messages from responses or error handlers.
- Clean up timers/intervals in onUnmounted hooks.
- Use confirm dialogs for destructive actions.

**Section sources**
- [Login.vue:84-176](file://frontend/src/views/Login.vue#L84-L176)
- [Files.vue:89-104](file://frontend/src/views/Files.vue#L89-L104)
- [Files.vue:182-200](file://frontend/src/views/Files.vue#L182-L200)

### Relationship Between API Services and Application State
- Frontend components manage local state (loading, path breadcrumbs, file lists).
- API responses update component state; normalized responses simplify state updates.
- Backend endpoints centralize validation and error reporting, keeping components lean.

Data fetching patterns:
- One-shot fetches for lists and single resources.
- Polling for asynchronous operations (login status).
- Pagination parameters passed through to endpoints.

Caching strategies:
- Frontend: Local state caching within components.
- Backend: No explicit caching shown; consider adding in-memory caches for frequent reads (e.g., file metadata) or Redis for distributed caching.

**Section sources**
- [Files.vue:78-104](file://frontend/src/views/Files.vue#L78-L104)
- [Login.vue:142-176](file://frontend/src/views/Login.vue#L142-L176)
- [files.py:19-35](file://backend/app/api/v1/files.py#L19-L35)

### Security Considerations, Rate Limiting, and Offline Fallbacks
Security:
- Cookies are used for authentication; ensure secure transport (HTTPS) and proper cookie policies.
- Avoid logging sensitive tokens or cookies.
- Validate and sanitize inputs on the backend.

Rate limiting:
- Configure backend rate limits per route or globally.
- Frontend should implement exponential backoff and user feedback on throttling.

Offline fallbacks:
- Detect navigator.onLine and show offline messaging.
- Cache recent successful responses for read-heavy operations.
- Allow retry mechanisms with user prompts.

[No sources needed since this section provides general guidance]

## Dependency Analysis
The frontend Axios client depends on API definitions; backend routers depend on auth and files endpoints; endpoints depend on the Quark service wrapper; the service wrapper depends on QuarkAPIClient; QuarkAPIClient depends on configuration and exceptions.

```mermaid
graph LR
FE_QUARK["frontend/src/api/quark.ts"] --> FE_AXIOS["frontend/src/api/index.ts"]
FE_AXIOS --> BE_ROUTER["backend/app/api/v1/router.py"]
BE_ROUTER --> BE_AUTH["backend/app/api/v1/auth.py"]
BE_ROUTER --> BE_FILES["backend/app/api/v1/files.py"]
BE_AUTH --> SVC["backend/app/services/quark_service.py"]
BE_FILES --> SVC
SVC --> QC_CORE["quark_client/core/api_client.py"]
QC_CORE --> QC_CONFIG["quark_client/config.py"]
QC_CORE --> QC_EXC["quark_client/exceptions.py"]
```

**Diagram sources**
- [quark.ts:1-125](file://frontend/src/api/quark.ts#L1-L125)
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:1-107](file://backend/app/api/v1/auth.py#L1-L107)
- [files.py:1-150](file://backend/app/api/v1/files.py#L1-L150)
- [api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)

**Section sources**
- [quark.ts:1-125](file://frontend/src/api/quark.ts#L1-L125)
- [index.ts:1-30](file://frontend/src/api/index.ts#L1-L30)
- [router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [auth.py:1-107](file://backend/app/api/v1/auth.py#L1-L107)
- [files.py:1-150](file://backend/app/api/v1/files.py#L1-L150)
- [api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)
- [config.py:1-63](file://quark_client/config.py#L1-L63)
- [exceptions.py:1-50](file://quark_client/exceptions.py#L1-L50)

## Performance Considerations
- Prefer pagination and filtering to reduce payload sizes.
- Use streaming downloads for large files to avoid memory pressure.
- Implement request deduplication for concurrent identical requests.
- Cache frequently accessed data (e.g., file metadata) in the frontend.
- Tune timeouts and retry delays based on network conditions.

[No sources needed since this section provides general guidance]

## Troubleshooting Guide
Common issues and resolutions:
- Authentication failures: Verify cookies are present and not expired; re-run QR login flow.
- Network timeouts: Increase timeout values and implement retry with backoff.
- JSON parsing errors: Validate response shape and handle non-JSON responses gracefully.
- HTTP errors: Inspect status codes and error messages returned by endpoints.
- Frontend loading states: Ensure loading flags are toggled in try/catch/finally blocks.

Relevant exception types:
- AuthenticationError: Raised when credentials are invalid or missing.
- APIError: Raised for API-level errors with optional status code and response data.
- NetworkError: Raised for network-related failures.
- FileNotFoundError: Raised when requested resources are not found.

**Section sources**
- [exceptions.py:13-50](file://quark_client/exceptions.py#L13-L50)
- [api_client.py:146-183](file://quark_client/core/api_client.py#L146-L183)
- [Files.vue:89-104](file://frontend/src/views/Files.vue#L89-L104)

## Conclusion
The API integration layer cleanly separates concerns across frontend, backend, and Quark client components. It provides robust authentication, standardized request/response handling, and service abstractions for file operations. By following the outlined patterns for loading states, error handling, security, and extension, teams can reliably evolve the API layer and integrate new backend endpoints.

## Appendices

### Guidelines for Extending the API Layer
- Define new endpoints in backend routers and handlers.
- Add API definitions in frontend quark.ts with typed request/response interfaces.
- Implement service wrappers in the Quark client if needed.
- Add request/response interceptors as required.
- Update components to consume new endpoints and manage loading/error states.

[No sources needed since this section provides general guidance]