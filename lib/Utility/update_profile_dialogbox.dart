import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:sizer/sizer.dart';

class UpdateProfileDialogBox extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? positivePress;
  final VoidCallback? negativePress;

  const UpdateProfileDialogBox(
      {super.key,
      required this.title,
      required this.message,
      required this.positivePress,
      required this.negativePress});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            child: SizedBox(
              height: 25.h,
              width: 100.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: kColorDark,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 1.h,
                        ),
                        Text(message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: kColorDark,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  GestureDetector(
                    onTap: positivePress,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kWhite,
                          border: Border.all(
                            color: kReSustainabilityRed,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      height: 4.h,
                      width: 40.w,
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: kReSustainabilityRed,
                            fontSize: 12.sp,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: negativePress,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kWhite,
                          border: Border.all(
                            color: kReSustainabilityRed,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      height: 4.h,
                      width: 40.w,
                      child: Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: kReSustainabilityRed,
                            fontSize: 12.sp,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 5,
                  )
                ],
              ),
            )));
  }
}
