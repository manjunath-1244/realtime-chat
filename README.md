Realtime Chat Application

A real-time chat application built with Ruby on Rails 7. The application supports user authentication, multi-user chat rooms, and live messaging using ActionCable, Turbo Streams, and Stimulus without page refresh.

------------------------------------------------------------

Features

- User authentication using Devise
- Multi-user chat rooms
- Real-time messaging with ActionCable (WebSockets)
- Turbo Stream broadcasting
- Automatic message alignment (sent/received)
- No page refresh required
- Clean MVC architecture

------------------------------------------------------------

Tech Stack

- Ruby on Rails 7
- Devise
- ActionCable
- Turbo (Hotwire)
- Stimulus
- PostgreSQL / SQLite (Development)

------------------------------------------------------------

Setup Instructions

1. Clone the repository

git clone https://github.com/manjunath-1244/realtime-chat.git
cd realtime-chat

2. Install dependencies

bundle install

3. Setup database

rails db:create
rails db:migrate

4. Start the server

rails s

Open in browser:
http://localhost:3000

------------------------------------------------------------

ActionCable Configuration

In config/cable.yml

Development:

development:
  adapter: async

Production (Recommended):

production:
  adapter: redis
  url: redis://localhost:6379/1

------------------------------------------------------------

How It Works

1. User sends a message
2. Message is saved in the database
3. Model broadcasts via Turbo Stream
4. All connected users receive updates instantly
5. Stimulus handles message alignment dynamically

------------------------------------------------------------

Authentication

Authentication is handled using Devise:
- User Registration
- Login / Logout
- Secure session management

------------------------------------------------------------

Future Improvements

- Typing indicators
- Read receipts
- Online presence tracking
- Message editing and deleting with real-time updates
- Production deployment with Redis

------------------------------------------------------------

Author

Manjunath
GitHub: https://github.com/manjunath-1244
```
