import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/utils/onbording_model.dart';
import 'package:todouapp/core/widgets/button_widget.dart';
import 'package:todouapp/core/widgets/onbording/onbording_dots.dart';

import '../constants/colors.dart';

class OnbordingUiView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OnbordingUiViewState();
}

class _OnbordingUiViewState extends State<OnbordingUiView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return onBordingLayout(media);
  }

  Widget onBordingLayout(Size media) => Column(
        children: [
          Flexible(
            child: PageView(
              allowImplicitScrolling: false,
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (value) {
                _currentIndex = value;
                setState(() {});
              },
              children: onbordingArrayList
                  .map(
                      (item) => buildOnboardingPage(media, item, _currentIndex))
                  .toList(),
            ),
          ),
        ],
      );

  Widget buildOnboardingPage(
      Size media, OnbordingModel item, int currentIndex) {
    return Container(
      decoration: BoxDecoration(color: primaryColor),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.8,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Text(
                  'Yure POS',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(color: Colors.white),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Form(
                    child: Column(
                      children: [
                        Container(
                          alignment: AlignmentDirectional.bottomCenter,
                          margin: EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (int i = 0;
                                  i < onbordingArrayList.length;
                                  i++)
                                if (i == currentIndex)
                                  OnbordingDots(true)
                                else
                                  OnbordingDots(false)
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.firaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Color(
                                            0xFF080808), // Couleur par défaut
                                      ),
                                      children: _buildColoredLastWord(
                                          item.onbordingHeading),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    item.onbordingSubHeading,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.firaSans(
                                        color: Color(0xFF080808),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.1),
                        CustomButton(
                            text: 'Continuer',
                            onPressed: () {
                              if (_currentIndex < 2) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.linear,
                                );
                              } else {
                                Navigator.pushNamed(
                                    context, RouteConstants.login);
                              }
                            }),
                        SizedBox(height: media.width * 0.05),
                        if (_currentIndex < 2)
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RouteConstants.login);
                            },
                            child: Text(
                              'Passer',
                              style: GoogleFonts.inter(
                                  color: Color(0xFF1C0802),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildColoredLastWord(String text) {
    final words = text.trim().split(' ');
    if (words.length == 1) {
      return [
        TextSpan(
          text: words[0],
          style: TextStyle(color: primaryColor),
        ),
      ];
    }

    final lastWord = words.removeLast();
    return [
      TextSpan(text: '${words.join(' ')} '),
      TextSpan(
        text: lastWord,
        style: TextStyle(color: primaryColor),
      ),
    ];
  }
}
