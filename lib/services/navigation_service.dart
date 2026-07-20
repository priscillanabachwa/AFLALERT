import 'package:flutter/material.dart';

/// Global navigator key so services outside the widget tree (e.g. the local
/// notification tap handler) can push routes without a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
