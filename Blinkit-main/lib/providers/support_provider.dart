import 'package:flutter/material.dart';
import '../data/repositories/support_repository.dart';
import '../models/support_model.dart';

enum LoadStatus { initial, loading, loaded, error }

class SupportProvider extends ChangeNotifier {
  final SupportRepository _repo = SupportRepository();

  List<FaqItem> faqs = [];
  LoadStatus faqStatus = LoadStatus.initial;
  String? faqError;

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
}
