import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error getting cameras: $e');
  }
  runApp(const DarkVideoApp());
}

class DarkVideoApp extends StatelessWidget {
  const DarkVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DarkLens',
      theme: ThemeData.dark(),
      home: const MainDarkVideoScreen(),
    );
  }
}

class MainDarkVideoScreen extends StatefulWidget {
  const MainDarkVideoScreen({super.key});

  @override
  State<MainDarkVideoScreen> createState() => _MainDarkVideoScreenState();
}

class _MainDarkVideoScreenState extends State<MainDarkVideoScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isRecording = false;
  bool _isStopping = false;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final String _adUnitId = Platform.isAndroid 
      ? 'ca-app-pub-3940256099942544/6300978111' // Test Android Ad
      : 'ca-app-pub-3940256099942544/2934735716'; // Test iOS Ad

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          print('Ad failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_isRecording && !_isStopping) {
        _stopRecording();
      }
    }
  }

  Future<void> _startRecording(CameraLensDirection direction) async {
    if (_isRecording || _isStopping) return;

    setState(() {
      _isRecording = true;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    try {
      if (cameras.isEmpty) return;
      
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == direction, 
        orElse: () => cameras.first
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true, 
      );

      await _cameraController!.initialize();
      
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (e) {
        print('Ignorando error de flash: $e');
      }

      await _cameraController!.startVideoRecording();
      
    } catch (e) {
      print('Error starting recording: $e');
      await _stopRecording();
    }
  }

  Future<void> _stopRecording() async {
    if (_isStopping) return;
    _isStopping = true;

    final controller = _cameraController;
    _cameraController = null;

    if (controller == null) {
      _resetUI();
      _isStopping = false;
      return;
    }

    try {
      if (controller.value.isRecordingVideo) {
        final XFile videoFile = await controller.stopVideoRecording();
        await Gal.putVideo(videoFile.path, album: 'DarkLens');
        print('Video guardado en la galería');
      }
    } catch (e) {
      print('Error stopping recording: $e');
    } finally {
      try {
        await controller.dispose();
      } catch (e) {
        print('Error disposing camera: $e');
      }
      
      _resetUI();
      _isStopping = false;
    }
  }

  void _resetUI() {
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCameraButton(
              title: 'PRINCIPAL',
              icon: Icons.camera_rear,
              color: Colors.red.shade700,
              onTap: () => _startRecording(CameraLensDirection.back),
            ),
            const SizedBox(height: 60),
            _buildCameraButton(
              title: 'FRONTAL',
              icon: Icons.camera_front,
              color: Colors.indigo.shade600,
              onTap: () => _startRecording(CameraLensDirection.front),
            ),
            // Banner re-ubicado debajo de los botones principales
            if (_isAdLoaded && _bannerAd != null) ...[
              const SizedBox(height: 80), // Espacio largo para que no estorbe
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
