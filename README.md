<p align="center">
  <h1 align="center">🧹 DutySpin</h1>
  <p align="center"><b>Minimal turn-based chore tracking for shared living.</b></p>
  <p align="center">
    <a href="https://dutyspin.web.app/"><b>🌐 Live App</b></a>
    &nbsp;•&nbsp;
    <a href="#-app-screenshots"><b>📸 Screenshots</b></a>
    &nbsp;•&nbsp;
    <a href="#-tech-stack"><b>🛠 Tech Stack</b></a>
    &nbsp;•&nbsp;
    <a href="#-status"><b>🚧 Status</b></a>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Platform-Web%20App-informational" />
    <img src="https://img.shields.io/badge/Frontend-Flutter-blue" />
    <img src="https://img.shields.io/badge/Backend-Firebase-orange" />
    <img src="https://img.shields.io/badge/Auth-OTP%20(Email%20%2B%20Phone)-success" />
  </p>
</p>

---

## 🧠 The Idea

DutySpin is a minimal utility app for managing shared chores using a simple **turn-based responsibility** model.

It answers one question:

> **Who’s responsible right now?**

Built for **fairness and clarity** — not productivity hacks, notifications, or gamification.

---

## ✨ What DutySpin Does

- Sign in using **email or phone OTP** (no passwords)
- Create or join a **shared room** (apartment, house, etc.)
- Add **roommates** and **shared chores**
- Assign chores with a clear **rotation order**
- Ensure **one person is responsible at a time**
- When a chore is marked **Done**, responsibility automatically rotates
- Show users **only what they need to handle today**

---

## 🧭 Core Principles

DutySpin is designed around simplicity and calm:

- Calm, neutral UX  
- No reminder spam  
- No chat or messaging  
- No gamification, scores, or leaderboards  
- No productivity pressure  

**Goal:** reduce friction — not add noise.

---

## 🔄 App Flow

1. User opens the app and logs in via OTP (email or phone)
2. New users create or join a room
3. Users add roommates and chores
4. Home screen shows:
   - Chores that are the user’s responsibility today
   - Shared chores the user participates in
5. User marks a chore as **Done**
6. Responsibility automatically rotates to the next person

---

## 🧺 Chore Types

### Rotating Chores
- One owner at a time  
- Responsibility rotates on completion  
- Examples: trash, dishes  

### Shared Chores
- Multiple participants  
- No single owner  
- Examples: general house cleaning  

---

## 🚫 What DutySpin Does *Not* Do

- No task management features  
- No payments or bill splitting  
- No messaging or social feed  
- No reminders or nudging  
- No performance tracking  

This is by design.

---

## 📸 App Screenshots

<p align="center">
  <img
    src="https://github.com/user-attachments/assets/dd16144a-9bc4-443a-bbce-e72446e51134"
    width="210"
    style="border-radius: 14px; box-shadow: 0 12px 24px rgba(0,0,0,0.18);"
  />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img
    src="https://github.com/user-attachments/assets/bea67d0d-8fce-4523-85f1-eceeb4394292"
    width="210"
    style="border-radius: 14px; box-shadow: 0 12px 24px rgba(0,0,0,0.18);"
  />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img
    src="https://github.com/user-attachments/assets/ec911ae8-e9d7-4e4f-ab6f-20edaf81a90e"
    width="210"
    style="border-radius: 14px; box-shadow: 0 12px 24px rgba(0,0,0,0.18);"
  />
</p>

<br/>

<p align="center">
  <img
    src="https://github.com/user-attachments/assets/7d3e5b04-1c6e-4917-8ea9-7b977bda8f2b"
    width="210"
    style="border-radius: 14px; box-shadow: 0 12px 24px rgba(0,0,0,0.18);"
  />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img
    src="https://github.com/user-attachments/assets/9d5fb3a2-76c9-4a43-8d0f-26670d54181a"
    width="210"
    style="border-radius: 14px; box-shadow: 0 12px 24px rgba(0,0,0,0.18);"
  />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img
    src="https://github.com/user-attachments/assets/6521fafd-4dd2-4e5d-a4a1-faaef8f30aef"
    width="210"
    style="border-radius: 14px; box-shadow: 0 12px 24px rgba(0,0,0,0.18);"
  />
</p>

---

## 🛠 Tech Stack

- **Frontend:** Flutter  
- **Backend:** Firebase  
- **Authentication:** Firebase OTP (Email & Phone)  
- **Database:** Firestore  

---

## 🚧 Status

**Work in progress.**  
V1 is focused on delivering a stable, simple, turn-based chore tracking experience.
