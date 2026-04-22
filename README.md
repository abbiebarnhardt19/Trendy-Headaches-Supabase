# Trendy Headaches

An iOS health tracking application designed to help users monitor and analyze migraine patterns through comprehensive symptom logging and interactive data visualizations.

## Project Overview

Trendy Headaches is a sophisticated iOS application that empowers users to take control of their migraine health through detailed tracking and data-driven insights. The app provides an intuitive interface for logging symptoms, medications, triggers, and side effects, paired with powerful analytics dashboards that help users identify patterns in their migraine occurrences.

**Status**: Active Development - UI refinements in progress before App Store launch

## Key Features

### Comprehensive Health Logging
- Track multiple aspects of migraine episodes including:
  - Symptoms and their severity
  - Medications taken
  - Potential triggers
  - Side effects experienced
  - Custom log topics for personalized tracking
- Flexible logging system that adapts to individual user needs
- Historical log management with easy editing and deletion

### Interactive Data Visualizations
- **Analytics Dashboard** with three main sections:
  - **Graphs Subview**: Visual representations of trends over time
  - **Compare Subview**: Side-by-side comparisons of different variables
  - **Statistics Subview**: Detailed statistical analysis of logged data
- Custom-designed charts and visualizations for different data types
- Correlation analysis between symptoms, triggers, and medications
- Time-based trend analysis to identify patterns
- Export capabilities for sharing with healthcare providers

### Modern User Interface
- Clean, intuitive design focused on ease of use during migraine episodes
- Thoughtfully crafted user experience flows
- Custom UI components including:
  - Specialized text fields for health data entry
  - Multiple choice selections for quick logging
  - Custom tables for list views
  - Editable lists in profile management
- Responsive layouts optimized for all iPhone sizes
- Tutorial system to guide new users through app features

### Cloud-Powered Backend
- Supabase integration with PostgreSQL database
- Real-time data synchronization across devices
- Secure user authentication
- Automatic backup and recovery capabilities
- Row-level security for data privacy

## Technologies Used

- **Swift**: Native iOS development for optimal performance
- **SwiftUI/UIKit**: Modern, responsive user interface design
- **Supabase**: Cloud database backend with PostgreSQL foundation
- **Supabase Swift Package**: Official SDK for database integration
- **Model-View-Controller Architecture**: Organized, maintainable code structure
- **Custom Data Visualization Components**: Purpose-built analytics views

## Database Schema

The application uses a relational database with the following core entities:
- **Users**: User authentication and profile information
- **Logs**: Individual migraine episode records
- **Log_Topics**: Custom tracking categories
- **Symptoms**: Symptom types and severity tracking
- **Medications**: Medication tracking and dosage information
- **Triggers**: Potential migraine trigger identification
- **Side_Effects**: Side effect monitoring and correlation

All entities are connected through well-defined relationships to enable comprehensive data analysis.

## Repository Structure

```
Trendy-Headaches-Supabase/
├── Functions/
│   ├── View Functions/          # View-specific logic and data operations
│   └── Non-View Functions/      # Database, security, and utilities
│       ├── Database/            # Supabase connection and SQL helpers
│       ├── Security/            # Authentication and data security
│       └── Environment Objects/ # Shared state management
├── Styles/
│   ├── Reusable Components/     # Cross-view UI components
│   ├── View-Specific Components/# Single-view UI elements
│   └── Analytics Components/    # Visualization components
│       ├── Graphs/              # Chart and graph components
│       ├── Compare/             # Comparison view components
│       └── Statistics/          # Statistical analysis components
├── Views/                       # Main application screens
└── Resources/                   # Assets and configurations
```

## Code Organization

The project follows Model-View-Controller architecture with clear separation of concerns:

### Naming Conventions
- **Functions**: camelCase (e.g., `preloadAll`)
- **Custom Data Types**: PascalCase (e.g., `CustomTextField`)
- **Variables**: snake_case or camelCase depending on context

### Environment Objects
Three key environment objects manage application state:
- **TutorialManager**: Controls tutorial display for new users
- **PreloadManager**: Handles data preloading and caching
- **UserSession**: Manages authentication state and user data

### Function Organization
- **View Functions**: Handle fetching, updating, and adding data for specific views
- **Database Functions**: Manage Supabase connections and SQL operations
- **Security Functions**: Handle authentication and data encryption

## Project Evolution

