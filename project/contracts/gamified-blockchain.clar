# Project Structure
.
├── README.md
├── backend/
│   ├── __init__.py
│   ├── app.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── lesson.py
│   │   └── progress.py
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── lessons.py
│   │   └── progress.py
│   └── utils/
│       ├── __init__.py
│       └── validators.py
├── contracts/
│   ├── clarity/
│   │   ├── progress-tracker.clar
│   │   └── reward-system.clar
│   └── rust/
│       └── game_logic/
│           └── lib.rs
└── requirements.txt

# backend/app.py
from flask import Flask, jsonify
from flask_cors import CORS
from routes import auth, lessons, progress

app = Flask(__name__)
CORS(app)

# Register blueprints
app.register_blueprint(auth.bp)
app.register_blueprint(lessons.bp)
app.register_blueprint(progress.bp)

@app.route('/health')
def health_check():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(debug=True)

# backend/models/user.py
from datetime import datetime
from dataclasses import dataclass

@dataclass
class User:
    id: str
    username: str
    email: str
    current_level: int
    points: int
    created_at: datetime
    completed_lessons: list

# backend/models/lesson.py
from dataclasses import dataclass

@dataclass
class Lesson:
    id: str
    title: str
    description: str
    difficulty: str
    content: str
    code_template: str
    test_cases: list
    points_reward: int
    prerequisites: list

# backend/routes/lessons.py
from flask import Blueprint, jsonify, request
from models.lesson import Lesson

bp = Blueprint('lessons', __name__, url_prefix='/lessons')

@bp.route('/', methods=['GET'])
def get_lessons():
    # Placeholder for database integration
    lessons = [
        Lesson(
            id="1",
            title="Introduction to Clarity",
            description="Learn the basics of Clarity smart contracts",
            difficulty="beginner",
            content="Welcome to Clarity programming...",
            code_template="(define-public (hello-world)...)",
            test_cases=[],
            points_reward=100,
            prerequisites=[]
        )
    ]
    return jsonify([vars(lesson) for lesson in lessons])

# contracts/clarity/progress-tracker.clar
;; Progress Tracker Contract

(define-data-var total-users uint u0)

(define-map user-progress
    { user-id: (string-utf8 36) }
    {
        level: uint,
        points: uint,
        completed-lessons: (list 10 uint)
    }
)

(define-public (register-user (user-id (string-utf8 36)))
    (begin
        (var-set total-users (+ (var-get total-users) u1))
        (ok (map-set user-progress
            { user-id: user-id }
            {
                level: u1,
                points: u0,
                completed-lessons: (list)
            }
        ))
    )
)

# contracts/clarity/reward-system.clar
;; Reward System Contract

(define-constant ERR_INSUFFICIENT_POINTS u1)
(define-constant REWARD_THRESHOLD u1000)

(define-map user-rewards
    { user-id: (string-utf8 36) }
    { points: uint }
)

(define-public (claim-reward (user-id (string-utf8 36)))
    (let (
        (user-points (default-to u0 (get points (map-get? user-rewards { user-id: user-id }))))
    )
    (if (>= user-points REWARD_THRESHOLD)
        (ok true)
        (err ERR_INSUFFICIENT_POINTS)
    ))
)

# contracts/rust/game_logic/lib.rs
use std::collections::HashMap;

pub struct GameState {
    pub user_progress: HashMap<String, UserProgress>,
}

pub struct UserProgress {
    pub level: u32,
    pub points: u32,
    pub completed_lessons: Vec<u32>,
}

impl GameState {
    pub fn new() -> Self {
        GameState {
            user_progress: HashMap::new(),
        }
    }

    pub fn update_progress(&mut self, user_id: String, lesson_id: u32, points: u32) -> Result<(), String> {
        let progress = self.user_progress.entry(user_id).or_insert(UserProgress {
            level: 1,
            points: 0,
            completed_lessons: Vec::new(),
        });

        progress.points += points;
        progress.completed_lessons.push(lesson_id);

        Ok(())
    }
}

# requirements.txt
flask==2.0.1
flask-cors==3.0.10
python-dotenv==0.19.0
pytest==6.2.5
black==21.9b0