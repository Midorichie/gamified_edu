# Gamified Education Platform for Clarity & Bitcoin Development

A interactive learning platform that teaches Clarity smart contract development and Bitcoin scripting through gamification. Learn blockchain development concepts while earning achievements and rewards!

## 🌟 Features

### Core Features
- Interactive lessons for Clarity and Bitcoin development
- Real-time code execution in a secure sandbox environment
- Achievement and reward system using smart contracts
- Progress tracking and gamification elements
- User authentication and profile management

### Learning Paths
- Clarity Smart Contract Development
- Bitcoin Script Programming
- Blockchain Fundamentals
- Advanced Contract Patterns

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- Docker
- Rust toolchain
- Clarity CLI
- Bitcoin Core (for Bitcoin script testing)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gamified-blockchain-education.git
cd gamified-blockchain-education
```

2. Set up Python virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Build the Docker containers for code execution:
```bash
docker build -t clarity-executor ./docker/clarity
```

5. Start the application:
```bash
python backend/app.py
```

## 🔧 Configuration

### Environment Variables
```
FLASK_APP=backend/app.py
FLASK_ENV=development
SECRET_KEY=your-secret-key
JWT_SECRET_KEY=your-jwt-secret
DATABASE_URL=your-database-url
```

### Security Settings
- Code execution timeout: 10 seconds
- Memory limit per execution: 512MB
- Rate limiting: 60 requests per minute
- Maximum code size: 1MB

## 📚 Project Structure

```
.
├── backend/                 # Python Flask backend
│   ├── app.py              # Main application entry
│   ├── models/             # Data models
│   ├── routes/             # API endpoints
│   ├── services/           # Business logic
│   └── utils/              # Helper functions
├── contracts/              # Smart contracts
│   ├── clarity/            # Clarity contracts
│   └── rust/               # Rust game logic
└── docs/                   # Documentation
```

## 🎮 Usage

### Starting a Learning Journey

1. Create an account or log in
2. Choose a learning path (Clarity or Bitcoin)
3. Complete interactive lessons
4. Write and test code in the sandbox
5. Earn achievements and rewards
6. Track your progress

### Example Lesson: Hello World in Clarity

```clarity
(define-public (hello-world)
    (ok "Hello, World!")
)
```

## 🛠 Development

### Running Tests
```bash
pytest backend/tests/
```

### Adding New Lessons
1. Create a new lesson file in `backend/content/lessons/`
2. Define test cases in `backend/content/tests/`
3. Add achievement criteria in the achievement contract
4. Update the lesson registry

### Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 🔐 Security

- All code execution happens in isolated Docker containers
- Rate limiting on API endpoints
- Input validation and sanitization
- JWT-based authentication
- Secure password hashing

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 🎯 Roadmap

- [ ] Add more advanced Clarity contract patterns
- [ ] Implement peer review system
- [ ] Add interactive debugging tools
- [ ] Implement multiplayer challenges
- [ ] Add more achievement types
- [ ] Integrate with testnet deployment

## 📫 Support

For support, please create an issue in the GitHub repository or contact the maintainers.