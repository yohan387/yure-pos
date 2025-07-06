import 'package:flutter/material.dart';
import 'package:todouapp/core/widgets/onbording_ui_view.dart';

class OnbordingPage extends StatefulWidget {
  const OnbordingPage({Key? key}) : super(key: key);

  @override
  State<OnbordingPage> createState() => _OnbordingPageState();
}

class _OnbordingPageState extends State<OnbordingPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(backgroundColor: Colors.black, body: OnbordingUiView()),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
