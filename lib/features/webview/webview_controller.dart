import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../services/connectivity_service.dart';

/// Possible states the WebView screen can be in.
enum WebViewStatus {
  loading,
  loaded,
  error,
  offline,
}

/// Controller that manages the [WebViewController] lifecycle, navigation and
/// state updates for the WebView screen.
class WebViewControllerWrapper extends ChangeNotifier {
  WebViewControllerWrapper() {
    _initController();
    _listenConnectivity();
  }

  // ─── Public state ─────────────────────────────────────────────────────────
  late final WebViewController webViewController;
  WebViewStatus status = WebViewStatus.loading;
  int loadingProgress = 0;
  bool canGoBack = false;
  String? errorMessage;

  // ─── Private ──────────────────────────────────────────────────────────────
  StreamSubscription<bool>? _connectivitySub;

  // ─── Init ─────────────────────────────────────────────────────────────────
  void _initController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onProgress: _onProgress,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.baseUrl));
  }

  void _listenConnectivity() {
    _connectivitySub =
        ConnectivityService.instance.onConnectivityChanged.listen((connected) {
      if (connected && status == WebViewStatus.offline) {
        reload();
      } else if (!connected) {
        status = WebViewStatus.offline;
        notifyListeners();
      }
    });
  }

  // ─── Navigation delegate callbacks ────────────────────────────────────────
  void _onPageStarted(String url) {
    status = WebViewStatus.loading;
    loadingProgress = 0;
    notifyListeners();
  }

  void _onPageFinished(String url) {
    _updateCanGoBack();
    status = WebViewStatus.loaded;
    notifyListeners();
  }

  void _onProgress(int progress) {
    loadingProgress = progress;
    notifyListeners();
  }

  void _onWebResourceError(WebResourceError error) {
    // Ignore sub-resource errors (images, ads, etc.)
    if (error.isForMainFrame != true) return;

    errorMessage = _friendlyError(error);
    status = WebViewStatus.error;
    notifyListeners();
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.parse(request.url);

    // Always allow external scheme links to be opened in external apps (tel, mailto, etc.)
    if (AppConstants.externalSchemes.contains(uri.scheme)) {
      _launchExternal(request.url);
      return NavigationDecision.prevent;
    }

    // Allow ALL other URLs to load in the WebView (no redirect to external browser)
    return NavigationDecision.navigate;
  }

  // ─── Public actions ───────────────────────────────────────────────────────
  Future<void> reload() async {
    final connected = await ConnectivityService.instance.isConnected;
    if (!connected) {
      status = WebViewStatus.offline;
      notifyListeners();
      return;
    }
    status = WebViewStatus.loading;
    notifyListeners();
    await webViewController.reload();
  }

  Future<void> goBack() async {
    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
      _updateCanGoBack();
    }
  }

  Future<bool> handleAndroidBackButton() async {
    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
      _updateCanGoBack();
      return true; // consumed
    }
    return false; // let system handle (exit app)
  }

  Future<void> _updateCanGoBack() async {
    canGoBack = await webViewController.canGoBack();
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _friendlyError(WebResourceError error) {
    switch (error.errorCode) {
      case -2:
        return 'Cannot connect to server. Check your internet connection.';
      case -6:
        return 'Connection timed out. Please try again.';
      case -7:
        return 'The server is unreachable. Try again later.';
      default:
        return 'An error occurred while loading the page.\n(${error.description})';
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
