🧠 NeuraLens

Hybrid AI-Powered Assistive Vision System for Visually Impaired Individuals

NeuraLens is an AI-powered assistive application designed to enhance environmental awareness for visually impaired individuals through real-time visual understanding and audio feedback.

The system introduces a Hybrid AI Architecture, supporting both:

Offline Mode (Local AI Model) for low-latency, privacy-preserving tasks

Online Mode (Cloud-based Gemini Vision AI) for advanced reasoning and intelligent scene understanding

NeuraLens is designed for mobile devices and experimental wearable hardware such as Raspberry Pi–based smart glasses.

🚀 Project Vision

Traditional assistive tools provide limited environmental intelligence. NeuraLens aims to:

Enable independent navigation

Provide real-time object detection

Offer intelligent scene understanding

Work with or without internet connectivity

Ensure privacy, accessibility, and reliability

✨ Key Features
🔁 Dual AI Operation Modes
📴 Offline Mode – Local AI

Runs directly on device / edge hardware

No internet required

Faster response time

Privacy-focused processing

Suitable for:

Basic object detection

Obstacle awareness

Navigation assistance

🌐 Online Mode – Gemini Vision AI

Uses Google Gemini 1.5 Flash Vision API

Requires internet connection

Advanced reasoning and contextual understanding

Suitable for:

Detailed scene descriptions

Complex object relationships

Context-based user queries

📸 Vision Capabilities

Image capture from mobile camera or Raspberry Pi camera

Scene description

Object listing

Context-aware prompts

🔊 Audio Feedback

Converts AI output into natural speech

Hands-free user interaction

Designed for accessibility-first experience

👓 Wearable Hardware Integration (Experimental)

Raspberry Pi

Camera module mounted on glasses

Wireless communication with mobile app

Edge AI inference for offline mode

🛠️ Technology Stack
📱 Frontend (Mobile App)

Flutter (Dart)

Camera integration

Text-to-Speech (TTS)

Network handling

Mode switching (Offline / Online)

🧠 AI & Machine Learning
Offline AI

Lightweight local vision model

Runs on:

Mobile device OR

Raspberry Pi (Edge AI)

Optimized for real-time inference

Online AI

Google Gemini Vision API

Image-to-text generative inference

Intelligent contextual responses

🌐 Backend (Online Mode Only)

Node.js

Express.js

Axios

Hosted on Render

Secures AI API keys

Handles image payloads and requests