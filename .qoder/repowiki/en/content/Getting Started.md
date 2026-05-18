# Getting Started

<cite>
**Referenced Files in This Document**
- [docker-compose.yml](file://docker-compose.yml)
- [backend/Dockerfile](file://backend/Dockerfile)
- [frontend/Dockerfile](file://frontend/Dockerfile)
- [backend/pyproject.toml](file://backend/pyproject.toml)
- [backend/requirements.txt](file://backend/requirements.txt)
- [frontend/package.json](file://frontend/package.json)
- [backend/app/main.py](file://backend/app/main.py)
- [backend/app/core/config.py](file://backend/app/core/config.py)
- [frontend/vite.config.ts](file://frontend/vite.config.ts)
- [PROJECT_SUMMARY.md](file://PROJECT_SUMMARY.md)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Quick Setup Options](#quick-setup-options)
4. [Production Setup with Docker Compose](#production-setup-with-docker-compose)
5. [Development Setup Without Docker](#development-setup-without-docker)
6. [Environment Configuration](#environment-configuration)
7. [Running the Application Locally](#running-the-application-locally)
8. [Accessing the Services](#accessing-the-services)
9. [Initial Project Setup](#initial-project-setup)
10. [Verification Steps](#verification-steps)
11. [Common Setup Issues and Solutions](#common-setup-issues-and-solutions)
12. [Troubleshooting Guide](#troubleshooting-guide)
13. [Conclusion](#conclusion)

## Introduction
This guide helps you quickly set up and begin using QuarkManager. It covers prerequisites, production deployment via Docker Compose, development installation, environment configuration, and initial usage. You will learn how to run the backend API, frontend UI, and supporting services, along with verification steps and common troubleshooting tips.

## Prerequisites
Ensure your machine meets the following requirements before proceeding:
- Python 3.9+ (required by backend project metadata)
- Node.js 20.x (recommended for frontend builds)
- Docker and Docker Compose installed and running

Notes:
- The backend project metadata requires Python 3.9 or newer.
- The frontend Dockerfile uses Node.js 20 Alpine as base image.
- Docker Compose is used to orchestrate backend, frontend, Redis, and Celery worker services.

**Section sources**
- [backend/pyproject.toml:12](file://backend/pyproject.toml#L12)
- [frontend/Dockerfile:1](file://frontend/Dockerfile#L1)
- [docker-compose.yml:1](file://docker-compose.yml#L1)

## Quick Setup Options
Choose one of the following approaches depending on your environment and goals:
- Production-like setup using Docker Compose (recommended for most users)
- Local development without Docker (best for contributors and iterative development)

Both options are documented below with step-by-step instructions.

## Production Setup with Docker Compose
Use Docker Compose to run all services in containers with persistent storage and inter-service networking.

Steps:
1. Build and start services
   - Run: docker compose up --build
   - This builds images from backend and frontend Dockerfiles, starts Redis, Celery worker, backend, and frontend, and exposes ports as defined.

2. Verify service status
   - Confirm all containers are healthy and running in your container runtime.

3. Access the services
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000 (internal mapping; exposed on host 8000)
   - Redis: http://localhost:6379
   - Celery worker logs: inspect the celery-worker container logs

Key points:
- Ports published by Compose:
  - Frontend: 3000 -> 3000
  - Backend: 8000 -> 8000
  - Redis: 6379 -> 6379
- Persistent volumes:
  - Backend data directory mapped under ./data
  - Redis data volume named redis_data

**Section sources**
- [docker-compose.yml:3](file://docker-compose.yml#L3)
- [docker-compose.yml:8](file://docker-compose.yml#L8)
- [docker-compose.yml:25](file://docker-compose.yml#L25)
- [docker-compose.yml:36](file://docker-compose.yml#L36)
- [docker-compose.yml:59](file://docker-compose.yml#L59)

## Development Setup Without Docker
Run backend and frontend locally for rapid iteration during development.

Backend (Python/FastAPI):
1. Install dependencies
   - Navigate to backend and install dependencies using requirements.txt
   - Example: pip install -r requirements.txt

2. Start the backend server
   - Run the Uvicorn ASGI server on port 8000
   - Example: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

3. Verify backend health
   - Endpoint: GET /health
   - Expected response indicates service health

Frontend (Node.js/Vue):
1. Install dependencies
   - Navigate to frontend and install dependencies using package.json
   - Example: npm install

2. Start the development server
   - Run the Vite dev server on port 3000
   - Example: npm run dev

3. Configure proxy (if needed)
   - Vite proxy targets backend on port 8000
   - No extra action required if using default configuration

**Section sources**
- [backend/requirements.txt:1](file://backend/requirements.txt#L1)
- [backend/app/main.py:43](file://backend/app/main.py#L43)
- [frontend/package.json:5](file://frontend/package.json#L5)
- [frontend/vite.config.ts:12](file://frontend/vite.config.ts#L12)
- [frontend/vite.config.ts:14](file://frontend/vite.config.ts#L14)

## Environment Configuration
Configure application settings and secrets for local runs.

Backend configuration:
- Settings class defines defaults for app name, debug mode, database URL, Redis URL, JWT secret, expiration, and CORS origins.
- Environment file support is enabled via env_file=".env".
- CORS allows frontend origin localhost:3000 by default.

Frontend configuration:
- Vite dev server runs on port 3000.
- Proxy configuration forwards API requests to backend on port 8000.

Notes:
- For production, replace default secret keys and adjust CORS origins accordingly.
- Ensure Redis and database URLs match your deployment topology.

**Section sources**
- [backend/app/core/config.py:5](file://backend/app/core/config.py#L5)
- [backend/app/core/config.py:22](file://backend/app/core/config.py#L22)
- [backend/app/core/config.py:28](file://backend/app/core/config.py#L28)
- [frontend/vite.config.ts:12](file://frontend/vite.config.ts#L12)
- [frontend/vite.config.ts:14](file://frontend/vite.config.ts#L14)

## Running the Application Locally
Follow these steps to run the system end-to-end in development mode.

Option A: Docker Compose (recommended)
- Build and start all services: docker compose up --build
- Wait for all containers to initialize and show healthy status
- Open browser to http://localhost:3000 for the frontend

Option B: Manual installation
- Backend:
  - Install dependencies from backend/requirements.txt
  - Start Uvicorn on port 8000
- Frontend:
  - Install dependencies from frontend/package.json
  - Start Vite dev server on port 3000
- Verify connectivity:
  - Backend health endpoint: GET /health
  - API docs: GET /docs

**Section sources**
- [docker-compose.yml:3](file://docker-compose.yml#L3)
- [backend/requirements.txt:1](file://backend/requirements.txt#L1)
- [backend/app/main.py:43](file://backend/app/main.py#L43)
- [frontend/package.json:5](file://frontend/package.json#L5)
- [PROJECT_SUMMARY.md:100](file://PROJECT_SUMMARY.md#L100)

## Accessing the Services
After successful startup, access the services at the following endpoints:

- Frontend UI
  - Local URL: http://localhost:3000
  - Purpose: Vue-based web interface for managing files

- Backend API
  - Local URL: http://localhost:8000
  - Health check: GET /health
  - API docs: GET /docs (Swagger UI)
  - Authentication endpoints: POST /api/v1/auth/login, GET /api/v1/auth/status, POST /api/v1/auth/logout
  - File management endpoints: GET /api/v1/files/list, POST /api/v1/files/folder, DELETE /api/v1/files/delete, PUT /api/v1/files/rename, POST /api/v1/files/move, GET /api/v1/files/search, GET /api/v1/files/storage, GET /api/v1/files/download/{file_id}

- Redis
  - Local URL: http://localhost:6379
  - Used for task queues and caching

- Celery Worker
  - Runs inside its own container
  - Logs indicate task processing readiness

Notes:
- The project summary documents earlier ports (e.g., 9000), but current Compose and Dockerfiles expose backend on 8000 and frontend on 3000.
- Ensure no conflicting applications are using these ports before starting.

**Section sources**
- [PROJECT_SUMMARY.md:64](file://PROJECT_SUMMARY.md#L64)
- [PROJECT_SUMMARY.md:66](file://PROJECT_SUMMARY.md#L66)
- [PROJECT_SUMMARY.md:108](file://PROJECT_SUMMARY.md#L108)
- [backend/app/main.py:31](file://backend/app/main.py#L31)
- [backend/app/main.py:37](file://backend/app/main.py#L37)
- [docker-compose.yml:8](file://docker-compose.yml#L8)
- [docker-compose.yml:25](file://docker-compose.yml#L25)
- [docker-compose.yml:36](file://docker-compose.yml#L36)

## Initial Project Setup
Complete the following steps to prepare your environment for first-time use.

Backend:
- Install Python dependencies from requirements.txt
- Prepare a .env file if you need to override defaults (app name, database URL, Redis URL, secret key, CORS origins)
- Start the backend server on port 8000

Frontend:
- Install Node.js dependencies from package.json
- Start the Vite dev server on port 3000
- Confirm API proxy forwards /api to backend on port 8000

Docker Compose:
- Build and start all services
- Confirm persistent volumes exist for backend data and Redis

Optional: Integrate real QuarkClient APIs
- The project summary outlines future integration work for authenticating and managing files via the Quark service

**Section sources**
- [backend/requirements.txt:1](file://backend/requirements.txt#L1)
- [backend/app/core/config.py:28](file://backend/app/core/config.py#L28)
- [frontend/package.json:5](file://frontend/package.json#L5)
- [frontend/vite.config.ts:12](file://frontend/vite.config.ts#L12)
- [docker-compose.yml:59](file://docker-compose.yml#L59)
- [PROJECT_SUMMARY.md:75](file://PROJECT_SUMMARY.md#L75)

## Verification Steps
Perform these checks to confirm a successful installation and basic functionality.

Backend:
- Health check: curl http://localhost:8000/health
- API documentation: open http://localhost:8000/docs in a browser
- Root endpoint: curl http://localhost:8000/

Frontend:
- UI loads: open http://localhost:3000 in a browser
- API proxy verified: network tab shows /api requests forwarded to backend

Docker Compose:
- All services reachable on their respective host ports
- Celery worker container logs show worker ready messages
- Redis container responds on port 6379

Basic usage examples:
- Authentication: POST /api/v1/auth/login (use method "api" as per project summary)
- File listing: GET /api/v1/files/list
- Search: GET /api/v1/files/search?q=query

**Section sources**
- [PROJECT_SUMMARY.md:108](file://PROJECT_SUMMARY.md#L108)
- [PROJECT_SUMMARY.md:113](file://PROJECT_SUMMARY.md#L113)
- [PROJECT_SUMMARY.md:118](file://PROJECT_SUMMARY.md#L118)
- [backend/app/main.py:31](file://backend/app/main.py#L31)
- [backend/app/main.py:37](file://backend/app/main.py#L37)

## Common Setup Issues and Solutions
Below are typical problems and their resolutions.

Port conflicts:
- Symptom: Port 3000, 8000, or 6379 already in use
- Solution: Stop the conflicting process or change the port mappings in docker-compose.yml and/or Vite config

Python version mismatch:
- Symptom: Virtual environment or system Python older than 3.9
- Solution: Upgrade to Python 3.9+ as required by backend project metadata

Node.js/npm issues:
- Symptom: npm install fails or Vite dev server errors
- Solution: Clear node_modules cache, reinstall dependencies, and ensure Node.js 20.x is installed

Missing environment variables:
- Symptom: Backend fails to start or CORS misconfiguration
- Solution: Create a .env file with required variables (DATABASE_URL, REDIS_URL, SECRET_KEY, etc.) as per configuration class

Docker build failures:
- Symptom: Image build errors or slow installs
- Solution: Use the official Docker Compose setup; ensure Docker daemon is running and network connectivity is available

Frontend proxy not working:
- Symptom: API calls fail from the UI
- Solution: Confirm Vite proxy target points to backend on port 8000; restart dev server after changes

Celery worker not processing tasks:
- Symptom: No task logs or delayed processing
- Solution: Ensure Redis is reachable and Celery worker container is healthy; check logs for initialization messages

**Section sources**
- [backend/pyproject.toml:12](file://backend/pyproject.toml#L12)
- [frontend/vite.config.ts:12](file://frontend/vite.config.ts#L12)
- [frontend/vite.config.ts:14](file://frontend/vite.config.ts#L14)
- [backend/app/core/config.py:28](file://backend/app/core/config.py#L28)
- [docker-compose.yml:8](file://docker-compose.yml#L8)
- [docker-compose.yml:36](file://docker-compose.yml#L36)

## Troubleshooting Guide
Use the following diagnostic steps to isolate issues.

Check backend:
- Confirm health endpoint responds
- Review logs from the backend container or local process
- Validate CORS origins include http://localhost:3000

Check frontend:
- Verify Vite dev server runs on port 3000
- Inspect browser console and network tab for proxy errors
- Ensure API endpoints are prefixed with /api and routed to backend

Check Docker Compose:
- View logs for each service: docker compose logs backend, docker compose logs frontend, docker compose logs redis, docker compose logs celery-worker
- Confirm volumes exist and are mounted correctly

Test API endpoints:
- Use curl or Postman to hit /health, /docs, and authentication endpoints
- For file operations, test list/search endpoints before trying write operations

**Section sources**
- [backend/app/main.py:37](file://backend/app/main.py#L37)
- [frontend/vite.config.ts:12](file://frontend/vite.config.ts#L12)
- [docker-compose.yml:3](file://docker-compose.yml#L3)
- [PROJECT_SUMMARY.md:108](file://PROJECT_SUMMARY.md#L108)

## Conclusion
You now have multiple pathways to set up and run QuarkManager:
- Use Docker Compose for a production-like environment with minimal effort
- Run backend and frontend manually for development iterations

Follow the verification steps to confirm everything is working, and consult the troubleshooting section if you encounter issues. As the project evolves, integrate real QuarkClient APIs and expand database/caching layers according to your needs.