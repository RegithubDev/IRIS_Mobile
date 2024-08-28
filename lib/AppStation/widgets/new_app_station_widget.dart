import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

class NewAppStationItemWidget extends StatelessWidget {
  final void Function() onTap;
  final String image;
  final String label;

  const NewAppStationItemWidget(
      {Key? key, required this.onTap, required this.image, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: GestureDetector(
        onTap:onTap,
        child: Center(
          child: SizedBox(
            width: 312,
            height: 64,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 303,
                    height: 64,
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFFDAD3D3)),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x1E000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 288,
                  top: 20,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFE21F26),
                      shape: OvalBorder(),
                      shadows: [
                        BoxShadow(
                          color: Color(0x1E000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 280,
                  top: 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.only(
                        top: 10, left: 12, right: 10, bottom: 6),
                    // clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 2.5.h,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  top: 11,
                  child: SizedBox(
                    width: 43,
                    height: 43,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 43,
                            height: 43,
                            decoration: const ShapeDecoration(
                              color: Color(0xFFE21F26),
                              shape: OvalBorder(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 6,
                          top: 5,
                          child: SizedBox(
                            width: 31.43,
                            height: 33,
                            child: Stack(children: [
                              Center(
                                child: SvgPicture.asset('assets/icons/$image.svg',
                                    semanticsLabel: 'Acme Logo'),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 107,
                  top: 20,
                  child: Text(
                    label,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
