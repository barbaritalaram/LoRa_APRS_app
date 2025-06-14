# GitHub Workflows

This directory contains all the GitHub Actions workflows for the LoRa APRS App project.

## CI (`ci.yml`)

This workflow handles the Continuous Integration process for the project. It is triggered on every push and pull request to the `main` and `develop` branches.

### Stages:
1.  **Set up Environment**: Prepares a clean Ubuntu environment with a consistent version of Flutter.
2.  **Install Dependencies**: Fetches all the project dependencies.
3.  **Analyze**: Runs static code analysis to check for code quality and potential issues.
4.  **Test**: Executes all unit and widget tests.
5.  **Build**: Compiles a debug APK to ensure the project is buildable.

This ensures that any code integrated into the main branches is always stable and meets quality standards. 