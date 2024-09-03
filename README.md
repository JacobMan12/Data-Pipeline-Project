# Data Pipeline Project

## Overview

This project demonstrates the creation of a simple data pipeline that integrates data extraction from an external API, data cleaning, database management, and data visualization. The pipeline is implemented using Python and SQL, with data sourced from the Polygon API and processed into a local SQL Server database.

This was completed on 7/12/24.

## Project Workflow

1. **Data Extraction and Cleaning (`P1 - Data Cleaning.ipynb`)**:
   - The Python notebook loads raw data directly from the Polygon API (`https://api.polygon.io`).
   - The data is then cleaned and prepared for further processing.
   - Once cleaned, the data is loaded into a SQL Server database on the local machine.

2. **Database Setup and Management (SQL Scripts)**:
   - **Loading Tables (`Project1SQL - Loading Tables.sql`)**:
     - This SQL script initializes the database by creating the necessary tables in the SQL Server.
   - **Star Schema (`P1 - Star Schema.sql`)**:
     - The star schema script structures the data into fact and dimension tables, optimizing the database for analysis and reporting.
   - **Metric Views (`P1 - Metric Views.sql`)**:
     - This script creates views in the SQL Server to facilitate the analysis of various key metrics.

3. **Data Visualization (`P1 - Visualization.ipynb`)**:
   - After the database and views are set up, this Python notebook pulls data from the created views.
   - The notebook generates visualizations based on the metrics defined in the views, providing insights into the data.

## Project Structure

- **Notebooks**:
  - `P1 - Data Cleaning.ipynb`: Handles data extraction, cleaning, and loading into the SQL Server.
  - `P1 - Visualization.ipynb`: Pulls data from SQL Server views and generates visualizations.
  
- **SQL Scripts**:
  - `Project1SQL - Loading Tables.sql`: Initializes the database and creates tables.
  - `P1 - Star Schema.sql`: Defines the star schema within the database.
  - `P1 - Metric Views.sql`: Creates views for various metrics.

## How to Run the Project

### Prerequisites

- Python 3.x
- Jupyter Notebook
- SQL Server (or any other relational database)
- Required Python packages (listed in the notebooks)
- Access to the Polygon API

### Steps to Execute

1. **Data Extraction and Cleaning**:
   - Open `P1 - Data Cleaning.ipynb` in Jupyter Notebook.
   - Run the cells to load data from the Polygon API, clean it, and load it into the SQL Server database.

2. **Database Setup**:
   - Execute the SQL scripts in the following order:
     1. `Project1SQL - Loading Tables.sql` to create the necessary tables in SQL Server.
     2. `P1 - Star Schema.sql` to structure the data into the star schema.
     3. `P1 - Metric Views.sql` to create views for metric analysis.

3. **Visualization**:
   - Open `P1 - Visualization.ipynb` in Jupyter Notebook.
   - Execute the cells to pull data from the SQL Server views and generate visualizations.

## Project Files

- `P1 - Data Cleaning.ipynb`: Python notebook for data extraction, cleaning, and loading.
- `P1 - Visualization.ipynb`: Python notebook for data visualization.
- `Project1SQL - Loading Tables.sql`: SQL script for database initialization.
- `P1 - Star Schema.sql`: SQL script for defining the star schema.
- `P1 - Metric Views.sql`: SQL script for creating metric views.

## Acknowledgments

- Polygon API for data sourcing.
- SQL Server and Python libraries used for data processing and visualization.
