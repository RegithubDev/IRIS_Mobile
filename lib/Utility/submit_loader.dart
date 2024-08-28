import 'package:flutter/material.dart';

class SubmitLoader extends StatelessWidget {
  SubmitLoader();

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
                child: const Text("Please Wait.\nSubmission In Progress..",
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
