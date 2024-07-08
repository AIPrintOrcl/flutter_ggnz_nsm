import 'package:flutter/material.dart';

class ButtonHealth extends StatelessWidget {
  final String healthState;
  const ButtonHealth({Key? key, required this.healthState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), color: Colors.white),
      width: 150,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Image.asset("assets/heart.png",
          //     height: 25,
          //     color: healthState == HealthState.Bad.name
          //         ? Colors.grey
          //         : healthState == HealthState.Normal.name
          //             ? Colors.pinkAccent.withOpacity(0.7)
          //             : null),
          const Spacer(),
          Text(
            healthState,
            style: const TextStyle(
                fontSize: 10, color: Colors.black, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
