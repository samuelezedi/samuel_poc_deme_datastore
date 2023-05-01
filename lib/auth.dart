import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:devdeme3/confirm.dart';
import 'package:flutter/material.dart';

/// Signs a user up with a username, password, and email. The required
/// attributes may be different depending on your app's configuration.
///
class AuthClass {
  Future<void> signUpUser(
      {required String username,
      required String password,
      required String email,
      String? phoneNumber,
      VoidCallback? onConfirmCode,
      VoidCallback? onNavigateToBlogPage}) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.email: email,
        if (phoneNumber != null) AuthUserAttributeKey.phoneNumber: phoneNumber,
        // additional attributes as needed
      };
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      await _handleSignUpResult(result,
          onConfirmCode: onConfirmCode,
          doNavigateToBlogPage: onNavigateToBlogPage);
    } on AuthException catch (e) {
      safePrint('Error signing up user: ${e.message}');
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result,
      {VoidCallback? doNavigateToBlogPage, VoidCallback? onConfirmCode}) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        onConfirmCode!();
        break;
      case AuthSignUpStep.done:
        safePrint('Sign up is complete');
        doNavigateToBlogPage!();
        break;
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
    print(codeDeliveryDetails.toJson());
    safePrint(
      'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
      'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
    );
  }

  Future<void> confirmUser({
    required String username,
    required String confirmationCode,
    VoidCallback? doNavigateToBlogPage, VoidCallback? onConfirmCode
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      // Check if further confirmations are needed or if
      // the sign up is complete.
      await _handleSignUpResult(result, onConfirmCode: onConfirmCode, doNavigateToBlogPage: doNavigateToBlogPage);
    } on AuthException catch (e) {
      safePrint('Error confirming user: ${e.message}');
    }
  }

  Future<void> signInUser(String username, String password, {VoidCallback? doNavigateToBlogPage, VoidCallback? onConfirmCode}) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      await _handleSignInResult(result, username, onConfirmCode: onConfirmCode, doNavigateToBlogPage: doNavigateToBlogPage);
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
    }
  }

  Future<void> _handleSignInResult(SignInResult result, String username,
      {VoidCallback? doNavigateToBlogPage, VoidCallback? onConfirmCode}) async {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithSmsMfaCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignInStep.confirmSignInWithNewPassword:
        safePrint('Enter a new password to continue signing in');
        break;
      case AuthSignInStep.confirmSignInWithCustomChallenge:
        final parameters = result.nextStep.additionalInfo;
        final prompt = parameters['prompt']!;
        safePrint(prompt);
        break;

      case AuthSignInStep.confirmSignUp:
        // Resend the sign up code to the registered device.
        final resendResult = await Amplify.Auth.resendSignUpCode(
          username: username,
        );
        _handleCodeDelivery(resendResult.codeDeliveryDetails);
        onConfirmCode!();
        break;
      case AuthSignInStep.done:
        safePrint('Sign in is complete');
        doNavigateToBlogPage!();
        break;
    }
  }

  Future<void> signInCustom(String username, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
        options: const SignInOptions(
          pluginOptions: CognitoSignInPluginOptions(
            authFlowType: AuthenticationFlowType.customAuthWithSrp,
          ),
        ),
      );
      await _handleSignInResult(result, username);
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
    }
  }
}
