import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inventory/helper/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  SupabaseErrorHandler._();

  static String getMessage(dynamic error) {
    if (error is AuthException) {
      return _authMessage(error.message);
    }

    if (error is PostgrestException) {
      return _dbMessage(error.message);
    }

    if (error is StorageException) {
      return _storageMessage(error.message);
    }

    if (error is http.ClientException) {
      return _networkMessage(error.message);
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is String) {
      return _genericMessage(error);
    }

    final raw = error?.toString() ?? '';
    if (raw.isNotEmpty) {
      return _genericMessage(raw);
    }

    return 'Something went wrong. Please try again.';
  }

  static String _authMessage(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'Email or password is incorrect.';
    }

    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before login.';
    }

    if (msg.contains('user already registered')) {
      return 'Account already exists with this email.';
    }

    if (msg.contains('token') && msg.contains('expired')) {
      return 'Your session has expired. Please login again.';
    }

    if (msg.contains('network')) {
      return 'No internet connection. Please check your network.';
    }

    AppLogger.info(message, 'SupabaseErrorHandler');
    return 'Authentication failed. Please try again.';
  }

  static String _dbMessage(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('duplicate key') ||
        msg.contains('already exists') ||
        msg.contains(
          'duplicate key value violates unique constraint "unique_category_per_user"',
        ) ||
        msg.contains('23505')) {
      return 'This data already exists.';
    }

    if (msg.contains('permission denied') ||
        msg.contains('not allowed') ||
        msg.contains('42501')) {
      return 'You do not have permission to perform this action.';
    }

    if (msg.contains('row-level security')) {
      return 'You are not authorized for this operation.';
    }

    if (msg.contains('foreign key') || msg.contains('23503')) {
      return 'Cannot complete this action due to linked data.';
    }

    if (msg.contains('null value') || msg.contains('23502')) {
      return 'Some required fields are missing.';
    }

    if (msg.contains('violates check constraint') || msg.contains('23514')) {
      return 'Input values are invalid. Please verify and try again.';
    }

    if (msg.contains('timeout')) {
      return 'Server is taking too long to respond. Please try again.';
    }

    return 'Database request failed. Please try again.';
  }

  static String _storageMessage(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('too large')) {
      return 'File is too large. Please choose a smaller file.';
    }
    if (msg.contains('not found')) {
      return 'Requested file was not found.';
    }
    if (msg.contains('permission')) {
      return 'You do not have permission to access this file.';
    }
    return 'File upload failed. Please try again.';
  }

  static String _networkMessage(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Network error. Please try again.';
  }

  static String _genericMessage(String raw) {
    final msg = raw.toLowerCase();

    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('permission denied') || msg.contains('not authorized')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('duplicate') || msg.contains('already exists')) {
      return 'This data already exists.';
    }

    return 'Something went wrong. Please try again.';
  }
}
