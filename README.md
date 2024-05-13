# Campus-InOut-Management-App

Campus-InOut-Management-App is a comprehensive campus entry and exit management system designed to streamline the flow of students, visitors, and authorities on campus. Built with a focus on safety, efficiency, and accessibility, this app aims to enhance the overall security and management of educational institutions.

## Table of Contents

- [Project Description](#project-description)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [Usage](#usage)


## Project Description

App is an advanced campus entry and exit management system developed to address the specific needs of educational institutions. With the primary goal of ensuring a secure and organized environment, this app facilitates the management of student entry and exit, visitor registration, and administrative oversight.

##### Purpose:

The purpose of this App is to provide a user-friendly and efficient solution for managing campus access. By digitizing the entry and exit process, the app aims to enhance security measures, streamline administrative tasks, and improve overall campus operations.

##### Goals:

```Improve Campus Security```: By implementing robust authentication mechanisms and access controls, the app aims to enhance campus security and prevent unauthorized access.

```Enhance User Experience```: App
prioritizes user experience, offering intuitive interfaces for students, visitors, guards, and administrators, ensuring smooth navigation and interaction.

```Streamline Administrative Tasks```: The app automates various administrative tasks such as visitor registration, ticket generation, and  reducing manual effort and increasing efficiency.

```Provide Data Insights```: By collecting and analyzing data related to campus entry and exit, the app enables administrators to gain valuable insights into campus traffic patterns, visitor demographics, and security incidents.



## Getting Started

### Prerequisites

*Flutter SDK*: Ensure you have Flutter SDK installed on your machine. You can download it from the official Flutter website.

*Dart*: Dart programming language is required as Flutter uses Dart for its development.

*Python*: This project utilizes Django as the backend server, so Python must be installed on your system. You can install Python from the official Python website.

*Django*: Install Django framework using pip, the Python package manager. You can do this by running pip install django in your terminal or command promp

### Installation

Installation and Setup
Follow these steps to install and set up the project:

- Step 1: Clone the Repository
Clone the repository from GitHub to your local machine:



git clone [Link](https://github.com/Patel-Het03/DEP24-P13-Campus-InOut-Management-App).

- Step 2: Backend Setup
Navigate to the backend directory and run the Django server:

```
cd backend
python manage.py runserver
```

- Step 3: Frontend Setup
Navigate to the frontend directory and install the required dependencies:

```
cd frontend
flutter pub get
```

- Step 4: Run the Flutter App
Run the Flutter app locally using the following command:

```
flutter run -d chrome --web-port 8080
```

- Step 5: Generate APK
To generate an APK, use the following command:

```
flutter build apk --build-name=1.0.1 --build-number=1
```

## Usage

To utilize the project, ensure the Django server is running for backend support. Install Flutter dependencies for frontend development and generate APKs as needed. Once set up, users can access various functionalities based on their roles, including ticket generation, QR code scanning, and data management.

