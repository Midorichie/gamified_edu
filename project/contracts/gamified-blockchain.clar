# Updated Project Structure
.
├── README.md
├── backend/
│   ├── __init__.py
│   ├── app.py
│   ├── config.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── lesson.py
│   │   ├── progress.py
│   │   └── achievement.py
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── lessons.py
│   │   ├── progress.py
│   │   └── code_execution.py
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── code_executor.py
│   │   └── achievement_service.py
│   └── utils/
│       ├── __init__.py
│       ├── validators.py
│       └── security.py
├── contracts/
│   ├── clarity/
│   │   ├── progress-tracker.clar
│   │   ├── reward-system.clar
│   │   └── achievement-system.clar
│   └── rust/
│       └── game_logic/
│           ├── lib.rs
│           └── sandbox.rs
└── requirements.txt

# backend/app.py
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from routes import auth, lessons, progress, code_execution
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
jwt = JWTManager(app)

# Register blueprints
app.register_blueprint(auth.bp)
app.register_blueprint(lessons.bp)
app.register_blueprint(progress.bp)
app.register_blueprint(code_execution.bp)

# backend/services/auth_service.py
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
import datetime

class AuthService:
    @staticmethod
    def create_user(username, email, password):
        hashed_password = generate_password_hash(password)
        # Store user in database
        return {"username": username, "email": email}

    @staticmethod
    def login(username, password):
        # Verify user credentials
        access_token = create_access_token(
            identity=username,
            expires_delta=datetime.timedelta(days=1)
        )
        return access_token

# backend/services/code_executor.py
import docker
import subprocess
from typing import Dict, Any

class CodeExecutor:
    def __init__(self):
        self.client = docker.from_env()

    def execute_clarity_code(self, code: str) -> Dict[str, Any]:
        try:
            container = self.client.containers.run(
                "clarity-executor",
                code,
                remove=True,
                timeout=10
            )
            return {"success": True, "output": container.decode('utf-8')}
        except Exception as e:
            return {"success": False, "error": str(e)}

    def execute_bitcoin_script(self, script: str) -> Dict[str, Any]:
        try:
            result = subprocess.run(
                ["bitcoin-cli", "test-script", script],
                capture_output=True,
                text=True,
                timeout=5
            )
            return {"success": True, "output": result.stdout}
        except Exception as e:
            return {"success": False, "error": str(e)}

# backend/routes/code_execution.py
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from services.code_executor import CodeExecutor

bp = Blueprint('code_execution', __name__, url_prefix='/execute')
executor = CodeExecutor()

@bp.route('/clarity', methods=['POST'])
@jwt_required()
def execute_clarity():
    code = request.json.get('code')
    result = executor.execute_clarity_code(code)
    return jsonify(result)

@bp.route('/bitcoin', methods=['POST'])
@jwt_required()
def execute_bitcoin():
    script = request.json.get('script')
    result = executor.execute_bitcoin_script(script)
    return jsonify(result)

# contracts/clarity/achievement-system.clar
;; Achievement System Contract

(define-map achievements
    { achievement-id: uint }
    {
        title: (string-utf8 50),
        description: (string-utf8 200),
        points: uint,
        requirements: (list 5 uint)
    }
)

(define-map user-achievements
    { user-id: (string-utf8 36) }
    { completed: (list 20 uint) }
)

(define-public (unlock-achievement (user-id (string-utf8 36)) (achievement-id uint))
    (let (
        (achievement (unwrap! (map-get? achievements { achievement-id: achievement-id }) (err u404)))
        (user-completed (default-to (list) (get completed (map-get? user-achievements { user-id: user-id }))))
    )
    (if (is-none (index-of user-completed achievement-id))
        (begin
            (map-set user-achievements
                { user-id: user-id }
                { completed: (append user-completed achievement-id) }
            )
            (ok true)
        )
        (err u403)
    ))
)

# contracts/rust/game_logic/sandbox.rs
use std::process::{Command, Stdio};
use std::time::Duration;
use std::io::Write;

pub struct Sandbox {
    timeout: Duration,
    memory_limit: usize,
}

impl Sandbox {
    pub fn new(timeout_secs: u64, memory_mb: usize) -> Self {
        Sandbox {
            timeout: Duration::from_secs(timeout_secs),
            memory_limit: memory_mb * 1024 * 1024,
        }
    }

    pub fn execute_code(&self, code: &str) -> Result<String, String> {
        let mut child = Command::new("clarity-cli")
            .arg("execute")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        let mut stdin = child.stdin.take().unwrap();
        stdin.write_all(code.as_bytes()).map_err(|e| e.to_string())?;
        drop(stdin);

        match child.wait_timeout(self.timeout) {
            Ok(Some(status)) => {
                if status.success() {
                    Ok("Code executed successfully".to_string())
                } else {
                    Err("Execution failed".to_string())
                }
            }
            Ok(None) => {
                child.kill().map_err(|e| e.to_string())?;
                Err("Execution timed out".to_string())
            }
            Err(e) => Err(e.to_string()),
        }
    }
}

# Sample Lesson Content
LESSON_CONTENT = {
    "clarity_basics": [
        {
            "id": "clarity_intro",
            "title": "Introduction to Clarity",
            "content": """
# Introduction to Clarity Programming

In this lesson, you'll learn the basics of Clarity, the smart contract language for the Stacks blockchain.

## Key Concepts:
1. Smart Contracts
2. Principal Types
3. Functions and Variables

## Practice Exercise:
Write a simple contract that stores and retrieves a value.

```clarity
(define-data-var stored-value uint u0)

(define-public (set-value (new-value uint))
    (begin
        (var-set stored-value new-value)
        (ok true)
    )
)

(define-read-only (get-value)
    (ok (var-get stored-value))
)
```
            """,
            "test_cases": [
                {
                    "input": "(set-value u42)",
                    "expected": "(ok true)"
                },
                {
                    "input": "(get-value)",
                    "expected": "(ok u42)"
                }
            ]
        }
    ]
}

# requirements.txt
flask==2.0.1
flask-cors==3.0.10
python-dotenv==0.19.0
pytest==6.2.5
black==21.9b0
flask-jwt-extended==4.3.1
docker==5.0.0