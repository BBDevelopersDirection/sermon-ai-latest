# Sermon AI - Project Overview

## **Project Description**

Sermon AI is a Christian-focused video streaming platform that combines Instagram Reels format with YouTube-style comprehensive content. The app serves Christians seeking spiritual content through both short-form sermon highlights and full-length sermon videos, with a freemium subscription model.

## **Core Features**

### **Content Types**
- **Sermon Reels**: Short-form video content (Instagram Reels style) featuring sermon highlights and key messages
- **Full Video Sermons**: Complete sermon videos for comprehensive spiritual learning
- **Seamless Integration**: All full sermons automatically segmented into digestible reels
- **"Watch Full Video" Feature**: Direct access to complete sermons from reel content

### **Subscription Model**
- **Freemium Access**: Users can watch 2 reels for free
- **Premium Subscription**: Unlimited access to both reels and full videos after subscription
- **7-Day Trial**: Optional free trial period for new users
- **Razorpay Integration**: Secure payment processing for subscriptions

### **User Experience**
- **Quick Spiritual Nourishment**: Bite-sized sermon highlights for busy Christians
- **Deep Spiritual Growth**: Full sermon access for comprehensive study
- **Curated Christian Content**: Focused platform without secular distractions
- **Mobile-Optimized**: Designed for on-the-go spiritual consumption
- **Pastor Discovery**: Easy access to sermons from favorite Christian leaders

## **Technical Stack**

### **Frontend**
- **Framework**: Flutter (Cross-platform mobile app)
- **State Management**: BLoC Pattern with Cubit
- **UI Components**: Material Design with custom theming
- **Video Player**: Custom implementation with Flick Video Player
- **Navigation**: Bottom navigation with PageView

### **Backend & Services**
- **Database**: Firebase Firestore with offline persistence
- **Authentication**: Firebase Authentication with OTP
- **Analytics**: Firebase Analytics + Amplitude
- **Push Notifications**: Firebase Cloud Messaging
- **Payment Processing**: Razorpay integration
- **Crash Reporting**: Firebase Crashlytics

### **Local Storage**
- **Hive**: Complex data storage (user preferences, cached content)
- **SharedPreferences**: Simple key-value storage (settings, tokens)

## **Architecture Overview**

### **State Management Pattern**
- **BLoC Pattern**: Used throughout the app for state management
- **Cubit Files**: `*_cubit.dart` - Business logic and state management
- **State Files**: `*_state.dart` - State definitions with Equatable
- **Screen Files**: `*_screen.dart` - UI components with BlocBuilder/BlocListener

### **Service Layer Architecture**
- **Firebase Services**: Organized by feature (user, video, reels, subscription, etc.)
- **Local Storage**: Hive for complex data, SharedPreferences for simple key-value
- **Network Layer**: Dio client with centralized configuration
- **Analytics**: Centralized analytics service with Firebase and Amplitude

### **Data Flow**
1. **User Authentication**: Firebase Auth → User Model → Local Storage
2. **Content Loading**: Firestore → BLoC → UI State
3. **Subscription**: Razorpay → Backend API → Firestore → Local State
4. **Video Streaming**: Network → Video Player → Analytics Tracking

## **Key Business Logic**

### **Subscription Validation**
- Users can watch 2 reels for free
- After 2 reels, paywall is triggered
- Subscription status checked against Firestore
- Trial period validation with network time sync

### **Content Access Control**
- Free users: Limited to 2 reels
- Subscribed users: Unlimited access to all content
- Offline persistence for subscribed content
- Real-time subscription status updates

### **Video Management**
- Automatic reel generation from full videos
- Seamless transition between reel and full video
- Video caching for offline viewing
- Analytics tracking for engagement metrics

## **Development Guidelines**

### **Code Organization**
- **Feature-based grouping**: Related functionality grouped together
- **Separation of concerns**: Clear separation between UI, business logic, and data
- **Reusability**: Common components extracted to `reusable/` folder
- **Consistency**: Follow established patterns throughout the codebase

### **Performance Considerations**
- **Offline-first design**: Firebase Firestore with offline persistence
- **Video optimization**: Efficient video loading and caching
- **Memory management**: Proper disposal of controllers and streams
- **Network optimization**: Dio client with timeout and retry logic

### **Security & Privacy**
- **Firebase Security Rules**: User-based access control
- **Payment Security**: Razorpay secure payment processing
- **Data Validation**: Input sanitization and validation
- **Authentication**: Secure OTP-based authentication flow

## **Deployment & Distribution**

### **Platform Support**
- **Android**: Google Play Store with signed APK
- **iOS**: App Store (when implemented)
- **Build Configuration**: Separate debug/production configurations

### **Monitoring & Analytics**
- **User Engagement**: Track spiritual content consumption
- **Subscription Metrics**: Monitor conversion rates and retention
- **Performance**: Video streaming and app performance monitoring
- **Error Tracking**: Firebase Crashlytics for error monitoring

## **Future Roadmap**

### **Planned Features**
- **Social Features**: Sharing and community engagement
- **Content Discovery**: Advanced search and recommendation
- **Offline Downloads**: Download content for offline viewing
- **Multi-language Support**: Localization for global reach

### **Technical Improvements**
- **Performance Optimization**: Enhanced video streaming
- **UI/UX Enhancements**: Improved user experience
- **Analytics Enhancement**: Deeper insights into user behavior
- **Security Updates**: Regular security patches and updates

---

*This documentation serves as the primary reference for understanding the Sermon AI project architecture, features, and development guidelines.*
