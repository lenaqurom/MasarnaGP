import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    Key? key,
    required this.isActive,
  }) : super(key: key);
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 2),
                        height: 4,
                        width: isActive ? 20 : 0,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 39, 26, 99),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      );
  }
}
