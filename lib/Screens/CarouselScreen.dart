import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../Utility/utils/constants.dart';
import 'login/login_page.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  _CarouselScreenState createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 5.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0XFFE00000) : Colors.black38,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            key: const ValueKey('carouselcontainer1'),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: PageView(
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            key: const ValueKey('carouselcontainer2'),
                            margin: EdgeInsets.only(
                                top: 0.0, bottom: height / 3.8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(0.0, 1.0),
                                colors: <Color>[
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.01),
                                  Colors.white,
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/reduce_text.png',
                                        height: 60,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Lorem ipsum dolor sit ",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'ARIAL'),
                                      ),
                                      const Text(
                                        "amet, consectetur adipiscing",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'ARIAL'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 100,
                                  ),
                                  Image.asset(
                                    'assets/images/reduce_logo.png',
                                    height: 300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            key: const ValueKey('carouselcontainer3'),
                            margin: EdgeInsets.only(
                                top: 0.0, bottom: height / 3.8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(0.0, 1.0),
                                // stops: [0.0, 1.0],
                                colors: <Color>[
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.01),
                                  Colors.white,
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/Reuse_text.png',
                                        height: 80,
                                      ),
                                      const Text(
                                        "Lorem ipsum dolor sit ",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'ARIAL'),
                                      ),
                                      const Text(
                                        "amet, consectetur adipiscing",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'ARIAL'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 100,
                                  ),
                                  Image.asset(
                                    'assets/images/reuse_logo.png',
                                    height: 300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            key: const ValueKey('carouselcontainer4'),
                            margin: EdgeInsets.only(
                                top: 0.0, bottom: height / 3.8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(0.0, 1.0),
                                // stops: [0.0, 1.0],
                                colors: <Color>[
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.01),
                                  Colors.white,
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/recycle_text.png',
                                        height: 60,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Lorem ipsum dolor sit ",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'ARIAL'),
                                      ),
                                      const Text(
                                        "amet, consectetur adipiscing",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            fontFamily: 'ARIAL'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 100,
                                  ),
                                  Image.asset(
                                    'assets/images/recycle_logo.png',
                                    height: 300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: FractionalOffset.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 70.0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ),
                ),
                _currentPage != _numPages - 1
                    ? Align(
                        alignment: FractionalOffset.bottomRight,
                        child: TextButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: const Text("")),
                      )
                    : const Text(''),
              ],
            ),
          ),
        ),
        bottomSheet: _currentPage == _numPages - 1
            ? InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      )
                      .then((value) => setState(() {}));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 28.0, left: 25, right: 25),
                  child: Container(
                    key: const ValueKey('carouselcontainer6'),
                    height: 50.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: FractionalOffset(1.0, 0.0),
                        end: FractionalOffset(0.0, 1.0),
                        // stops: [0.0, 1.0],
                        colors: <Color>[
                          kReSustainabilityRed,
                          kReSustainabilityRed
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                      color: kReSustainabilityRed,
                    ),
                    child: const Center(
                        child: Text(
                      "Get Started",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "ARIAL",
                          letterSpacing: 1.5),
                    )),
                  ),
                ),
              )
            : const Text(''),
      ),
    );
  }
}
