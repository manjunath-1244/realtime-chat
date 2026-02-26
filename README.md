Realtime Chat Application

A production-ready real-time chat application built with Ruby on Rails 7.1 using Hotwire (Turbo Streams) for live updates without heavy frontend frameworks.

This application supports authentication, multi-user chat rooms, real-time messaging, scheduled messages, file sharing, threaded replies, pinned messages, search functionality, and compliance-ready audit logging — all implemented using clean Rails architecture.

---

## Features

### Authentication and Authorization

* User authentication using Devise
* Role-based access control (User, Admin)
* Secure login and logout
* Session management

### Real-Time Messaging

* Live messaging using ActionCable and Turbo Streams
* Instant message broadcasting
* No page refresh required
* Automatic message alignment (sent and received messages)

### Threaded Replies

* Nested replies using self-referential associations
* Structured conversation hierarchy
* Optimized eager loading to prevent N+1 queries

### Pinned Messages

* Only one pinned message per room
* Real-time pinned message updates
* Broadcast synchronization across connected users

### Scheduled Messages (Send Later)

* Schedule messages for future delivery
* Processed using Sidekiq and Redis
* Automatically published at the scheduled time

### File and Image Sharing

* Upload images and documents
* Powered by Active Storage
* Inline image rendering support

### Message Search

* Case-insensitive search using PostgreSQL ILIKE
* Protected against SQL injection using sanitize_sql_like

### Message Editing and Deleting

* Real-time update broadcasting
* Edit timestamp tracking
* Secure authorization validation

### Compliance and Audit Logging

* JSONB-based audit logging
* Tracks message creation, updates, deletions, and pin actions
* Stores before and after state snapshots
* Future-proof schema design

### Read Receipts and Reactions (Extensible)

* Structured support tables included
* Designed for future enhancements

---

## Technology Stack

* Ruby on Rails 7.1
* PostgreSQL
* Devise
* Hotwire (Turbo Streams and Stimulus)
* ActionCable
* Sidekiq
* Redis
* Active Storage

---

## Architecture Overview

The system follows a Rails-native real-time architecture:

1. A user sends a message
2. The message is saved in the database
3. A model-level callback triggers Turbo Stream broadcasting
4. All connected users receive the update instantly

Example:

```ruby
after_create_commit -> { broadcast_append_to room, target: "messages" }
after_update_commit -> { broadcast_replace_to room }
after_destroy_commit -> { broadcast_remove_to room }
```

No custom WebSocket JavaScript implementation is required.

---

## Database Structure (Core Tables)

* users
* rooms
* room_members
* messages
* audit_logs

### Message Table Fields

```ruby
t.text     :content
t.integer  :parent_id
t.boolean  :pinned, default: false
t.datetime :scheduled_for
t.datetime :published_at
t.datetime :edited_at
t.datetime :deleted_at
```

---

## Setup Instructions

### Clone the Repository

```bash
git clone https://github.com/manjunath-1244/realtime-chat.git
cd realtime-chat
```

### Install Dependencies

```bash
bundle install
```

### Setup Database

```bash
rails db:create
rails db:migrate
```

### Start Redis (Required)

```bash
redis-server
```

### Start Rails Server

```bash
rails s
```

### Start Sidekiq (For Scheduled Messages)

```bash
bundle exec sidekiq
```

Open in browser:

```
http://localhost:3000
```

---

## ActionCable Configuration

### config/cable.yml

Development:

```yaml
development:
  adapter: async
```

Production (Recommended):

```yaml
production:
  adapter: redis
  url: redis://localhost:6379/1
```

---

## Production Recommendations

* Use Redis adapter for ActionCable
* Configure Sidekiq concurrency properly
* Use AWS S3 or cloud storage for Active Storage
* Implement rate limiting
* Use Pundit for policy-based authorization
* Enable caching for performance optimization

---

## Future Improvements

* Typing indicators
* Online presence tracking
* Emoji reactions interface
* Read receipts interface
* Notification system
* Mobile responsiveness
* Docker support
* CI/CD integration

---

## What This Project Demonstrates

* Advanced Rails architecture
* Real-time WebSocket broadcasting
* Background job scheduling
* Secure audit logging with JSONB
* Scalable relational database design
* Production-ready backend engineering

This project can serve as a foundation for building:

* Messaging platforms
* Collaboration tools
* Internal communication systems
* Live dashboards

---

## Author

Manjunath
GitHub: [https://github.com/manjunath-1244](https://github.com/manjunath-1244)
