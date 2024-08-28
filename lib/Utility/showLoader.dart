import 'package:flutter/material.dart';

class ShowLoader extends StatelessWidget {
  ShowLoader();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        key: const ValueKey('showLoader'),
        content: Row(
          children: [
            const SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 5),
                child: const Text(
                    "Please Wait.\nWhile We Fetch Latest Information..",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'ARIAL',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ))),
          ],
        ),
      ),
    );
  }
}
