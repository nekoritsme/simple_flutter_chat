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
        print("Set online man");
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
    return widget.child;
  }
}
