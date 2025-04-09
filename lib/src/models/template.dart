class Template {
  final int? templateId;
  final String templateName;

  Template({this.templateId, required this.templateName});

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      templateId: map['template_id'],
      templateName: map['template_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'template_id': templateId,
      'template_name': templateName,
    };
  }
}