import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgButton extends StatelessWidget {
  final Function onTap;
  final Color? buttonColor;
  final String svgIconUrl;
  final double? width;
  final double? height;

  const SvgButton({
    Key? key,
    this.width,
    this.height,
    required this.onTap,
    this.buttonColor,
    required this.svgIconUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
      },
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        height: height ?? 25,
        width: width ?? 25,
        child: SvgPicture.asset(
          svgIconUrl,
          //Defaulted to the page colour back when these sat on the blue
          //header; the header is light now, so the glyph must be dark.
          colorFilter: ColorFilter.mode(
            buttonColor ?? AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
