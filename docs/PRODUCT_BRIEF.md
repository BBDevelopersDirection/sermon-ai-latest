# Sermon AI - Product Brief

## Project Overview

Sermon AI is a Christian-focused video streaming platform that combines the engaging format of Instagram Reels with the comprehensive content of YouTube. The app serves as a dedicated platform for Christians to discover, watch, and engage with sermons from their favorite pastors in both short-form and long-form video formats.

## Target Audience

- **Primary**: Christians seeking spiritual content and sermons
- **Secondary**: Religious content consumers interested in short-form video content
- **Demographics**: Users who prefer mobile-first video consumption with both quick access to highlights and deep-dive sermon experiences

## Primary Benefits & Features

### Core Features
1. **Sermon Reels**: Short-form video content (similar to Instagram Reels) featuring sermon highlights and key messages
2. **Full Video Sermons**: Complete sermon videos for comprehensive spiritual learning
3. **Seamless Content Integration**: All full sermons are automatically segmented into digestible reels
4. **"Watch Full Video" Feature**: Direct access to complete sermons from reel content
5. **Subscription-based Access**: Premium paywall for unlimited access to both reels and full videos

### Key Benefits
- **Quick Spiritual Nourishment**: Access to sermon highlights in bite-sized formats
- **Deep Spiritual Growth**: Full sermon access for comprehensive study
- **Curated Christian Content**: Focused platform without secular distractions
- **Mobile-Optimized Experience**: Designed for on-the-go spiritual consumption
- **Pastor Discovery**: Easy access to sermons from favorite Christian leaders

## High-Level Tech/Architecture

### Technology Stack
- **Frontend**: Flutter (cross-platform mobile app)
- **Backend**: Firebase ecosystem
  - Firestore for data storage
  - Firebase Authentication for user management
  - Firebase Analytics for user insights
  - Firebase Crashlytics for error monitoring
- **Payment Processing**: Razorpay integration
- **Video Management**: Custom video player with offline caching
- **State Management**: Flutter BLoC pattern

### Architecture Highlights
- **Offline-First Design**: Firebase Firestore with offline persistence enabled
- **Real-time Data**: Stream-based data fetching for live content updates
- **Modular Structure**: Separate management services for videos, reels, users, and transactions
- **Analytics Integration**: Comprehensive tracking with Firebase Analytics and Amplitude
- **Push Notifications**: Firebase Cloud Messaging for content updates

### Data Structure
- **Reels Collection**: Short-form sermon segments with links to full videos
- **Videos Collection**: Complete sermon content organized by sections/categories
- **User Management**: Authentication, subscription status, and preferences
- **Transaction Management**: Payment processing and subscription tracking

The platform is designed to scale efficiently while maintaining a smooth user experience across both content formats, ensuring Christians can access spiritual content in their preferred consumption style.
