import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/telegram_config.dart';
import '../../data/models/telegram_auth_request_model.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

/// Haqiqiy Telegram Login Widget — mijoz/00-kirish-va-profil.md §1-2.
/// `TelegramConfig.botUsername` to'ldirilgach ishga tushadi.
class TelegramWebviewLoginScreen extends StatefulWidget {
  const TelegramWebviewLoginScreen({super.key});

  @override
  State<TelegramWebviewLoginScreen> createState() => _TelegramWebviewLoginScreenState();
}

class _TelegramWebviewLoginScreenState extends State<TelegramWebviewLoginScreen> {
  static const _timeout = Duration(seconds: 12);

  late WebViewController _controller;
  bool _isPageLoading = true;
  bool _timedOut = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _startTimeoutWatch();
  }

  WebViewController _buildController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('FlutterTelegramAuth', onMessageReceived: _onAuthMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isPageLoading = false);
          },
          onWebResourceError: (error) {
            // Statik sahifaning o'zi (Telegram skripti emas) yuklanmasa —
            // odatda internet yo'qligi. Widget ichidagi xatoni (masalan
            // "Username invalid") tashqi WebView bu orqali bilolmaydi,
            // chunki u alohida domendagi iframe — shuning uchun asosiy
            // himoya pastdagi taymer.
            if (mounted) {
              setState(() {
                _isPageLoading = false;
                _timedOut = true;
              });
            }
          },
        ),
      )
      ..loadHtmlString(_widgetHtml, baseUrl: TelegramConfig.widgetOriginUrl);
  }

  void _startTimeoutWatch() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeout, () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  void _retry() {
    setState(() {
      _timedOut = false;
      _isPageLoading = true;
      _controller = _buildController();
    });
    _startTimeoutWatch();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _onAuthMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final result = TelegramAuthRequestModel(
        id: (data['id'] as num).toInt(),
        firstName: data['first_name'] as String?,
        lastName: data['last_name'] as String?,
        username: data['username'] as String?,
        photoUrl: data['photo_url'] as String?,
        authDate: (data['auth_date'] as num?)?.toInt(),
        hash: data['hash'] as String?,
      );
      _timeoutTimer?.cancel();
      if (mounted) Navigator.pop(context, result);
    } catch (_) {
      // Yaroqsiz javob — foydalanuvchi qayta urinishi mumkin.
    }
  }

  String get _widgetHtml => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { margin: 0; display: flex; align-items: center; justify-content: center;
           height: 100vh; font-family: sans-serif; background: #ffffff; }
  </style>
</head>
<body>
  <script async src="https://telegram.org/js/telegram-widget.js?22"
    data-telegram-login="${TelegramConfig.botUsername}"
    data-size="large"
    data-radius="14"
    data-onauth="onTelegramAuth(user)"
    data-request-access="write"></script>
  <script>
    function onTelegramAuth(user) {
      FlutterTelegramAuth.postMessage(JSON.stringify(user));
    }
  </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconCloseLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Telegram orqali kirish'),
        centerTitle: true,
      ),
      body: _timedOut ? _buildTimeoutError() : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isPageLoading) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildTimeoutError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(AppAssets.iconErrorWarningLine, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Telegram tugmasi ko\'rinmadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bot (@${TelegramConfig.botUsername}) yoki uning domen sozlamasi bilan bog\'liq muammo bo\'lishi mumkin — bu ilova kodiga emas, Telegram tomonidagi @BotFather sozlamasiga bog\'liq.',
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Qayta urinish'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Yopish'),
            ),
          ],
        ),
      ),
    );
  }
}
