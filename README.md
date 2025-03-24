# Agent Ready App

A Ruby on Rails application that integrates with OpenAI's API to provide AI-powered functionality.

## System Requirements

* Ruby 3.3.4
* Rails 7.2.2
* SQLite 3
* Node.js (for Tailwind CSS)

## Key Features

* OpenAI API integration
* Real-time updates using Hotwire (Turbo)
* Interactive JavaScript functionality with Stimulus

## Setup

1. Clone the repository
2. Install dependencies:
```bash
bin/setup
```

3. Create a `.env` file in the root directory and add your OpenAI API key:
```bash
OPENAI_API_KEY=your_api_key_here
```

4. Start the Rails server:
```bash
bin/rails server
```

## Development

* The application uses SQLite as the database
* Tailwind CSS is used for styling
* JavaScript is handled through importmaps
* Environment variables are managed with dotenv-rails

## Testing

The application is configured with RSpec for testing. Run the test suite with:

```bash
bin/rails spec
```

## Docker Support

A production-ready Dockerfile is included. To build and run the application in Docker:

1. Build the image:
```bash
docker build -t agent-ready-app .
```

2. Run the container:
```bash
docker run -d -p 3000:3000 -e RAILS_MASTER_KEY=<your-master-key> agent-ready-app
```

## Development Environment

The application includes a devcontainer configuration for VS Code, providing:
* Preconfigured Ruby development environment
* GitHub CLI integration
* SQLite3 support
* Redis support
* Automated setup via postCreateCommand

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

[Add your license information here]
