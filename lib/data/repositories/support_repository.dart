import '../../models/support_model.dart';

class SupportRepository {
  Future<List<FaqItem>> fetchFaqs({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (simulateError) throw Exception('Unable to load FAQs');
    return [
      FaqItem(
          question: 'How do I track my order?',
          answer:
              'Go to Your Orders > Active tab and tap on your order to see the live timeline.'),
      FaqItem(
          question: 'What is GoFresh Money?',
          answer:
              'GoFresh Money is your in-app wallet where cashback and refunds are credited for faster checkout.'),
      FaqItem(
          question: 'How do I cancel an order?',
          answer:
              'Open the order from Your Orders > Active, then tap Cancel Order before it is packed.'),
      FaqItem(
          question: 'How long does delivery take?',
          answer:
              'Most orders are delivered within 10-15 minutes depending on your location.'),
      FaqItem(
          question: 'How do I get a refund?',
          answer:
              'Refunds for cancelled or returned orders are credited to GoFresh Money within 24 hours.'),
    ];
  }

  Future<void> submitIssue({
    required String categoryId,
    required String description,
    String? screenshotPath,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock submission — always succeeds. Wire to real API here later.
  }
}
