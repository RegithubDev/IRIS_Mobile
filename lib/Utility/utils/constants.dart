import 'dart:io' show Platform;
import 'package:flutter/material.dart';

const kColorBlue = Color(0xff2e83f8);
const kColorDarkBlue = Color(0xff1b3a5e);
const kColorPink = Color(0xffff748d);
const kWhite = Color(0xffffffff);

const kInputTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xffbcbcbc),
    fontWeight: FontWeight.w300,
    fontFamily: 'ARIAL');

const kColorPrimary = Color(0xff2e83f8);
const kColorPrimaryDark = Color(0xff1b3a5e);
const kColorSecondary = Color(0xffff748d);
const kColorDark = Color(0xff121212);
const kColorLight = Color(0xffEBF2F5);
const kChartBarColor = Color(0xffF94144);
const kColorRed = Color(0xffff0000);
const kReSustainabilityRed = Color(0xffe12228);
const kPrimaryLightColor = Color(0xFF3E4095);
const kGreyColor = Color(0x61000000);
const kGreyTextColor = Color(0xff8B8080);
const kGreyTitleColor = Color(0xFF696A6D);
const kLightGrayColor = Color(0xFFF7F7F7);
const kGreyTimeline = Color(0xFFD9D9D9);
const kBlueTitleColor = Color(0xFF1E69D8);
const kGreenTitleColor = Color(0xFF2A6605);
const kRecyclableTitleColor = Color(0xFF901A1A);
const kClosingStockTitleColor = Color(0xFFA513D9);
const kDateBorderColor = Color(0xff8b8080);
const kRecycleBag = Color(0xffe4b3e2);
const kRecycleGlass = Color(0xffa9ccff);
const kRecycleCardboard = Color(0xffced666);
const kRecyclePlastic= Color(0xff31cfcf);
const kColorBlack= Color(0xff000000);
const kAshBottom = Color(0xffE4B3E2);
const kAshFly = Color(0xff31CFCF);
const kAshTotal = Color(0xFF90BE6D);
const kGenStream = Color(0xFFF94144);
const kGenPowerGen = Color(0xFFd6d727);
const kGenPowerExport = Color(0xFF92CAD1);
const kGenAuxConsumption = Color(0xFF78CCB3);
const kGenPowerGenCap = Color(0xFF868686);
const kGenPlantLoadFactor= Color(0xFFe9724d);
const kRdfCombust = Color(0xFF008000);

const kSelectDropdown = Color(0xFFFECFCF);

const kSummary1  = Color(0xFFD0FBEA);
const kSummary2  = Color(0xFFF2E5FF);
const kSummary3  = Color(0xFFCAE0FF);

const kGreyDivider = Color(0xFFE7E4E4);

const kGreenDotColor = Color(0xff14b8a6);
const kOrangeDotColor = Color(0xfff59e0b);
const kVioletDotColor = Color(0xff6366f1);
const kYellowDotColor = Color(0xfffacc15);

const kPlasticGraphColor = Color(0xff31cfcf);

const kCollectionSummaryColor1 = Color(0xFFC5F1F1);
const kCollectionSummaryBorderColor1 = Color(0xFF31CFCF);

const kProcessingSummaryColor1 = Color(0xFFD4F58C);
const kProcessingSummaryBorderColor1 = Color(0xFF83B90C);
const kAutoclaveGraphColor = Color(0xFF90BE6D);

const kRecyclableSummaryColor1 = Color(0xFFFFD9BD);
const kRecyclableSummaryBorderColor1 = Color(0xFFBECC17);

const kSummarySiteSbuColor = Color(0xFFD0FBEA);

const kClosingStockSummary = Color(0xFFF7E2FF);

const kSummaryColor1 = Color(0xFFC5F1F1);
const kSummaryBorderColor1 = Color(0xFFE2EDFD);

const kSummaryColor2 = Color(0xFFD7F7C8);
const kSummaryBorderColor2 = Color(0xFFD7F7C8);

const kSummaryColor3 = Color(0xFFF7FFA1);
const kSummaryBorderColor3 = Color(0xFFBECC17);

const kSummaryColor4 = Color(0xFFD3BEFF);
const kSummaryBorderColor4 = Color(0xFF925FFF);



// const kSummaryColor2 = Color(0xFF696A6D);
// const kSummaryColor3 = Color(0xFF696A6D);
// const kSummaryColor4 = Color(0xFF696A6D);

const inactiveColor = Color(0xff8b8080);
const searchFillColor = Color(0xffd6d6d6);
const protectBackgroundColor = Color(0xfff2f3f6);

const kBottomPadding = 48.0;

const kTextStyleButton = TextStyle(
  color: kReSustainabilityRed,
  fontSize: 18,
  fontWeight: FontWeight.w500,
  fontFamily: 'ARIAL',
);

const kTextStyleSubtitle1 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  fontFamily: 'ARIAL',
);

const kTextStyleSubtitle2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  fontFamily: 'ARIAL',
);

const kTextStyleBody2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  fontFamily: 'ARIAL',
);

const kTextStyleHeadline6 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w500,
  fontFamily: 'ARIAL',
);

const REFRESH_TOKEN_KEY = 'https://oauth2.googleapis.com/token';
const BACKEND_TOKEN_KEY = 'backend_token';
const GOOGLE_ISSUER = 'https://accounts.google.com';
const GOOGLE_CLIENT_ID_IOS =
    '180023549420-laibl7g5ebqfe7lmagf0a2aflhih2g97.apps.googleusercontent.com';
const GOOGLE_REDIRECT_URI_IOS =
    'https://appmint.resustainability.com/reirm/login';
const GOOGLE_CLIENT_ID_ANDROID =
    '180023549420-laibl7g5ebqfe7lmagf0a2aflhih2g97.apps.googleusercontent.com';
const GOOGLE_REDIRECT_URI_ANDROID =
    'https://appmint.resustainability.com/reirm/login';

String clientID() {
  if (Platform.isAndroid) {
    return GOOGLE_CLIENT_ID_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_CLIENT_ID_IOS;
  }
  return '';
}

String redirectUrl() {
  if (Platform.isAndroid) {
    return GOOGLE_REDIRECT_URI_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_REDIRECT_URI_IOS;
  }
  return '';
}
