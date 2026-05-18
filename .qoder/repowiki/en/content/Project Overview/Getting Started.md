# Getting Started

<cite>
**Referenced Files in This Document**
- [docker-compose.yml](file://docker-compose.yml)
- [backend/Dockerfile](file://backend/Dockerfile)
- [frontend/Dockerfile](file://frontend/Dockerfile)
- [backend/pyproject.toml](file://backend/pyproject.toml)
- [frontend/package.json](file://frontend/package.json)
- [backend/app/main.py](file://backend/app/main.py)
- [backend/app/core/config.py](file://backend/app/core/config.py)
- [backend/app/api/v1/auth.py](file://backend/app/api/v1/auth.py)
- [backend/app/api/v1/files.py](file://backend/app/api/v1/files.py)
- [backend/app/services/quark_service.py](file://backend/app/services/quark_service.py)
- [frontend/src/views/Login.vue](file://frontend/src/views/Login.vue)
- [frontend/src/views/Files.vue](file://frontend/src/views/Files.vue)
- [frontend/src/api/quark.ts](file://frontend/src/api/quark.ts)
- [quark_client/client.py](file://quark_client/client.py)
- [PROJECT_SUMMARY.md](file://PROJECT_SUMMARY.md)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Basic Authentication Walkthrough](#basic-authentication-walkthrough)
5. [Essential File Operations](#essential-file-operations)
6. [Docker Deployment Details](#docker-deployment-details)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Next Steps](#next-steps)

## Introduction
This guide helps you set up QuarkManager quickly using Docker Compose, access the web interface, verify backend connectivity, log in via QR code or Cookie, and perform basic file operations. It also covers common setup issues and provides troubleshooting steps for Docker permissions and service startup failures.

## Prerequisites
Ensure the following tools are installed and available on your system:
- Python 3.9+ (required by the backend project metadata)
- Node.js 20.x (required by the frontend Dockerfile)
- Docker and Docker Compose (containerization runtime)
- Git (to clone or manage the repository)

Notes:
- The backend Dockerfile uses Python 3.11 slim image.
- The frontend Dockerfile uses Node.js 20 Alpine image.
- The backend project metadata requires Python >= 3.9, but the runtime image is 3.11.

**Section sources**
- [backend/pyproject.toml:12](file://backend/pyproject.toml#L12)
- [backend/Dockerfile:1](file://backend/Dockerfile#L1)
- [frontend/Dockerfile:1](file://frontend/Dockerfile#L1)

## Quick Start
Follow these steps to deploy and run QuarkManager locally using Docker Compose:

1. Start all services in detached mode:
   - Backend runs on port 8000 inside containers; mapped to 8000 on host.
   - Frontend runs on port 3000 inside containers; mapped to 3000 on host.
   - Redis runs on port 6379 inside containers; mapped to 6379 on host.
   - Celery worker is configured to connect to Redis and uses the same backend image.

2. Access the applications:
   - Web interface: http://localhost:3000
   - Backend API docs: http://localhost:8000/docs

3. Verify backend connectivity:
   - Health endpoint: http://localhost:8000/health

4. Environment variables:
   - DATABASE_URL defaults to an SQLite file under a persistent volume.
   - REDIS_URL points to the Redis service in the compose network.
   - Backend CORS allows requests from the frontend origin.

5. Service startup order:
   - Redis starts first and is used by backend and Celery worker.
   - Backend depends on Redis.
   - Frontend depends on backend for API proxying during development.

**Section sources**
- [docker-compose.yml:3–65:3-65](file://docker-compose.yml#L3-L65)
- [backend/app/main.py:31–41:31-41](file://backend/app/main.py#L31-L41)
- [backend/app/core/config.py:10–25:10-25](file://backend/app/core/config.py#L10-L25)

## Basic Authentication Walkthrough
QuarkManager supports two login methods: QR code and Cookie.

- QR Code Login (recommended):
  - The frontend automatically requests a QR code from the backend.
  - The frontend renders the QR code and polls the backend to check login status.
  - After successful login, the frontend navigates to the file browser.

- Cookie Login:
  - Enter your Cookie string in the Cookie tab.
  - Submit to log in directly.

Key endpoints:
- GET /api/v1/auth/qrcode: Request a QR code and token.
- POST /api/v1/auth/check-login: Poll for login completion.
- POST /api/v1/auth/login: Perform login (supports method and cookies).
- GET /api/v1/auth/status: Check current login status.
- POST /api/v1/auth/logout: Log out.

Frontend behavior:
- On mount, the login page generates a QR code and starts polling.
- On success, navigates to the file browser.
- Cookie login submits the provided Cookie string to the backend.

**Section sources**
- [frontend/src/views/Login.vue:84–184:84-184](file://frontend/src/views/Login.vue#L84-L184)
- [backend/app/api/v1/auth.py:18–107:18-107](file://backend/app/api/v1/auth.py#L18-L107)
- [frontend/src/api/quark.ts:55–75:55-75](file://frontend/src/api/quark.ts#L55-L75)

## Essential File Operations
After logging in, you can browse and manage files:

- Browse directories:
  - Load the file list for the current folder.
  - Navigate into subfolders by clicking rows.
  - Use breadcrumbs to move up.

- Upload files:
  - The upload button is present in the header.
  - Current implementation indicates upload is under development.

- Create folders:
  - Use the “New Folder” button and confirm the prompt.

- Delete files:
  - Select a file and click the delete action.
  - Confirm the deletion dialog.

- Download files:
  - Click the download action for a file to open the download URL.

- Search files:
  - Use the search endpoint with keyword, page, and size parameters.

- Storage info:
  - Retrieve total and used storage capacity.

Backend endpoints:
- GET /api/v1/files/list: List files in a folder.
- POST /api/v1/files/folder: Create a folder.
- DELETE /api/v1/files/delete: Delete files.
- PUT /api/v1/files/rename: Rename a file.
- POST /api/v1/files/move: Move files.
- GET /api/v1/files/search: Search files.
- GET /api/v1/files/storage: Get storage info.
- GET /api/v1/files/download/{file_id}: Get download URL.

Frontend behavior:
- File list loads on mount and refreshes on demand.
- Navigation updates the current folder and path breadcrumb.
- Actions trigger API calls and update the UI accordingly.

**Section sources**
- [frontend/src/views/Files.vue:89–214:89-214](file://frontend/src/views/Files.vue#L89-L214)
- [backend/app/api/v1/files.py:19–150:19-150](file://backend/app/api/v1/files.py#L19-L150)
- [frontend/src/api/quark.ts:77–124:77-124](file://frontend/src/api/quark.ts#L77-L124)

## Docker Deployment Details
Compose services and ports:
- backend: exposes 8000; mounts backend code and data volume; depends on redis; environment variables include DATABASE_URL and REDIS_URL.
- frontend: exposes 3000; mounts frontend code; depends on backend.
- redis: exposes 6379; persists data in a named volume.
- celery-worker: runs Celery worker using the backend image; shares environment variables and volumes.

Network:
- All services are on a shared bridge network named quarkmanager.

Volumes:
- redis_data persists Redis data.

CORS:
- Backend allows origins http://localhost:3000 and http://127.0.0.1:3000.

**Section sources**
- [docker-compose.yml:3–65:3-65](file://docker-compose.yml#L3-L65)
- [backend/app/core/config.py:22–25:22-25](file://backend/app/core/config.py#L22-L25)

## Troubleshooting Guide
Common setup issues and resolutions:

- Port conflicts:
  - If ports 3000, 8000, or 6379 are in use, change the host mappings in docker-compose.yml or stop conflicting services.

- Network connectivity:
  - Ensure the frontend can reach the backend at http://localhost:8000 during development.
  - Verify CORS settings allow the frontend origin.

- Dependency resolution:
  - Backend Python dependencies are installed from requirements.txt inside the backend image.
  - Frontend Node dependencies are installed from package.json inside the frontend image.

- Docker permission issues:
  - Run Docker commands with appropriate user permissions.
  - On Linux, ensure your user is part of the docker group.

- Service startup failures:
  - Check logs for backend and frontend services after starting with Docker Compose.
  - Confirm Redis is reachable before backend starts.
  - Validate environment variables (DATABASE_URL, REDIS_URL) match the compose network.

- API documentation:
  - Visit http://localhost:8000/docs to verify the backend is running and serving the OpenAPI docs.

**Section sources**
- [docker-compose.yml:8–18:8-18](file://docker-compose.yml#L8-L18)
- [docker-compose.yml:25–32:25-32](file://docker-compose.yml#L25-L32)
- [docker-compose.yml:36–41:36-41](file://docker-compose.yml#L36-L41)
- [backend/app/main.py:31–41:31-41](file://backend/app/main.py#L31-L41)

## Next Steps
- Integrate the real QuarkClient library for production functionality.
- Complete frontend integration with real APIs for uploads, downloads, and advanced features.
- Enable database integration for user and session persistence.
- Configure environment-specific settings and secrets management.
- Add CI/CD pipelines and monitoring.

**Section sources**
- [PROJECT_SUMMARY.md:75–99:75-99](file://PROJECT_SUMMARY.md#L75-L99)