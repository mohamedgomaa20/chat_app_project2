import 'package:flutter/cupertino.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';

class LogoApp extends StatelessWidget {
  const LogoApp({
    super.key, this.height=145,
  });
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kLogo,
      height: height,
      color: kPrimaryColor,
    );
  }
}
