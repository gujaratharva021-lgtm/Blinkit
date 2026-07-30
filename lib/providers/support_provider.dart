import 'package:flutter/material.dart';
import '../data/repositories/support_repository.dart';
import '../models/support_model.dart';

enum LoadStatus { initial, loading, loaded, error }
enum SubmitStatus { idle, submitting, success, error }

class SupportProvider extends ChangeNotifier {
  final SupportRepository _repo = SupportRepository();

  List<FaqItem> faqs = [];
  LoadStatus faqStatus = LoadStatus.initial;
  String? faqError;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitError;

  Future<void> loadFaqs() async {
    faqStatus = LoadStatus.loading;
    notifyListeners();
    try {
      faqs = await _repo.fetchFaqs();
      faqStatus = LoadStatus.loaded;
    } catch (e) {
      faqStatus = LoadStatus.error;
      faqError = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> submitIssue({
    required String categoryId,
    required String description,
    String? screenshotPath,
  }) async {
    submitStatus = SubmitStatus.submitting;
    notifyListeners();
    try {
      await _repo.submitIssue(
          categoryId: categoryId, description: description, screenshotPath: screenshotPath);
      submitStatus = SubmitStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      submitStatus = SubmitStatus.error;
      submitError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void resetSubmit() {
    submitStatus = SubmitStatus.idle;
    notifyListeners();
  }
}
