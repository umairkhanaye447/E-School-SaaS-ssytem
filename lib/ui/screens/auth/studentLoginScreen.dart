import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/resetPasswordRequestCubit.dart';
import 'package:eschool/cubits/signInCubit.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/ui/screens/auth/widgets/requestResetPasswordBottomsheet.dart';
import 'package:eschool/ui/screens/auth/widgets/termsAndConditionAndPrivacyPolicyContainer.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/ui/widgets/passwordHideShowButton.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/unauthenticatedAccessManager.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTheme.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({Key? key}) : super(key: key);

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();

  static Widget routeInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInCubit>(
          create: (_) => SignInCubit(AuthRepository()),
        ),
      ],
      child: const StudentLoginScreen(),
    );
  }
}

class _StudentLoginScreenState extends State<StudentLoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  late final Animation<double> _patterntAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ),
  );

  late final Animation<double> _formAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ),
  );

  final TextEditingController _grNumberTextEditingController =
      TextEditingController(
          text: showDefaultCredentials
              ? defaultStudentGRNumber
              : null); //default grNumber

  final TextEditingController _passwordTextEditingController =
      TextEditingController(
          text: showDefaultCredentials
              ? defaultStudentPassword
              : null); //default password

  final _schoolCodeController = TextEditingController(
    text: showDefaultCredentials ? defaultSchoolCode : null,
  );

  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _grNumberTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  void _signInStudent() {
    if (_schoolCodeController.text.trim().isEmpty) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(
          Utils.getTranslatedLabel("pleaseEnterSchoolCode"),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_grNumberTextEditingController.text.trim().isEmpty) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseEnterGRNumberKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_passwordTextEditingController.text.trim().isEmpty) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseEnterPasswordKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    context.read<SignInCubit>().signInUser(
          userId: _grNumberTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
          schoolCode: _schoolCodeController.text.trim(),
          isStudentLogin: true,
        );
  }

  Widget _buildRequestResetPasswordContainer() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GestureDetector(
          onTap: () {
            Utils.showBottomSheet(
              child: BlocProvider(
                create: (_) => RequestResetPasswordCubit(AuthRepository()),
                child: const RequestResetPasswordBottomsheet(),
              ),
              context: context,
            ).then((value) {
              if (value != null && !value['error']) {
                Utils.showCustomSnackBar(
                  context: context,
                  errorMessage: Utils.getTranslatedLabel(
                    passwordResetRequestKey,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                );
              }
            });
          },
          child: Text(
            "${Utils.getTranslatedLabel(resetPasswordKey)}?",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpperPattern() {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: FadeTransition(
        opacity: _patterntAnimation,
        child: SlideTransition(
          position: _patterntAnimation.drive(
            Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero),
          ),
          child: SvgPicture.asset(
            Utils.getImagePath("upper_pattern.svg"),
          ),
        ),
      ),
    );
  }

  Widget _buildLowerPattern() {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: FadeTransition(
        opacity: _patterntAnimation,
        child: SlideTransition(
          position: _patterntAnimation.drive(
            Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
          ),
          child: SvgPicture.asset(
            Utils.getImagePath("lower_pattern.svg"),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Align(
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _formAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ), //to make UI scrollable when keyboard is opened
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: NotificationListener(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * (0.075),
                  right: MediaQuery.of(context).size.width * (0.075),
                  top: MediaQuery.of(context).size.height * (0.17),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Utils.getTranslatedLabel(letsSignInKey),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "${Utils.getTranslatedLabel(welcomeBackKey)}, \n${Utils.getTranslatedLabel(youHaveBeenMissedKey)}",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                    ),

                    /// School code field
                    const SizedBox(height: AppSpacing.xl),
                    CustomTextFieldContainer(
                      hideText: false,
                      hintTextKey: Utils.getTranslatedLabel("schoolCode"),
                      bottomPadding: 0,
                      prefixIcon: Icons.school_outlined,
                      textEditingController: _schoolCodeController,
                    ),

                    /// GR number field
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextFieldContainer(
                      hideText: false,
                      hintTextKey: grNumberKey,
                      bottomPadding: 0,
                      prefixIcon: Icons.person_outline_rounded,
                      textEditingController: _grNumberTextEditingController,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextFieldContainer(
                      textEditingController: _passwordTextEditingController,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixWidget: PasswordHideShowButton(
                        hidePassword: _hidePassword,
                        onTap: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                      hideText: _hidePassword,
                      hintTextKey: passwordKey,
                      bottomPadding: 0,
                    ),
                    _buildRequestResetPasswordContainer(),
                    const SizedBox(height: 30.0),
                    Center(
                      child: BlocConsumer<SignInCubit, SignInState>(
                        listener: (context, state) {
                          if (state is SignInSuccess) {
                            //
                            context.read<AuthCubit>().authenticateUser(
                                  schoolCode: state.schoolCode,
                                  jwtToken: state.jwtToken,
                                  isStudent: state.isStudentLogIn,
                                  parent: state.parent,
                                  student: state.student,
                                );

                            // Unblock API calls after re-authentication
                            UnauthenticatedAccessManager()
                                .onUserAuthenticated();

                            // Check if user was redirected here due to 401
                            final lastRoute =
                                UnauthenticatedAccessManager().lastRoute;
                            if (lastRoute != null &&
                                lastRoute != Routes.auth &&
                                lastRoute != Routes.studentLogin &&
                                lastRoute != Routes.parentLogin) {
                              UnauthenticatedAccessManager().clearLastRoute();
                              Get.offNamedUntil(
                                lastRoute,
                                (_) => false,
                              );
                            } else {
                              UnauthenticatedAccessManager().clearLastRoute();
                              Get.offNamedUntil(Routes.studentOnbording,
                                  (Route<dynamic> route) => false);
                            }
                          } else if (state is SignInFailure) {
                            Utils.showCustomSnackBar(
                              context: context,
                              errorMessage:
                                  Utils.getTranslatedLabel(state.errorMessage),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            );
                          }
                        },
                        builder: (context, state) {
                          //Brand-gradient CTA with a soft blue glow so the
                          //Sign In action is unmistakably the primary step.
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: context.brand.heroGradient,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.32),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -6,
                                ),
                              ],
                            ),
                            child: CustomRoundedButton(
                              onTap: () {
                                if (state is SignInInProgress) {
                                  return;
                                }
                                FocusScope.of(context).unfocus();

                                _signInStudent();
                              },
                              widthPercentage: 0.8,
                              backgroundColor: Colors.transparent,
                              buttonTitle: Utils.getTranslatedLabel(signInKey),
                              titleColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              showBorder: false,
                              child: state is SignInInProgress
                                  ? const CustomCircularProgressIndicator(
                                      strokeWidth: 2,
                                      widthAndHeight: 20,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    BlocBuilder<SignInCubit, SignInState>(
                      builder: (context, state) {
                        return Center(
                          child: InkWell(
                            onTap: () {
                              if (state is SignInInProgress) {
                                return;
                              }
                              Get.offNamed(Routes.parentLogin);
                            },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                      color:
                                          Utils.getColorScheme(context).primary,
                                    ),
                                    text: Utils.getTranslatedLabel(
                                      loginAsKey,
                                    ),
                                  ),
                                  const TextSpan(text: " "),
                                  TextSpan(
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Utils.getColorScheme(context)
                                          .secondary,
                                    ),
                                    text:
                                        "${Utils.getTranslatedLabel(parentKey)}?",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const TermsAndConditionAndPrivacyPolicyContainer(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //to aboide the lower pattern from hiding login form when keyboard is open
      body: Stack(
        children: [
          _buildLowerPattern(),
          _buildUpperPattern(),
          _buildLoginForm(),
        ],
      ),
    );
  }
}
