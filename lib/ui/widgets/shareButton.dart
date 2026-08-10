import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,),
        child: Icon(
          Icons.share_outlined,
          size: 15,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
