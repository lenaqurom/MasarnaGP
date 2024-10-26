# Masarna - Collaborative Travel Planning Platform

Masarna is a collaborative travel planning app designed to streamline group travel organization. With features like group itinerary planning, event mapping, media uploads, and AI-driven weather suggestions, Masarna makes travel planning easy, efficient, and enjoyable.

## Table of Contents
- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Project Architecture](#project-architecture)
- [Tech Stack](#tech-stack)
- [Setup & Installation](#setup--installation)
- [Usage](#usage)
- [Future Enhancements](#future-enhancements)

## Project Overview
Masarna addresses common challenges in group travel planning, offering a platform where users can organize, discuss, and visualize trip details in one place. From event scheduling to weather-based suggestions, the app provides a comprehensive solution for seamless trip coordination.

## Key Features
- **Trip Planning**: Create trip plans, invite friends, and manage shared and personal events.
- **Location Mapping**: View locations and routes for planned events.
- **Media Uploads**: Upload photos/videos and generate a shareable trip reel.
- **Notifications**: Real-time alerts for event updates.
- **Chat and Translate**: In-app chat and translation for better communication on the go.
- **Smart Chatbot**: Get travel tips and itinerary suggestions based on weather.
- **Weather Forecast**: 16-day forecasts for multiple cities.
- **Admin Management**: Tools for managing users, handling reports, and system oversight.

## Project Architecture

### MVC Structure
The platform is built with an MVC architecture:
- **Model**: MongoDB stores core data, while Firebase handles chat-specific data.
- **View**: Flutter-based UI for both web and mobile.
- **Controller**: Express.js server for core functionality, Flask server for chatbot processing.

### Development Workflow
An Agile model was used for iterative development:
1. **Requirement Analysis**: Defined core features and objectives.
2. **Planning**: Chose tech stack and assigned tasks.
3. **Development**: Regular meetings and testing sessions.
4. **Testing**: Used Postman for backend tests and Android emulators for frontend.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Express.js (Node.js), Flask (Python)
- **Database**: MongoDB Atlas, Firebase
- **Machine Learning**: TensorFlow, Keras, Naive Bayes for activity classification
- **Libraries**: Puppeteer (web scraping), Axios (API requests), Syncfusion (calendar), Google Maps API (maps)

## Setup & Installation

### Prerequisites
- [Node.js](https://nodejs.org/)
- [Python](https://www.python.org/) with Flask
- [MongoDB Atlas](https://www.mongodb.com/atlas/database)
- [Flutter SDK](https://flutter.dev/)

### Installation Steps
1. **Clone the Repository**:
   ```bash
   git clone <repo-link>
   cd Masarna
   ```
2. **Install Dependencies**:
   - For Node.js:
   ```bash
   npm install
   ```
   - For Python:
   ```bash
   pip install -r requirements.txt
   ```
3. **Database Configuration**:
  - Set up MongoDB and Firebase.
  - Update connection strings in .env files.
4. **Run the Backend**:
  - Start the Express.js server:
    ```bash
    npm start
    ```
  - Start the Flask server:
    ```bash
    python app.py
    ```
5. **Run the Frontend**:
   ```bash
   flutter run
   ```
### Usage
- Create Trip: Start a new trip, invite members, and manage events.
- Use the Chatbot: Ask for travel advice or itinerary suggestions tailored to weather.
- Admin Controls: Manage user activities and respond to reports in the admin dashboard.

### Future Enhancements
- Expanding chatbot interactions for a broader range of conversation.
- Adding more itinerary suggestions and activities.
- Implementing support for iOS.


