import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/core/widgets/onbording_ui_view.dart';
import 'package:todouapp/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class OnbordingPage extends StatefulWidget {
  const OnbordingPage({Key? key}) : super(key: key);

  @override
  State<OnbordingPage> createState() => _OnbordingPageState();
}

class _OnbordingPageState extends State<OnbordingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingBloc>(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(backgroundColor: Colors.black, body: OnbordingUiView()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
