class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class IssueCategory {
  final String id;
  final String label;

  const IssueCategory(this.id, this.label);
}

const List<IssueCategory> kIssueCategories = [
  IssueCategory('order', 'Order related issue'),
  IssueCategory('payment', 'Payment / refund issue'),
  IssueCategory('delivery', 'Delivery issue'),
  IssueCategory('app', 'App bug / crash'),
  IssueCategory('other', 'Other'),
];