### Previous Version: Trendy-Headaches-SQLite
The original implementation used SQLite for local database management. The project was migrated to Supabase to enable:
- Cloud synchronization and backup
- Multi-device support
- Enhanced scalability
- Real-time data updates
- Improved data security and user authentication

**Note**: The SQLite version remains available in the [Trendy-Headaches-SQLite](https://github.com/abbiebarnhardt19/Trendy-Headaches-SQLite) repository for reference.

## Development Roadmap

### Current Phase: UI/UX Refinement
- Polishing user interface design
- Enhancing user experience flows
- Optimizing performance and responsiveness
- Conducting user testing and feedback integration
- Preparing App Store submission materials

### Upcoming Features
- Apple Health integration
- Weather API integration for automatic environmental tracking
- Medication reminder notifications
- Enhanced data visualization options
- Shareable reports for healthcare providers
- Community insights (anonymized aggregate data)

## Technical Highlights

### User Interface Design
The app features a carefully crafted interface that:
- Makes health data logging quick and easy, even during migraine episodes
- Provides intuitive navigation through multiple data views
- Uses visual hierarchy to highlight important information
- Implements responsive design patterns for various screen sizes
- Includes a comprehensive tutorial system for new users

### Data Visualization Architecture
Custom analytics components provide:
- Multiple chart types for different data relationships
- Interactive elements for exploring data in depth
- Three distinct analytics views (Graphs, Compare, Statistics)
- Time-based trend analysis
- Correlation analysis for identifying trigger patterns
- Customizable views based on user preferences

### Database Architecture
Supabase backend provides:
- PostgreSQL relational database with complex querying capabilities
- Row-level security for user data privacy
- Real-time subscriptions for instant updates
- RESTful API integration with Swift
- Scalable infrastructure for growing user base

### Data Privacy & Security
- End-to-end encryption for sensitive health data
- HIPAA-compliant data handling practices
- User-controlled data sharing and export
- Secure authentication with Supabase Auth
- Hashing utilities for sensitive information

## Setup & Installation

### Prerequisites
```
Xcode 14.0+
iOS 15.0+ deployment target
Supabase account and project
Swift 5.5+
```

### Dependencies
The project requires only one external dependency:
- **Supabase Swift Package**: Required for all database functionality

### Installation
1. Clone the repository
```bash
git clone https://github.com/abbiebarnhardt19/Trendy-Headaches-Supabase.git
cd Trendy-Headaches-Supabase
```

2. Install Supabase Swift Package
- Open the main project file in Xcode
- Select the application target
- Add the Supabase package under Frameworks, Libraries, and Embedded Content

3. Configure Supabase credentials
- Create a `Config.swift` file with your Supabase URL and API key
- Update database connection settings
- Credentials for the developer account are stored in project documentation

4. Build and run
- Select your target device or simulator
- Build and run (⌘R)

## Database Access

Database schema documentation and current table contents are available through the project's Dropbox folder. Access is provided through a dedicated developer account with credentials stored in the project documentation.

## Why This Project Matters

Migraine disorders affect over 1 billion people worldwide, yet many struggle to identify their personal triggers and patterns. Trendy Headaches empowers users with:
- **Comprehensive tracking** that captures all relevant migraine data
- **Visual analytics** that make complex health data understandable
- **Pattern recognition** through correlation and trend analysis
- **Actionable intelligence** to improve quality of life and inform healthcare decisions

## App Store Launch

This application is currently in final development stages with an anticipated App Store launch in 2026.

## Contact

**Abigail Barnhardt**
- Email: abbiebarnhardt@gmail.com
- LinkedIn: [linkedin.com/in/abigail-barnhardt-6276942b5](https://linkedin.com/in/abigail-barnhardt-6276942b5)
- GitHub: [@abbiebarnhardt19](https://github.com/abbiebarnhardt19)

## License

This project is currently in development. All rights reserved. Please contact the author for usage permissions.

## Acknowledgments

Special thanks to:
- Region One Planning Council for supporting data analytics research
- Concordia University Wisconsin Computer Science program
- The migraine community for inspiration and feedback

---

*Combining mobile development, cloud architecture, and data visualization to make a meaningful impact on migraine management.*

**Related Repositories**:
- [Headache-Predictions](https://github.com/abbiebarnhardt19/Headache-Predictions) - Data analysis research and exploration
- [Trendy-Headaches-SQLite](https://github.com/abbiebarnhardt19/Trendy-Headaches-SQLite) - Original SQLite implementation
