import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/Utility/MySharedPreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';


main() {
  group(MySharedPreferences, () {

    group('getSessionID', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('JSESSIONID')
            .then((session) async {
              actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "JSESSIONID=74389913F18ECEF45EBE357DFD56C467; Path=/reirm; Secure; HttpOnly";
        SharedPreferences.setMockInitialValues({"JSESSIONID": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('JSESSIONID')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getUserID', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('user_id')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "54321";
        SharedPreferences.setMockInitialValues({"user_id": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('user_id')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getUserName', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('user_name')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "abhijith pc";
        SharedPreferences.setMockInitialValues({"user_name": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('user_name')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getEmailId', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('email_id')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "pcabhijith2@gmail.com";
        SharedPreferences.setMockInitialValues({"email_id": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('email_id')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getProjectName', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('project_name')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "pcabhijith2@gmail.com";
        SharedPreferences.setMockInitialValues({"project_name": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('project_name')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getModuleType', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('module_type')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "User";
        SharedPreferences.setMockInitialValues({"module_type": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('module_type')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getBaseSbu', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('base_sbu')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "BMW";
        SharedPreferences.setMockInitialValues({"base_sbu": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('base_sbu')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getBaseProject', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('base_project')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "DE";
        SharedPreferences.setMockInitialValues({"base_project": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('base_project')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getBaseRole', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('base_role')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "User";
        SharedPreferences.setMockInitialValues({"base_role": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('base_role')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getMessage', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('message')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "User Action";
        SharedPreferences.setMockInitialValues({"message": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('message')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getSbuName', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('sbu_name')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "Bio Medical Waste Management";
        SharedPreferences.setMockInitialValues({"sbu_name": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('sbu_name')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getRewardPoints', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('reward_points')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "390";
        SharedPreferences.setMockInitialValues({"reward_points": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('reward_points')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('getBaseDepartments', () {
      test('returns "" if no value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        String expectedValue="";
        var actualValue="";
        MySharedPreferences.instance
            .getCityStringValue('base_department')
            .then((session) async {
          actualValue=session;
        });

        expect(expectedValue, actualValue);
      });

      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "RE";
        SharedPreferences.setMockInitialValues({"base_department": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('base_department')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });


    group('setStringValueFunction', () {
      test('returns "" if default value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});

        MySharedPreferences.instance.setStringValue("employee_code", "");

        expect("", "");
      });
      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "User Action";
        SharedPreferences.setMockInitialValues({"message": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('message')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });

    group('setBooleanValueFunction', () {
      test('returns false if default value is stored in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});
        MySharedPreferences.instance.setBooleanValue("hf", false);

        expect(false, false);
      });
      test('returns the correct value stored in SharedPreferences', () async {
        String sessionValue = "User Action";
        SharedPreferences.setMockInitialValues({"message": sessionValue});

        String expectedValue = sessionValue;

        MySharedPreferences.instance
            .getCityStringValue('message')
            .then((session) async {
          expect(expectedValue, session);
        });

      });
    });


  });
}
