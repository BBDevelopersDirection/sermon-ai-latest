# Sermon AI - Video System Documentation

## **Overview**

The Sermon AI video system implements a dual-content approach with short-form reels and full-length videos. The system provides seamless navigation between content types, efficient video streaming, and comprehensive analytics tracking.

## **Content Architecture**

### **Content Types**

1. **Sermon Reels**
   - Short-form video content (Instagram Reels style)
   - Sermon highlights and key messages
   - Vertical video format optimized for mobile
   - Auto-looping playback

2. **Full Video Sermons**
   - Complete sermon videos
   - Comprehensive spiritual content
   - Horizontal video format
   - Full video player controls

3. **Content Integration**
   - Each reel links to its corresponding full video
   - Seamless transition between content types
   - Unified content management system

### **Data Models**

#### **Reels Model**
```dart
class ReelsModel {
  final String id;                    // Unique reel identifier
  final String videoId;               // Associated full video ID
  final String fullVideoLink;         // URL to full video
  final String reelLink;              // URL to reel video
  final String category;              // Content category
  
  // Serialization methods
  factory ReelsModel.fromMap(Map<String, dynamic> data);
  Map<String, dynamic> toMap();
}
```

#### **Video Data Model**
```dart
class VideoDataModel {
  final String id;                    // Video identifier
  final String title;                 // Video title
  final String description;           // Video description
  final String videoUrl;              // Video URL
  final String thumbnailUrl;          // Thumbnail URL
  final String category;              // Content category
  final DateTime createdAt;           // Creation timestamp
  final int duration;                 // Video duration in seconds
  final List<String> tags;            // Content tags
}
```

## **Video Player Implementation**

### **Reels Video Player**

```dart
class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;
  final int index;
  final Function(int, VideoPlayerController) onControllerReady;
  
  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showPlayPause = false;
  
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reelsModel.reelLink)
    )..initialize().then((_) {
      if (mounted) setState(() {});
      widget.onControllerReady(widget.index, _controller);
    })..setLooping(true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### **Full Video Player**

```dart
class VideoPlayerUsingId extends StatefulWidget {
  final String url;
  final String? title;
  final String? description;
  
  const VideoPlayerUsingId({
    Key? key,
    required this.url,
    this.title,
    this.description,
  }) : super(key: key);
  
  @override
  State<VideoPlayerUsingId> createState() => _VideoPlayerUsingIdState();
}

class _VideoPlayerUsingIdState extends State<VideoPlayerUsingId> {
  late FlickManager _flickManager;
  
  @override
  void initState() {
    super.initState();
    _flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      ),
    );
  }
  
  @override
  void dispose() {
    _flickManager.dispose();
    super.dispose();
  }
}
```

## **Video Management System**

### **Controller Management**

```dart
class _BottomNavZeroScreenState extends State<BottomNavZeroScreen> {
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentPage = 0;
  int _maxFreeIndex = 1;
  
  // Register video controller
  void _registerController(int index, VideoPlayerController controller) {
    _controllers[index] = controller;
    if (index == _currentPage) {
      controller.play();
    } else {
      controller.pause();
    }
  }
  
  // Pause specific controller
  void _pauseController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.pause();
    }
  }
  
  // Play specific controller
  void _playController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.play();
    }
  }
  
  // Handle page scroll
  void _onScroll() {
    final page = _pageController.page ?? 0.0;
    final newPage = page.round();
    
    if (newPage != _currentPage) {
      _pauseController(_currentPage);
      _playController(newPage);
      _currentPage = newPage;
    }
  }
}
```

### **Memory Management**

```dart
@override
void dispose() {
  _pageController.dispose();
  _cubit.close();
  
  // Dispose all video controllers
  for (final c in _controllers.values) {
    c.dispose();
  }
  
  // Restore system UI
  WakelockPlus.disable();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  super.dispose();
}
```

## **Content Loading & Caching**

### **Reels Loading**

```dart
class BottomNavZeroCubit extends Cubit<BottomNavZeroState> {
  final ReelsFirestoreFunctions _firestoreFunctions;
  
  BottomNavZeroCubit({required ReelsFirestoreFunctions firestoreFunctions})
      : _firestoreFunctions = firestoreFunctions,
        super(BottomNavZeroInitial());
  
