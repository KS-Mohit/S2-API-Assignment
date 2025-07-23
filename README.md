# KPA-ERP Full Stack Application

This project is a full-stack implementation of the KPA ERP system, featuring a **Flutter Web frontend** and a **FastAPI backend**. It is designed to provide a complete, interactive experience for managing railway maintenance forms, backed by a PostgreSQL database.

---

## Implemented APIs

The backend API has been expanded to support the full functionality of the frontend.

1.  **Form Submission**
    * `POST /api/forms/wheel-specifications`: Submits a new Wheel Specifications form.
    * `POST /api/forms/bogie-checksheet`: Submits a new Bogie Checksheet form.


3.  **Data Retrieval & Filtering**
    * `GET /api/forms/all`: This is a powerful endpoint that retrieves a combined list of all submitted forms (`Wheel Specs` and `Bogie Checksheets`). It supports filtering by `formNumber`, `inspector`, and a `startDate`/`endDate` range.

---

## Tech Stack

* **Frontend**: Flutter 3.19.6 with Dart 3.3.4
* **Backend**: Python 3.10 with FastAPI
* **Database**: PostgreSQL
* **Data Validation**: Pydantic
* **Database ORM**: SQLAlchemy
* **Containerization**: Docker

---

## Setup and Installation

### Prerequisites
* Python 3.10+ & `pip`
* Flutter SDK
* Docker Desktop

### 1. Local Development Setup (Recommended)

This method runs both the frontend and backend locally without containers.

1.  **Run the Backend**:
    * Navigate to the `backend` directory.
    * Create and activate a virtual environment: `python -m venv venv` then `.\venv\Scripts\activate`.
    * Install dependencies: `pip install -r requirements.txt`.
    * Create a `.env` file with `DATABASE_URL=postgresql://USER:PASS@localhost/DB_NAME`.
    * Start the server: `uvicorn main:app --reload`. It will run on `http://localhost:8000`.

2.  **Run the Frontend**:
    * Open a **new terminal**.
    * Navigate to the `KPA-ERP-FE` (frontend) directory.
    * Update the API base URL in `lib/services/api_services/api_service.dart` to point to your local server:
        ```dart
        static const String _baseUrl = 'http://localhost:8000';
        ```
    * Get dependencies: `flutter pub get`.
    * Start the app: `flutter run -d chrome`.

### 2. Backend-Only Docker Setup

This method runs the backend in a Docker container while the frontend runs locally on your machine.

1.  **Configure Environment for Docker**:
    * In the `backend` directory, create a `.env` file.
    * Ensure the `DATABASE_URL` points to `host.docker.internal` to connect to the PostgreSQL server running on your host machine.
        ```
        DATABASE_URL=postgresql://YOUR_USER:YOUR_PASSWORD@host.docker.internal/assignment_db
        ```

2.  **Build the Docker Image**:
    * Navigate to the `backend` directory.
    * Run the build command:
        ```bash
        docker build -t kpa-api .
        ```

3.  **Run the Docker Container**:
    ```bash
    docker run -p 8000:8000 --env-file .env kpa-api
    ```
    The backend API will be available at `http://localhost:8000`.

4.  **Run the Frontend**:
    * Follow the steps in the "Local Development Setup" to run the frontend, ensuring its `_baseUrl` in `api_service.dart` is pointed to `http://localhost:8000`.

---

## Bonus Features Implemented

* **Dockerization**: The backend application is fully containerized with a `Dockerfile` for easy deployment and isolation.
* **Robust Input Validation**: Validation is handled on the frontend (Flutter forms) and backend (Pydantic models).
* **Environment-based Configuration**: A `.env` file is used to securely manage the database credentials, keeping them separate from the source code.
* **Automatic API Documentation**: FastAPI automatically generates a live, interactive Swagger UI at the `/docs` endpoint.
* **Advanced Filtering**: The `/api/forms/all` endpoint supports server-side filtering by form number, inspector, and date range.
