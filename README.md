# DarkLens (Stealth Video Recorder)

**DarkLens** (previamente "Dark Video") es una aplicación desarrollada en Flutter diseñada exclusivamente para fines de seguridad personal, periodismo ciudadano y documentación ética. 

Su propósito central es permitir la grabación de videos de forma segura, silenciosa y visualmente indetectable, protegiendo al usuario ante situaciones de emergencia.

## 🚀 Características Principales

* **Grabación Sigilosa (Pantalla Oscura):** Al iniciar la grabación, la pantalla del dispositivo se vuelve inmediatamente de color negro profundo. Se activa el Modo Inmersivo de Android, ocultando la barra de estado y la botonera de navegación para evitar cualquier distracción luminosa.
* **Soporte Multi-Cámara:** Cuenta con una interfaz intuitiva con dos botones grandes (Rojo y Azul) para seleccionar entre la cámara **Principal (Trasera)** o la cámara **Frontal (Selfie)** de forma rápida y sin mirar.
* **Manejo Inteligente de Hardware (Sin Punto Verde):** 
  * A diferencia de otras aplicaciones, DarkLens **no** inicializa la cámara al abrir la app. Sólo la activa durante la grabación.
  * Al terminar de grabar (presionando el botón físico de apagado/bloqueo de pantalla), la instancia de la cámara se destruye automáticamente en una milésima de segundo, borrando instantáneamente el indicador de "punto verde" nativo de privacidad de Android/iOS en segundo plano.
* **Guardado Directo en Galería:** Utiliza el paquete `gal` para inyectar transparentemente el archivo `.mp4` resultante a la Galería pública de tu teléfono tan pronto terminas de grabar, sin necesitar que mantengas la pantalla encendida.
* **Protección Legal (Disclaimer):** Integración de un robusto aviso de Términos y Uso Ético inicial. El usuario está obligado a aceptar las condiciones legales de privacidad y consentimiento de su país antes de acceder a la cámara, desligando al creador de cualquier mal uso.

## 🛠️ Tecnologías y Dependencias

Este proyecto está construido en **Flutter** (Dart), y hace uso de las siguientes librerías principales:
- [`camera`](https://pub.dev/packages/camera): Para capturar el flujo de video y controlar el flash.
- [`gal`](https://pub.dev/packages/gal): Para el guardado nativo y permisos de la galería del teléfono.
- [`google_mobile_ads`](https://pub.dev/packages/google_mobile_ads): (Opcional/Removido) Preparado para monetización con AdMob.

## 📦 Instalación

Puedes clonar este repositorio y compilar el APK usando el ecosistema de Flutter:

```bash
# Clonar el proyecto
git clone git@github.com:JaimeUTalca/DarkLens.git

# Entrar al directorio
cd DarkLens

# Descargar las extensiones
flutter pub get

# Compilar para Android (APK)
flutter build apk --release
```
El instalador generado se encontrará en `build/app/outputs/flutter-apk/app-release.apk`.

## ⚖️ Descargo de Responsabilidad Legal
El uso de esta aplicación para grabar a personas sin su consentimiento puede violar estrictas leyes de privacidad locales, estatales o nacionales. El código se provee "tal cual" (AS-IS) y el desarrollador se desliga legal, penal y civilmente de cualquier responsabilidad derivada del mal uso de esta herramienta. No debe ser utilizada en áreas con una expectativa razonable de privacidad (ej. baños, vestidores, propiedad privada ajena) ni para propósitos de acoso o ilícitos.
