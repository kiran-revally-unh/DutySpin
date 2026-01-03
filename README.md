DutySpin

DutySpin is a simple utility app for managing shared chores using turn-based responsibility.
It answers one question only:

Who’s responsible right now?

This project is intentionally minimal and focused on fairness, not productivity.

⸻

What DutySpin Does
	•	Allows users to sign in using email or phone OTP (no passwords)
	•	Lets users create or join a room (e.g. an apartment or shared house)
	•	Supports adding roommates and shared chores
	•	Each chore follows a rotation order
	•	Only one person is responsible at a time
	•	When a chore is marked Done, responsibility automatically moves to the next person
	•	Shows users only what they need to do today

⸻

Core Principles
	•	Calm and neutral UX
	•	No reminders spam
	•	No chat or messaging
	•	No gamification, scores, or leaderboards
	•	No productivity pressure

DutySpin is inspired by the simplicity of living.

⸻

App Flow (Functional Overview)
	1.	User opens the app and logs in via OTP (email or phone)
	2.	New users create or join a room
	3.	Users add roommates and chores
	4.	Home screen shows:
	•	Chores that are the user’s turn today
	•	Shared chores the user is involved in
	5.	User marks a chore as done
	6.	The system automatically rotates the turn

⸻

Chore Types
	•	Rotating chores
One owner at a time, rotates on completion (e.g. trash, dishes)
	•	Shared chores
Multiple participants, no single owner (e.g. house cleaning)

⸻

What DutySpin Does Not Do
	•	No task management features
	•	No payments or bill splitting
	•	No messaging or social feed
	•	No reminders or nudging
	•	No performance tracking

⸻

Tech Stack
	•	Frontend: (add your framework here — Flutter / React Native / etc.)
	•	Backend: Firebase
	•	Authentication: Firebase OTP (Email & Phone)
	•	Database: Firestore

⸻

Status

Work in progress — V1 focused on core turn-based chore tracking.
