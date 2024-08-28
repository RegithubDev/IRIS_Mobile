import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';

class GPSDialog extends StatelessWidget {
  const GPSDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        key: const ValueKey('Enable GPS'),
        backgroundColor: kReSustainabilityRed,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        content: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: 35,
                    color: kReSustainabilityRed,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Enable GPS!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: "ARIAL",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                " Please Enable GPS",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: "ARIAL",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFffffff),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text("OK",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kReSustainabilityRed,
                      fontFamily: "ARIAL",
                    )),
                onPressed: () {
                  const AndroidIntent intent = AndroidIntent(
                      action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                  intent.launch();

                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
