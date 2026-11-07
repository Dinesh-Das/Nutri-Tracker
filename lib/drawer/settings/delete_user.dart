import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/account_deletion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showAlertDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Warning"),
        content: const Text("Are you sure you want to delete account?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text("Continue"),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteCurrentAccount(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deleteCurrentAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _goToLogin(context);
    return;
  }

  try {
    await _reauthenticateForDelete(context, user);
    await AccountDeletionService().deleteAccount(
      uid: user.uid,
      deleteAuthUser: user.delete,
    );
    await GoogleSignIn().signOut();
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deleted successfully.')),
    );
    _goToLogin(context);
  } on FirebaseAuthException catch (error) {
    if (!context.mounted) return;
    final message = error.code == 'requires-recent-login'
        ? 'Please sign in again before deleting your account.'
        : error.message ?? 'Unable to delete account.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to delete account: $error')),
    );
  }
}

Future<void> _reauthenticateForDelete(BuildContext context, User user) async {
  final providerIds = user.providerData.map((provider) => provider.providerId);
  if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Google sign-in was cancelled.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
    return;
  }

  if (providerIds.contains(EmailAuthProvider.PROVIDER_ID)) {
    final password = await _promptForPassword(context);
    if (password == null || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Password confirmation is required.',
      );
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account does not have an email address.',
      );
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  }
}

Future<String?> _promptForPassword(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Confirm password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Current password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

void _goToLogin(BuildContext context) {
  context.go(AppRoutes.login);
}
