import 'package:flutter/material.dart';

import '../../domain/usecases/set_offline_usecase.dart';
import '../../domain/usecases/set_online_usecase.dart';

class PresenceWrapper extends StatefulWidget {
  const PresenceWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<PresenceWrapper> createState() => _PresenceWrapperState();
}

class _PresenceWrapperState extends State<PresenceWrapper>
    with WidgetsBindingObserver {
  DateTime _lastSent = DateTime.now();

  void _onUserActivity() {
    final now = DateTime.now();
    if (now.difference(_lastSent) > const Duration(seconds: 45)) {
      _lastSent = now;
      SetOnlineUseCase().setOnline();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SetOnlineUseCase().setOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SetOfflineUseCase().setOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        SetOnlineUseCase().setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        SetOfflineUseCase().setOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserActivity(),
      onPointerUp: (_) => _onUserActivity(),
      child: widget.child,
    );
  }
}
