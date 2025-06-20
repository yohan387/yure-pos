import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionCardShimmer extends StatelessWidget {
  const TransactionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      title: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 12,
          width: 100,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 5),
        ),
      ),
      subtitle: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 10,
          width: 80,
          color: Colors.white,
        ),
      ),
      trailing: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 15,
          width: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}
