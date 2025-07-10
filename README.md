
# 📚 Library Data Ingestion, Normalization & KPI Reporting System

## 📌 Overview

This project demonstrates an end-to-end data engineering workflow using **SQL Server**. Data from four Excel files is ingested, normalized, stored in structured relational tables, and migrated to a clean database where KPIs are generated using stored procedures.

---

## 🚀 Features

- Bulk data import from 4 Excel files using `BULK INSERT`
- Normalization of denormalized raw data into relational tables
- Migration of clean data to a separate `LibraryClean` database
- Stored procedures for KPI calculation (e.g., book issue trends, overdue stats, user activity)
- Clean and scalable database design

---

## 🛠️ Technologies Used

- **SQL Server**
- **T-SQL** (Queries, Views, Stored Procedures)
- **Excel (as source files)**
- **SSMS (SQL Server Management Studio)**

---

## 🗂️ Project Architecture

```text
Excel Files (4) → Raw Tables in LibraryRaw DB
                  ↓
        Normalization using SQL
                  ↓
     Relational Tables (Books, Users, Issues, etc.)
                  ↓
     Migrated to LibraryClean DB
                  ↓
    KPI Reporting using Stored Procedures
