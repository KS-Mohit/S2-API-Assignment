# KPA Backend API Implementation

This project is a backend implementation for the KPA ERP system, as per the requirements of the backend development assignment. It features a set of FastAPI endpoints designed to integrate with the provided frontend codebase and a PostgreSQL database.

## Implemented APIs

The following two APIs from the SwaggerHub documentation have been implemented:

1.  **`POST /api/forms/bogie-checksheet`**
    * **Description**: Submits a new, multi-section Bogie Checksheet form.
    * **Functionality**: Receives a complex JSON object containing details for three separate checklists, validates the structure, and saves the entire form as a single record in the `bogie_checksheets` table.

2.  **`POST /api/forms/wheel-specifications`** & **`GET /api/forms/wheel-specifications`**
    * **Description**: A full CRUD (Create, Read) implementation for the Wheel Specifications form.
    * **POST Functionality**: Submits a new Wheel Specifications form. The data is validated and stored in the `wheel_specifications` table.
    * **GET Functionality**: Retrieves a list of previously submitted Wheel Specifications forms. It supports optional query parameters (`formNumber`, `submittedBy`, `submittedDate`) to filter the results.

---

## Tech Stack

* **Framework**: Python 3.10 with FastAPI
* **Database**: PostgreSQL
* **Data Validation**: Pydantic
* **Database ORM**: SQLAlchemy
* **Containerization**: Docker

---

## Setup and Installation

### Prerequisites
* Python 3.10+
* PostgreSQL Server
* Docker Desktop (for containerized setup)

### Local Setup Instructions

1.  **Clone the Repository**:
    ```bash
    git clone <your-repo-url>
    cd S2_API_Assignment/backend
    ```

2.  **Create and Activate Virtual Environment**:
    ```bash
    # For Windows
    python -m venv venv
    .\venv\Scripts\activate
    ```

3.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

4.  **Configure Environment Variables**:
    * Create a file named `.env` in the `backend` directory.
    * Add your PostgreSQL connection string to it:
        ```
        DATABASE_URL=postgresql://YOUR_USER:YOUR_PASSWORD@localhost/assignment_db
        ```

5.  **Run the Application**:
    ```bash
    uvicorn main:app --reload
    ```
    The application will be available at `http://127.0.0.1:8000`. The interactive API documentation (Swagger UI) is available at `http://127.0.0.1:8000/docs`.

### Docker Setup Instructions

1.  **Configure Environment for Docker**:
    * In the `.env` file, ensure the `DATABASE_URL` points to `host.docker.internal` to connect to the PostgreSQL server running on your host machine.
        ```
        DATABASE_URL=postgresql://YOUR_USER:YOUR_PASSWORD@host.docker.internal/assignment_db
        ```

2.  **Build the Docker Image**:
    ```bash
    docker build -t kpa-api .
    ```

3.  **Run the Docker Container**:
    ```bash
    docker run -p 8000:8000 --env-file .env kpa-api
    ```
    The application will be available at `http://localhost:8000`.

---

## Bonus Features Implemented

* **Dockerization**: The application is fully containerized with a `Dockerfile` for easy deployment.
* **Input Validation**: Pydantic models are used to enforce required fields, data types, and the overall structure of incoming requests.
* **Environment-based Configuration**: A `.env` file is used to securely manage the database credentials, keeping them separate from the source code.
* **Swagger/OpenAPI Integration**: As a native feature of FastAPI, interactive API documentation is automatically generated and available at the `/docs` endpoint.
