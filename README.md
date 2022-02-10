# ScalableParkingCapacityApp
Tracks which parking stalls are unavailable in underground parking.


# Installation:

Installing Flask Package


>pip install Flask


Installing pyodbc Package


>pip install pyodbc


Installing ODBC package


https://www.microsoft.com/en-us/download/details.aspx?id=50420 Is the source location. Must be 13. Once installed, will run on native linux or native windows.


Packages:
- Flask : Required package for python, in order to host our Web Server API
- pyodbc : Connects our API to our Microsoft Azure SQL Database

# Getting Started

## Python Version

Our ScalableParkingCapacityApp depends on packages that was written for Python 3 and will not correctly work on Python 2


# API Routes

Our API follows REST-ful guidelines

## GET Route

>URI/api/v1/parking-lot/{place-name}/{lot-ID}

This route will obtain all database entries relating to ***{place-name}*** in parking lot ***{lot-ID}***.

Example Usage:

>localhost:420/api/v1/parking-lot/madison-garden/D3





