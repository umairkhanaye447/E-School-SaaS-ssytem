import 'package:eschool/utils/labelKeys.dart';

//database urls
//Please add your admin panel url here and make sure you do not add '/' at the end of the url
// const String baseUrl = "https://eschool-saas.wrteam.me";

const String baseUrl = "https://vslearn.com";

/// Prefixed onto every endpoint in [Api], so changing [baseUrl] above is the
/// only edit needed to repoint the whole app.
const String databaseUrl = "$baseUrl/api/";

// Reverb WebSocket configuration
const String reverbUrl =
    "ws://stage-eschool-saas.wrteam.net:9090/app/e2mhe9gu4tb2x2vkncxa";

//error message display duration
const Duration errorMessageDisplayDuration = Duration(milliseconds: 3000);

// Reverb reconnect base delay (used with exponential backoff)
const Duration reverbReconnectDelay = Duration(seconds: 3);

//home menu bottom sheet animation duration
const Duration homeMenuBottomSheetAnimationDuration = Duration(
  milliseconds: 300,
);

//Change slider duration
const Duration changeSliderDuration = Duration(seconds: 5);

//Number of latest notices to show in home container
const int numberOfLatestNoticesInHomeScreen = 3;

//Number of online classes to show in the home/student-details container
//(the "View All" button leads to the full timetable)
const int numberOfOnlineClassesInHomeScreen = 3;

//Maximum characters to show in announcement description before "Read More"
const int maxAnnouncementDescriptionLength = 100;

//notification channel keys
const String notificationChannelKey = "basic_channel";

// //to enable and disable default credentials in login page
//Off for the live build: users type their own credentials. Flip to true only
//against a demo panel whose accounts match the values below.
const bool showDefaultCredentials = false;

//Demo credentials, kept for local testing against a demo panel. These are
//WRTeam demo accounts and do NOT exist on the live vslearn backend.
// const String defaultStudentGRNumber = "2022-2312509";
// const String defaultStudentPassword = "22112006";
// const String defaultParentEmail = "AmberMWayt@gustr.com";
// const String defaultParentPassword = "8200727077";
// const String defaultSchoolCode = "SCH202412";
const String defaultStudentGRNumber = "";
const String defaultStudentPassword = "";
const String defaultParentEmail = "";
const String defaultParentPassword = "";
const String defaultSchoolCode = "";

/// When [true], screenshots and screen recording are blocked on
/// sensitive screens (Online Exam, Payment WebView).
/// Set to [false] to disable screen protection.
const bool isScreenProtectionEnabled = true;

//animations configuration
//if this is false all item appearance animations will be turned off
const bool isApplicationItemAnimationOn = true;
//note: do not add Milliseconds values less then 10 as it'll result in errors
const int listItemAnimationDelayInMilliseconds = 100;
const int itemFadeAnimationDurationInMilliseconds = 250;
const int itemZoomAnimationDurationInMilliseconds = 200;
const int itemBouncScaleAnimationDurationInMilliseconds = 200;
const double appContentHorizontalPadding = 15.0;
double bottomsheetBorderRadius = 15.0;
double topPaddingOfErrorAndLoadingContainer = 150;

String getExamStatusTypeKey(String examStatus) {
  if (examStatus == "0") {
    return upComingKey;
  }
  if (examStatus == "1") {
    return onGoingKey;
  }
  return completedKey;
}

List<String> examFilters = [allExamsKey, upComingKey, onGoingKey, completedKey];

int getExamStatusBasedOnFilterKey({required String examFilter}) {
  ///[Exam status: 0- Upcoming, 1-On Going, 2-Completed, 3-All Details]
  if (examFilter == upComingKey) {
    return 0;
  }

  if (examFilter == onGoingKey) {
    return 1;
  }

  if (examFilter == completedKey) {
    return 2;
  }

  return 3;
}

const int minimumPasswordLength = 6;

const String stripePaymentMethodKey = "Stripe";
const String razorpayPaymentMethodKey = "Razorpay";
const String flutterwavePaymentMethodKey = "Flutterwave";
const String paystackPaymentMethodKey = "Paystack";

///[Payment transaction status this must be in sync with backend]
const String pendingTransactionStatusKey = "pending";
const String failedTransactionStatusKey = "failed";
const String succeedTransactionStatusKey = "succeed";

List<String> months = [
  januaryKey,
  februaryKey,
  marchKey,
  aprilKey,
  mayKey,
  juneKey,
  julyKey,
  augustKey,
  septemberKey,
  octoberKey,
  novemberKey,
  decemberKey,
];

/// Transport Report Issue Label Keys
const List<String> transportReportIssueLabelKeys = [
  unsafeDrivingKey,
  unauthorizedPersonKey,
  missedPickupKey,
  uncleanBusInteriorKey,
  busBreakdownKey,
];
