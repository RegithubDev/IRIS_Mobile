import 'package:flutter/material.dart';

class AthenticationLoader extends StatelessWidget {
  const AthenticationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
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
                child: const Text("Please Wait.\nAuthentication In Progress..",
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
