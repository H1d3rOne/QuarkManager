# Backend Architecture

<cite>
**Referenced Files in This Document**
- [backend/app/main.py](file://backend/app/main.py)
- [backend/app/api/v1/router.py](file://backend/app/api/v1/router.py)
- [backend/app/api/v1/auth.py](file://backend/app/api/v1/auth.py)
- [backend/app/api/v1/files.py](file://backend/app/api/v1/files.py)
- [backend/app/core/config.py](file://backend/app/core/config.py)
- [backend/app/core/database.py](file://backend/app/core/database.py)
- [backend/app/schemas/auth.py](file://backend/app/schemas/auth.py)
- [backend/app/schemas/files.py](file://backend/app/schemas/files.py)
- [backend/app/services/quark_service.py](file://backend/app/services/quark_service.py)
- [backend/pyproject.toml](file://backend/pyproject.toml)
- [backend/Dockerfile](file://backend/Dockerfile)
- [docker-compose.yml](file://docker-compose.yml)
- [quark_client/client.py](file://quark_client/client.py)
- [quark_client/core/api_client.py](file://quark_client/core/api_client.py)
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
This document describes the backend architecture of a FastAPI-based server that integrates with the Quark Pan API via a dedicated Python client library. The system follows a layered architecture with clear separation between presentation (FastAPI routers), business logic (service layer), and data access (SQLAlchemy). It also documents asynchronous programming patterns, dependency injection, middleware configuration, error handling strategies, infrastructure requirements, scalability considerations, and deployment topology. Cross-cutting concerns such as authentication, logging, monitoring, and security are addressed alongside the technology stack and version compatibility.

## Project Structure
The backend is organized into distinct layers:
- Presentation layer: FastAPI application and API routers under app/api/v1
- Business logic layer: Service layer under app/services
- Data access layer: SQLAlchemy engine/session factory under app/core/database.py
- Configuration: Environment-driven settings under app/core/config.py
- Schemas: Pydantic models for request/response validation under app/schemas
- Client integration: QuarkClient and QuarkAPIClient under quark_client

```mermaid
graph TB
subgraph "Backend Application"
M["FastAPI App<br/>backend/app/main.py"]
R["API Routers<br/>backend/app/api/v1/router.py"]
AAuth["Auth Router<br/>backend/app/api/v1/auth.py"]
AFiles["Files Router<br/>backend/app/api/v1/files.py"]
Cfg["Settings & Config<br/>backend/app/core/config.py"]
DB["Database Engine & Session<br/>backend/app/core/database.py"]
Svc["Quark Service<br/>backend/app/services/quark_service.py"]
SchAuth["Auth Schemas<br/>backend/app/schemas/auth.py"]
SchFiles["Files Schemas<br/>backend/app/schemas/files.py"]
end
subgraph "External Integration"
QCli["QuarkClient<br/>quark_client/client.py"]
QApi["QuarkAPIClient<br/>quark_client/core/api_client.py"]
end
M --> R
R --> AAuth
R --> AFiles
AAuth --> Svc
AFiles --> Svc
Svc --> QCli
QCli --> QApi
M --> Cfg
M --> DB
AAuth --> SchAuth
AFiles --> SchFiles
```

**Diagram sources**
- [backend/app/main.py:12-28](file://backend/app/main.py#L12-L28)
- [backend/app/api/v1/router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [backend/app/api/v1/auth.py:15-107](file://backend/app/api/v1/auth.py#L15-L107)
- [backend/app/api/v1/files.py:16-150](file://backend/app/api/v1/files.py#L16-L150)
- [backend/app/core/config.py:5-35](file://backend/app/core/config.py#L5-L35)
- [backend/app/core/database.py:10-29](file://backend/app/core/database.py#L10-L29)
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [backend/app/schemas/auth.py:5-50](file://backend/app/schemas/auth.py#L5-L50)
- [backend/app/schemas/files.py:5-54](file://backend/app/schemas/files.py#L5-L54)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

**Section sources**
- [backend/app/main.py:12-28](file://backend/app/main.py#L12-L28)
- [backend/app/api/v1/router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [backend/app/core/config.py:5-35](file://backend/app/core/config.py#L5-L35)
- [backend/app/core/database.py:10-29](file://backend/app/core/database.py#L10-L29)
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

## Core Components
- FastAPI application: Initializes middleware, registers routers, and exposes health checks.
- API routers: Modularized under v1 with separate routers for authentication and files.
- Service layer: Encapsulates business logic and integrates with QuarkClient.
- Configuration: Centralized settings via pydantic-settings with environment file support.
- Data access: SQLAlchemy engine and session factory for persistence.
- Schemas: Pydantic models for request/response validation and serialization.
- Client integration: QuarkClient and QuarkAPIClient handle authentication, HTTP requests, and API interactions.

Key implementation patterns:
- Asynchronous programming: All route handlers are async-compatible with FastAPI.
- Dependency injection: Settings and database sessions are provided via dependency functions.
- Error handling: Route handlers raise HTTPException on failures; service layer returns structured result dictionaries.
- Middleware: CORS configured centrally for cross-origin requests.

**Section sources**
- [backend/app/main.py:12-40](file://backend/app/main.py#L12-L40)
- [backend/app/api/v1/router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [backend/app/api/v1/auth.py:15-107](file://backend/app/api/v1/auth.py#L15-L107)
- [backend/app/api/v1/files.py:16-150](file://backend/app/api/v1/files.py#L16-L150)
- [backend/app/core/config.py:5-35](file://backend/app/core/config.py#L5-L35)
- [backend/app/core/database.py:22-29](file://backend/app/core/database.py#L22-L29)
- [backend/app/schemas/auth.py:5-50](file://backend/app/schemas/auth.py#L5-L50)
- [backend/app/schemas/files.py:5-54](file://backend/app/schemas/files.py#L5-L54)
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)

## Architecture Overview
The system follows a layered architecture:
- Presentation: FastAPI app and routers expose REST endpoints.
- Business logic: Service layer orchestrates operations and interacts with the QuarkClient.
- Data access: SQLAlchemy manages persistence (configured but not actively used in code).
- External integration: QuarkClient encapsulates Quark Pan API interactions via QuarkAPIClient.

```mermaid
graph TB
Client["Client Browser/App"]
FA["FastAPI App<br/>main.py"]
AR["API Router v1<br/>router.py"]
AuthR["Auth Router<br/>auth.py"]
FilesR["Files Router<br/>files.py"]
Svc["QuarkService<br/>quark_service.py"]
QC["QuarkClient<br/>client.py"]
QAC["QuarkAPIClient<br/>api_client.py"]
Client --> FA
FA --> AR
AR --> AuthR
AR --> FilesR
AuthR --> Svc
FilesR --> Svc
Svc --> QC
QC --> QAC
```

**Diagram sources**
- [backend/app/main.py:12-28](file://backend/app/main.py#L12-L28)
- [backend/app/api/v1/router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)
- [backend/app/api/v1/auth.py:15-107](file://backend/app/api/v1/auth.py#L15-L107)
- [backend/app/api/v1/files.py:16-150](file://backend/app/api/v1/files.py#L16-L150)
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

## Detailed Component Analysis

### FastAPI Application and Middleware
- Initializes FastAPI with metadata and registers CORS middleware using settings.
- Includes v1 API router under /api/v1 and exposes root and health endpoints.
- Uses Uvicorn for development runtime.

```mermaid
sequenceDiagram
participant Client as "Client"
participant App as "FastAPI App"
participant Router as "API Router v1"
participant Auth as "Auth Router"
participant Files as "Files Router"
Client->>App : "GET /"
App-->>Client : "Welcome message"
Client->>App : "GET /health"
App-->>Client : "{status : healthy}"
Client->>App : "GET /api/v1/test"
App->>Router : "include_router"
Router-->>Client : "API is working"
Client->>App : "GET /api/v1/health"
App->>Router : "include_router"
Router-->>Client : "{status : ok, service : api}"
```

**Diagram sources**
- [backend/app/main.py:12-40](file://backend/app/main.py#L12-L40)
- [backend/app/api/v1/router.py:9-18](file://backend/app/api/v1/router.py#L9-L18)

**Section sources**
- [backend/app/main.py:12-40](file://backend/app/main.py#L12-L40)
- [backend/app/api/v1/router.py:1-24](file://backend/app/api/v1/router.py#L1-L24)

### Authentication Router and Service Integration
- Provides endpoints for QR code generation, login status polling, explicit login, status check, and logout.
- Delegates to QuarkService for all operations, returning structured results and raising HTTPException on failure.

```mermaid
sequenceDiagram
participant FE as "Frontend"
participant Auth as "Auth Router"
participant Svc as "QuarkService"
participant QC as "QuarkClient"
participant QAC as "QuarkAPIClient"
FE->>Auth : "GET /auth/qrcode"
Auth->>Svc : "get_qrcode()"
Svc->>QC : "create_client(...) (when available)"
QC->>QAC : "APILogin.get_qr_code()"
QAC-->>QC : "qr_token, qr_url"
QC-->>Svc : "result"
Svc-->>Auth : "QRCodeResponse"
Auth-->>FE : "QRCodeResponse"
FE->>Auth : "POST /auth/check-login"
Auth->>Svc : "check_login_status(token)"
Svc->>QAC : "APILogin.check_login_status(token)"
QAC-->>Svc : "status result"
Svc-->>Auth : "CheckLoginResponse"
Auth-->>FE : "CheckLoginResponse"
```

**Diagram sources**
- [backend/app/api/v1/auth.py:18-52](file://backend/app/api/v1/auth.py#L18-L52)
- [backend/app/services/quark_service.py:46-136](file://backend/app/services/quark_service.py#L46-L136)
- [quark_client/client.py:402-405](file://quark_client/client.py#L402-L405)
- [quark_client/core/api_client.py:18-209](file://quark_client/core/api_client.py#L18-L209)

**Section sources**
- [backend/app/api/v1/auth.py:15-107](file://backend/app/api/v1/auth.py#L15-L107)
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

### Files Router and Service Integration
- Provides endpoints for listing files, creating folders, deleting files, renaming files, moving files, searching, retrieving storage info, and obtaining download URLs.
- Delegates to QuarkService and raises HTTPException on failure.

```mermaid
sequenceDiagram
participant FE as "Frontend"
participant Files as "Files Router"
participant Svc as "QuarkService"
participant QC as "QuarkClient"
FE->>Files : "GET /files/list?folder_id=...&page=...&size=..."
Files->>Svc : "list_files(folder_id, page, size)"
Svc->>QC : "list_files(...)"
QC-->>Svc : "result"
Svc-->>Files : "FileListResponse"
Files-->>FE : "FileListResponse"
FE->>Files : "GET /files/storage"
Files->>Svc : "get_storage_info()"
Svc->>QC : "get_storage_info()"
QC-->>Svc : "result"
Svc-->>Files : "StorageInfoResponse"
Files-->>FE : "StorageInfoResponse"
```

**Diagram sources**
- [backend/app/api/v1/files.py:19-138](file://backend/app/api/v1/files.py#L19-L138)
- [backend/app/services/quark_service.py:202-335](file://backend/app/services/quark_service.py#L202-L335)
- [quark_client/client.py:261-273](file://quark_client/client.py#L261-L273)

**Section sources**
- [backend/app/api/v1/files.py:16-150](file://backend/app/api/v1/files.py#L16-L150)
- [backend/app/services/quark_service.py:202-335](file://backend/app/services/quark_service.py#L202-L335)
- [quark_client/client.py:261-273](file://quark_client/client.py#L261-L273)

### QuarkService Singleton and Client Integration
- Implements a thread-safe singleton pattern to manage a single QuarkClient instance.
- Provides methods for QR code retrieval, login status checking, explicit login, logout, file operations, storage info, and download URL retrieval.
- Integrates with QuarkClient and QuarkAPIClient for all Quark Pan API interactions.

```mermaid
classDiagram
class QuarkService {
-_instance : QuarkService?
-_client : Any?
-_is_logged_in : bool
-_api_login : Any?
-_current_qr_token : str?
+get_client() Any?
+init_client(cookies, auto_login) Any
+get_qrcode() dict
+check_login_status(qr_token) dict
+login(method, cookies) dict
+is_logged_in() bool
+logout() dict
+list_files(folder_id, page, size) dict
+create_folder(name, parent_id) dict
+delete_files(ids) dict
+rename_file(id, name) dict
+move_files(ids, target) dict
+search_files(keyword, page, size) dict
+get_storage_info() dict
+get_download_url(file_id) dict
}
class QuarkClient {
+login(force_relogin, use_qr, method) str
+logout() void
+is_logged_in() bool
+list_files(folder_id, kwargs) dict
+create_folder(name, parent_id) dict
+delete_files(ids) dict
+rename_file(id, name) dict
+move_files(ids, target) dict
+search_files(keyword, kwargs) dict
+get_download_url(file_id) str
+get_storage_info() dict
}
class QuarkAPIClient {
+get(url, params, kwargs) dict
+post(url, data, json_data, kwargs) dict
+close() void
}
QuarkService --> QuarkClient : "manages"
QuarkClient --> QuarkAPIClient : "uses"
```

**Diagram sources**
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

**Section sources**
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)

### Configuration and Database Layer
- Settings loaded via pydantic-settings with environment file support.
- Database engine and session factory configured; dependency function provided for DI.
- Redis URL configured for potential background task integration.

```mermaid
flowchart TD
Start(["Load Settings"]) --> Env["Read .env via pydantic-settings"]
Env --> DBUrl["Resolve DATABASE_URL"]
Env --> RedisUrl["Resolve REDIS_URL"]
DBUrl --> Engine["Create SQLAlchemy Engine"]
RedisUrl --> Ready["Ready for Services"]
Engine --> Ready
```

**Diagram sources**
- [backend/app/core/config.py:5-35](file://backend/app/core/config.py#L5-L35)
- [backend/app/core/database.py:10-29](file://backend/app/core/database.py#L10-L29)

**Section sources**
- [backend/app/core/config.py:5-35](file://backend/app/core/config.py#L5-L35)
- [backend/app/core/database.py:10-29](file://backend/app/core/database.py#L10-L29)

## Dependency Analysis
- FastAPI application depends on configuration and registers v1 routers.
- Routers depend on schemas for request/response validation and on the service layer.
- Service layer depends on QuarkClient and QuarkAPIClient for external API interactions.
- Database layer provides dependency functions for session management.

```mermaid
graph LR
Main["main.py"] --> Cfg["config.py"]
Main --> V1["api/v1/router.py"]
V1 --> Auth["api/v1/auth.py"]
V1 --> Files["api/v1/files.py"]
Auth --> Svc["services/quark_service.py"]
Files --> Svc
Svc --> QCli["quark_client/client.py"]
QCli --> QApi["quark_client/core/api_client.py"]
Main --> DB["core/database.py"]
```

**Diagram sources**
- [backend/app/main.py:4-28](file://backend/app/main.py#L4-L28)
- [backend/app/api/v1/router.py:3-23](file://backend/app/api/v1/router.py#L3-L23)
- [backend/app/api/v1/auth.py:4-13](file://backend/app/api/v1/auth.py#L4-L13)
- [backend/app/api/v1/files.py:4-14](file://backend/app/api/v1/files.py#L4-L14)
- [backend/app/services/quark_service.py:10-19](file://backend/app/services/quark_service.py#L10-L19)
- [quark_client/client.py:8-16](file://quark_client/client.py#L8-L16)
- [quark_client/core/api_client.py:8-13](file://quark_client/core/api_client.py#L8-L13)
- [backend/app/core/database.py:5-6](file://backend/app/core/database.py#L5-L6)

**Section sources**
- [backend/app/main.py:4-28](file://backend/app/main.py#L4-L28)
- [backend/app/api/v1/router.py:3-23](file://backend/app/api/v1/router.py#L3-L23)
- [backend/app/api/v1/auth.py:4-13](file://backend/app/api/v1/auth.py#L4-L13)
- [backend/app/api/v1/files.py:4-14](file://backend/app/api/v1/files.py#L4-L14)
- [backend/app/services/quark_service.py:10-19](file://backend/app/services/quark_service.py#L10-L19)
- [quark_client/client.py:8-16](file://quark_client/client.py#L8-L16)
- [quark_client/core/api_client.py:8-13](file://quark_client/core/api_client.py#L8-L13)
- [backend/app/core/database.py:5-6](file://backend/app/core/database.py#L5-L6)

## Performance Considerations
- Asynchronous design: Route handlers are async-compatible; consider using async-aware clients for I/O-bound operations to improve concurrency.
- Database usage: SQLAlchemy engine/session factory is present; ensure proper connection pooling and avoid long transactions.
- External API latency: Quark Pan API calls introduce network latency; implement caching for frequently accessed metadata and consider pagination limits.
- Background tasks: Redis and Celery are available; offload long-running operations (e.g., batch downloads, conversions) to workers.
- Resource limits: Configure container resource limits and readiness/liveness probes in production deployments.

## Troubleshooting Guide
Common issues and resolutions:
- Authentication failures: Verify cookie validity and re-login if necessary; check QuarkAPIClient error handling for 401/403 responses.
- CORS errors: Ensure backend_cors_origins matches frontend origin; confirm middleware registration order.
- Health checks: Use / and /health endpoints to validate service availability; use /api/v1/health for API-specific checks.
- Database connectivity: Confirm DATABASE_URL and connection arguments; ensure SQLite file path exists or switch to PostgreSQL in production.
- Redis connectivity: Validate REDIS_URL and ensure Redis service is reachable from the backend container.

**Section sources**
- [backend/app/main.py:31-40](file://backend/app/main.py#L31-L40)
- [backend/app/api/v1/router.py:9-18](file://backend/app/api/v1/router.py#L9-L18)
- [backend/app/core/config.py:22-25](file://backend/app/core/config.py#L22-L25)
- [quark_client/core/api_client.py:146-156](file://quark_client/core/api_client.py#L146-L156)

## Conclusion
The backend employs a clean, layered architecture with FastAPI as the presentation layer, a robust service layer for business logic, and a clear integration boundary with the QuarkClient/QuarkAPIClient for external API interactions. Asynchronous patterns, dependency injection, and centralized configuration enable maintainability and scalability. The provided Docker and docker-compose configurations facilitate local development and deployment, while Redis/Celery offer pathways for background task processing. Cross-cutting concerns such as CORS, error handling, and configuration are consistently implemented across the stack.

## Appendices

### Technology Stack and Version Compatibility
- FastAPI: >= 0.109.0
- Uvicorn: >= 0.27.0
- SQLAlchemy: >= 2.0.0
- Alembic: >= 1.13.0
- Pydantic: >= 2.5.0
- Pydantic Settings: >= 2.1.0
- Celery: >= 5.3.0
- Redis: >= 5.0.0
- httpx: >= 0.26.0
- Python: >= 3.9

**Section sources**
- [backend/pyproject.toml:13-27](file://backend/pyproject.toml#L13-L27)

### Infrastructure Requirements and Deployment Topology
- Backend service: Exposed on port 8000; mounts ./data for persistent storage.
- Frontend service: Exposed on port 3000; depends on backend.
- Redis service: Exposed on port 6379; used for Celery and caching.
- Celery worker: Runs as a separate service using the same backend image.
- Networking: All services on a shared bridge network named quarkmanager.

```mermaid
graph TB
subgraph "Network: quarkmanager"
B["backend:8000"]
F["frontend:3000"]
R["redis:6379"]
CW["celery-worker"]
end
F --> |"HTTP"| B
B --> |"Redis"| R
CW --> |"Redis"| R
```

**Diagram sources**
- [docker-compose.yml:34-57](file://docker-compose.yml#L34-L57)

**Section sources**
- [docker-compose.yml:1-65](file://docker-compose.yml#L1-L65)
- [backend/Dockerfile:1-15](file://backend/Dockerfile#L1-L15)

### System Context Diagram
High-level view of backend, frontend, and external Quark Pan API integration.

```mermaid
graph TB
FE["Frontend (Browser/App)"]
BE["Backend (FastAPI)"]
QC["QuarkClient"]
QAPI["QuarkAPIClient"]
QP["Quark Pan API"]
FE --> |"HTTP Requests"| BE
BE --> |"Business Logic"| QC
QC --> |"HTTP Calls"| QAPI
QAPI --> |"REST API"| QP
```

**Diagram sources**
- [backend/app/main.py:12-28](file://backend/app/main.py#L12-L28)
- [backend/app/api/v1/auth.py:15-107](file://backend/app/api/v1/auth.py#L15-L107)
- [backend/app/api/v1/files.py:16-150](file://backend/app/api/v1/files.py#L16-L150)
- [backend/app/services/quark_service.py:22-361](file://backend/app/services/quark_service.py#L22-L361)
- [quark_client/client.py:18-405](file://quark_client/client.py#L18-L405)
- [quark_client/core/api_client.py:16-209](file://quark_client/core/api_client.py#L16-L209)