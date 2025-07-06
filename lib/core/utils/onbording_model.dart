import 'package:todouapp/core/constants/onbording.dart';

class OnbordingModel {
  final String onbordingImageUrl;
  final String onbordingHeading;
  final String onbordingSubHeading;

  OnbordingModel(
      {required this.onbordingImageUrl,
      required this.onbordingHeading,
      required this.onbordingSubHeading});
}

final onbordingArrayList = [
  OnbordingModel(
      onbordingImageUrl: 'Yure POS',
      onbordingHeading: OnbordingConstants.ONBORDING_HEADING_1,
      onbordingSubHeading: OnbordingConstants.ONBORDING_DESC_1),
  OnbordingModel(
      onbordingImageUrl: 'Yure POS',
      onbordingHeading: OnbordingConstants.ONBORDING_HEADING_2,
      onbordingSubHeading: OnbordingConstants.ONBORDING_DESC_2),
  OnbordingModel(
      onbordingImageUrl: 'Yure POS',
      onbordingHeading: OnbordingConstants.ONBORDING_HEADING_3,
      onbordingSubHeading: OnbordingConstants.ONBORDING_DESC_3),
];
