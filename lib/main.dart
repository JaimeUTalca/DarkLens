import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui' as ui;

List<CameraDescription> cameras = [];
bool hasAcceptedDisclaimer = false;

// --- DICCIONARIO DE TRADUCCIONES (i18n) ---
final Map<String, Map<String, String>> _localizedStrings = {
  'en': {
    'title': 'Terms & Ethical Use',
    'body': 'The DarkLens app is designed strictly for personal security, journalism, and ethical documentation.\n\nUsing this app to record individuals without their explicit consent may violate strict local, state, or national privacy laws.\n\nThe developer and creators of DarkLens expressly disclaim all legal, civil, and criminal liability arising from the misuse of this tool.\n\nIMPORTANT MANDATORY SAFEGUARDS:\n\n1. Ensure you are fully aware of and comply with audio/video recording laws in your region (e.g., one-party or two-party consent laws).\n2. It is strictly prohibited to use this app in areas with a reasonable expectation of privacy (e.g., restrooms, changing rooms, private property).\n3. Never use this app for harassment, defamation, espionage, or any other illicit or immoral purpose.\n\nBy tapping "ACCEPT", you declare that you are of legal age, will obey all applicable laws, and assume full, exclusive, and absolute responsibility for your recording actions.',
    'accept': 'ACCEPT AND CONTINUE',
    'reject': 'REJECT AND EXIT',
    'rear': 'REAR',
    'front': 'FRONT',
  },
  'es': {
    'title': 'Términos y Uso Ético',
    'body': 'La aplicación DarkLens ha sido diseñada exclusivamente para fines de seguridad personal, periodismo ciudadano y documentación ética.\n\nEl uso de esta aplicación para grabar a personas sin su consentimiento puede violar estrictas leyes de privacidad locales, estatales o nacionales.\n\nEl desarrollador y los creadores de DarkLens se desligan legal, penal y civilmente de cualquier responsabilidad derivada del mal uso de esta herramienta.\n\nRESGUARDOS IMPORTANTES OBLIGATORIOS:\n\n1. Asegúrate de conocer y acatar plenamente las leyes de grabación de audio y video de tu país (ej. leyes de consentimiento de una o dos partes).\n2. Queda estrictamente prohibido utilizar esta aplicación en áreas donde exista una expectativa razonable de privacidad (ej. baños, vestidores, propiedad privada ajena).\n3. Nunca utilices esta aplicación para realizar actos de acoso, difamación, espionaje o cualquier otro propósito de naturaleza ilícita o inmoral.\n\nAl pulsar "ACEPTAR", declaras que eres mayor de edad, que cumplirás con las leyes aplicables y asumes la total, exclusiva y absoluta responsabilidad de tus actos de grabación.',
    'accept': 'ACEPTAR Y CONTINUAR',
    'reject': 'RECHAZAR Y SALIR',
    'rear': 'PRINCIPAL',
    'front': 'FRONTAL',
  },
};

String _t(String key) {
  // Obtener el idioma nativo del teléfono
  String languageCode = ui.PlatformDispatcher.instance.locale.languageCode;
  
  // Si el teléfono no está en español, el inglés será el idioma de fábrica/universal
  if (languageCode != 'es') {
    languageCode = 'en';
  }
  
  return _localizedStrings[languageCode]?[key] ?? key;
}
// ------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error getting cameras: $e');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    hasAcceptedDisclaimer = prefs.getBool('accepted_disclaimer') ?? false;
  } catch (e) {
    print('Error getting preferences: $e');
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
      home: hasAcceptedDisclaimer ? const MainDarkVideoScreen() : const DisclaimerScreen(),
    );
  }
}

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _t('title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _t('body'),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('accepted_disclaimer', true);
                    } catch(e) {
                      print('Error saving: $e');
                    }

                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainDarkVideoScreen(),
                      ),
                    );
                  },
                  child: Text(
                    _t('accept'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () {
                    // Cerrar la app
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text(
                    _t('reject'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      ? 'ca-app-pub-4566173049235624/3975499794' // Real Android Ad
      : 'ca-app-pub-4566173049235624/3975499794'; // Real iOS Ad

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
        print('Video guardado en la galería (Álbum DarkLens)');
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
              title: _t('rear'),
              icon: Icons.camera_rear,
              color: Colors.red.shade700,
              onTap: () => _startRecording(CameraLensDirection.back),
            ),
            const SizedBox(height: 60),
            _buildCameraButton(
              title: _t('front'),
              icon: Icons.camera_front,
              color: Colors.indigo.shade600,
              onTap: () => _startRecording(CameraLensDirection.front),
            ),
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