  Future<void> fetchReels({bool loadMore = false}) async {
    if (loadMore) {
      emit(state.copyWith(isLoadingMore: true));
    } else {
      emit(BottomNavZeroLoading());
    }
    
    try {
      final reels = await _firestoreFunctions.getReels(
        limit: 10,
        lastDocument: loadMore ? state.lastDocument : null,
      );
      
      emit(state.copyWith(
        reels: loadMore ? [...state.reels, ...reels] : reels,
        isLoading: false,
        isLoadingMore: false,
        hasMore: reels.length == 10,
        lastDocument: reels.isNotEmpty ? reels.last : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      ));
    }
  }
}
```

### **Firestore Integration**

```dart
class ReelsFirestoreFunctions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get reels with pagination
  Future<List<ReelsModel>> getReels({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(FirestoreVariables.reelsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ReelsModel.fromMap(data);
      }).toList();
    } catch (e) {
      AppLogger.e('Error fetching reels: $e');
      return [];
    }
  }
  
  // Get single reel by ID
  Future<ReelsModel?> getReelById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirestoreVariables.reelsCollection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ReelsModel.fromMap(data);
      }
      return null;
    } catch (e) {
      AppLogger.e('Error fetching reel: $e');
      return null;
    }
  }
}
```

## **User Interface Components**

### **Reels Screen Layout**

```dart
class BottomNavZeroScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<BottomNavZeroCubit, BottomNavZeroState>(
        builder: (context, state) {
          if (state.isLoading && state.reels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.reels.isEmpty) {
            return const Center(
              child: Text(
                "No Reels Found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: state.reels.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final reel = state.reels[index];
              return ReelVideoPlayer(
                reelsModel: reel,
                index: index,
                onControllerReady: _registerController,
              );
            },
          );
        },
      ),
    );
  }
}
```

### **Video Player UI**

```dart
@override
Widget build(BuildContext context) {
  if (!_controller.value.isInitialized) {
    return const Center(child: CircularProgressIndicator());
  }
  
  return GestureDetector(
    onTap: _togglePlayPause,
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Background video
        FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        
        // Play/Pause overlay
        if (_showPlayPause)
          Center(
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 70,
            ),
          ),
        
        // Watch full sermon button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildWatchFullVideoButton(),
        ),
      ],
    ),
  );
}
```

### **Watch Full Video Button**

```dart
Widget _buildWatchFullVideoButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GestureDetector(
      onTap: () async {
        // Log analytics event
        await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().watch_full_video_reel,
        );
        
        // Pause current video
        _controller.pause();
        
        // Navigate to full video
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPlayerUsingId(
              url: widget.reelsModel.fullVideoLink,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: ShapeDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Watch Full Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ),
  );
}
```

## **Analytics Integration**

### **Video Engagement Tracking**

```dart
class VideoAnalytics {
  // Track reel watch
  static void logReelWatched(String reelId, String category) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().reel_watched,
      parameters: {
        'reel_id': reelId,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track full video watch
  static void logFullVideoWatched(String videoId, String category) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().watch_full_video_reel,
      parameters: {
        'video_id': videoId,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track video completion
  static void logVideoCompletion(String videoId, double completionRate) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'video_completion',
      parameters: {
        'video_id': videoId,
        'completion_rate': completionRate,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
```

### **Analytics Events**

```dart
class LogEventsName {
  // Video engagement events
  static String reel_watched = 'reel_watched';
  static String watch_full_video_reel = 'watch_full_video_reel';
  static String video_completion = 'video_completion';
  
  // User interaction events
  static String video_play = 'video_play';
  static String video_pause = 'video_pause';
  static String video_seek = 'video_seek';
}
```

## **Performance Optimization**

### **Video Loading Strategy**

1. **Lazy Loading**: Videos load only when they become visible
2. **Preloading**: Preload next video for smooth transitions
3. **Memory Management**: Dispose unused controllers
4. **Caching**: Cache video metadata and thumbnails

### **Network Optimization**

```dart
class VideoNetworkManager {
  // Configure video player for optimal streaming
  static VideoPlayerController createOptimizedController(String url) {
    return VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );
  }
  
  // Implement retry logic for failed loads
  static Future<void> loadVideoWithRetry(
    VideoPlayerController controller,
    {int maxRetries = 3}
  ) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        await controller.initialize();
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw e;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }
}
```

### **Memory Management**

```dart
class VideoMemoryManager {
  static const int maxControllers = 5;
  static final Map<String, VideoPlayerController> _controllers = {};
  
  // Get or create controller
  static VideoPlayerController getController(String url) {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }
    
    // Clean up old controllers if limit reached
    if (_controllers.length >= maxControllers) {
      final oldestKey = _controllers.keys.first;
      _controllers[oldestKey]?.dispose();
      _controllers.remove(oldestKey);
    }
    
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[url] = controller;
    return controller;
  }
  
  // Dispose all controllers
  static void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}
```

## **Error Handling**

### **Video Loading Errors**

```dart
class VideoErrorHandler {
  static void handleVideoError(String url, dynamic error) {
    AppLogger.e('Video loading error for $url: $error');
    
    // Log error to analytics
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'video_load_error',
      parameters: {
        'video_url': url,
        'error_message': error.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    // Show user-friendly error message
    // Implementation depends on UI context
  }
  
  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## **Offline Support**

### **Video Caching**

```dart
class VideoCacheManager {
  static final FlutterCacheManager _cacheManager = DefaultCacheManager();
  
  // Cache video for offline viewing
  static Future<void> cacheVideo(String url) async {
    try {
      await _cacheManager.downloadFile(url);
      AppLogger.d('Video cached successfully: $url');
    } catch (e) {
      AppLogger.e('Failed to cache video: $e');
    }
  }
  
  // Check if video is cached
  static Future<bool> isVideoCached(String url) async {
    final file = await _cacheManager.getSingleFile(url);
    return await file.exists();
  }
  
  // Get cached video file
  static Future<File> getCachedVideo(String url) async {
    return await _cacheManager.getSingleFile(url);
  }
}
```

## **Testing Strategy**

### **Unit Tests**

```dart
group('Video System', () {
  test('should create video controller correctly', () {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse('https://example.com/video.mp4')
    );
    expect(controller, isNotNull);
  });
  
  test('should parse reels model correctly', () {
    final data = {
      'id': 'test_id',
      'videoId': 'video_id',
      'fullVideoLink': 'https://example.com/full.mp4',
      'reelLink': 'https://example.com/reel.mp4',
      'category': 'sermon',
    };
    
    final reel = ReelsModel.fromMap(data);
    expect(reel.id, 'test_id');
    expect(reel.category, 'sermon');
  });
});
```

### **Integration Tests**

1. **Video Loading**: Test video loading and initialization
2. **Controller Management**: Test controller lifecycle management
3. **Navigation**: Test navigation between reels and full videos
4. **Analytics**: Test analytics event tracking
5. **Error Handling**: Test error scenarios and recovery

---

*This video system documentation provides comprehensive details about the dual-content architecture, video player implementation, and performance optimization strategies in Sermon AI.*
