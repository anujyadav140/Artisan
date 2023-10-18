import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ArtisanListItem extends StatelessWidget {
  const ArtisanListItem(
      {super.key,
      required this.onNavigate,
      required this.asset,
      required this.artisanListItemName});
  final VoidCallback onNavigate;
  final String asset;
  final String artisanListItemName;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    bool isLessThan960() {
      if (w < 960) {
        return true;
      } else {
        return false;
      }
    }

    return GestureDetector(
      onTap: onNavigate,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: kIsWeb
                  ? isLessThan960()
                      ? w * 0.1
                      : w * 0.04
                  : w * 0.1,
              backgroundImage: AssetImage(asset),
            ),
            const SizedBox(width: 16.0),
            Text(
              artisanListItemName,
              style: TextStyle(
                  fontFamily: "NexaBold",
                  color: Colors.blue,
                  fontSize: kIsWeb
                      ? isLessThan960()
                          ? w / 25
                          : 25
                      : w / 25),
            ),
          ],
        ),
      ),
    );
  }
}
