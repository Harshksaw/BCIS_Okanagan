# BCIS_Okanagan
# BCIS_Okanagan

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the Application](#running-the-application)
- [Accessing Jupyter Lab](#accessing-jupyter-lab)
- [Pushing Changes to GitHub](#pushing-changes-to-github)
- [Troubleshooting](#troubleshooting)

## Introduction
This project sets up a PostgreSQL database and a Jupyter Lab environment using Docker. The Jupyter Lab environment is configured to work with Python libraries such as `yfinance`, `sqlalchemy`, `pandas`, `matplotlib`, and `seaborn`.

## Prerequisites
Before you begin, ensure you have the following installed on your machine:
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

## Setup
1. **Clone the Repository**:
   ```sh
   git clone https://github.com/Harshksaw/BCIS_Okanagan.git
   cd BCIS_Okanagan

2. Open cloned repo in vscode, or enter this command to directly open form terminal, if youa re in that directory

    ```
    code .


3. got to directory 
cd COSC436

4.2. Build and start the Docker containers:


    ```sh
    docker-compose up --build
    ```

3. Access the Jupyter Lab interface:

    Open your web browser and navigate to [http://localhost:8888](http://localhost:8888). You should see the Jupyter Lab interface.

   -
   -
   After Opening this link you will encounter Jypter notbook | GO inside notebooks ,there you find the .ipynb pything file , go thorught it
   

## Project Structure

- `docker-compose.yml`: Docker Compose configuration file
- `Dockerfile`: Dockerfile for building the Jupyter Lab environment
- `notebooks/`: Directory containing Jupyter notebooks
  - `stock_analysis.ipynb`: Main notebook for stock analysis
- `README.md`: This file

## Stopping the Containers

To stop the running containers, use the following command:

```sh
docker-compose down







## Creating a Backup of the SQL Database

To create a backup of your PostgreSQL database, follow these steps:

1. **Find the Container ID**:
    First, find the container ID of the running PostgreSQL container. You can do this by listing all running containers:
    ```sh
    docker ps
    ```

2. **Execute the Backup Command**:
    Use the `docker exec` command to create a backup of the database. Replace `CONTAINER_ID` with the actual container ID from the previous step:
    ```sh
    docker exec -t CONTAINER_ID pg_dump -U cosc stock_data > stock_data.sql
    ```

This will create a file named `stock_data.sql` in your current directory containing the backup of your PostgreSQL database.




## Updating the Project

To update the project with the latest changes, follow these steps:

1. **Pull the Latest Changes**:
    ```sh
    git pull origin main
    ```

2. **Stop and Remove Previous Docker Containers**:
    ```sh
    docker-compose down
    docker system prune -f
    ```

3. **Rebuild and Start the Docker Containers**:
    ```sh
    docker-compose up --build
    ```

This will ensure that you have the latest code and a fresh Docker environment.