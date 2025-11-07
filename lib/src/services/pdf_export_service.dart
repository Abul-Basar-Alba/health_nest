import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pregnancy_model.dart';
import '../models/symptom_log_model.dart';
import '../models/doctor_visit_model.dart';
import '../models/bump_photo_model.dart';
import '../models/contraction_log_model.dart';
import '../models/postpartum_log_model.dart';

class PdfExportService {
  static Future<pw.Document> generatePregnancyReport({
    required PregnancyModel pregnancy,
    List<SymptomLogModel>? symptoms,
    List<DoctorVisitModel>? doctorVisits,
    List<BumpPhotoModel>? bumpPhotos,
    Map<String, dynamic>? kickCountStats,
    List<ContractionLogModel>? contractions,
    List<PostpartumLogModel>? postpartumLogs,
    bool isBangla = false,
    bool includeSummary = true,
    bool includeSymptoms = true,
    bool includeVisits = true,
    bool includePhotos = true,
    bool includeKicks = true,
    bool includeContractions = true,
    bool includePostpartum = true,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (context) => _buildCoverPage(pregnancy, isBangla)));
    if (includeSummary) pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => [_buildPregnancySummary(pregnancy, isBangla)]));
    if (includeSymptoms && symptoms != null && symptoms.isNotEmpty) pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => [_buildSymptomSection(symptoms, isBangla)]));
    if (includeVisits && doctorVisits != null && doctorVisits.isNotEmpty) pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => [_buildDoctorVisitsSection(doctorVisits, isBangla)]));
    if (includePhotos && bumpPhotos != null && bumpPhotos.isNotEmpty) pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => [_buildPhotoGallerySection(bumpPhotos, isBangla)]));
    if (includeKicks && kickCountStats != null) pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (context) => _buildKickCountSection(kickCountStats, isBangla)));
    if (includeContractions && contractions != null && contractions.isNotEmpty) pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => [_buildContractionsSection(contractions, isBangla)]));
    if (includePostpartum && postpartumLogs != null && postpartumLogs.isNotEmpty) pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => [_buildPostpartumSection(postpartumLogs, isBangla)]));
    return pdf;
  }

  static pw.Widget _buildCoverPage(PregnancyModel pregnancy, bool isBangla) {
    return pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [pw.Text(isBangla ? 'গর্ভাবস্থার রিপোর্ট' : 'Pregnancy Report', style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#E91E63'))), pw.SizedBox(height: 40), pw.Text('${isBangla ? 'সপ্তাহ' : 'Week'} ${pregnancy.getCurrentWeek()} of 42', style: pw.TextStyle(fontSize: 24, color: PdfColor.fromHex('#C2185B'))), pw.SizedBox(height: 20), pw.Text('${isBangla ? 'নির্ধারিত তারিখ' : 'Due Date'}: ${_formatDate(pregnancy.dueDate)}', style: const pw.TextStyle(fontSize: 18))]));
  }

  static pw.Widget _buildPregnancySummary(PregnancyModel pregnancy, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'গর্ভাবস্থার সারসংক্ষেপ' : 'Pregnancy Summary', isBangla), pw.SizedBox(height: 20), _buildInfoRow(isBangla ? 'শেষ মাসিকের তারিখ' : 'Last Period Date', _formatDate(pregnancy.lastPeriodDate), isBangla), _buildInfoRow(isBangla ? 'নির্ধারিত তারিখ' : 'Due Date', _formatDate(pregnancy.dueDate), isBangla), _buildInfoRow(isBangla ? 'বর্তমান সপ্তাহ' : 'Current Week', '${pregnancy.getCurrentWeek()} of 42', isBangla), _buildInfoRow(isBangla ? 'দিন বাকি' : 'Days Remaining', '${pregnancy.getDaysRemaining()} ${isBangla ? 'দিন' : 'days'}', isBangla)]);
  }

  static pw.Widget _buildSymptomSection(List<SymptomLogModel> symptoms, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'লক্ষণ লগ' : 'Symptom Log', isBangla), pw.SizedBox(height: 20), pw.Text('${isBangla ? 'মোট লক্ষণ রেকর্ড' : 'Total Records'}: ${symptoms.length}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))]);
  }

  static pw.Widget _buildDoctorVisitsSection(List<DoctorVisitModel> visits, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'ডাক্তার দেখানো' : 'Doctor Visits', isBangla), pw.SizedBox(height: 20), ...visits.map((v) => pw.Container(margin: const pw.EdgeInsets.only(bottom: 10), padding: const pw.EdgeInsets.all(10), decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue300)), child: pw.Text(v.getVisitTypeName(isBangla))))]);
  }

  static pw.Widget _buildPhotoGallerySection(List<BumpPhotoModel> photos, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'বাম্প ফটো' : 'Bump Photos', isBangla), pw.SizedBox(height: 20), pw.Text('${isBangla ? 'মোট ফটো' : 'Total Photos'}: ${photos.length}')]);
  }

  static pw.Widget _buildKickCountSection(Map<String, dynamic> stats, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'কিক কাউন্ট' : 'Kick Count', isBangla), pw.SizedBox(height: 20), _buildInfoRow(isBangla ? 'মোট সেশন' : 'Total Sessions', '${stats['totalSessions'] ?? 0}', isBangla), _buildInfoRow(isBangla ? 'মোট কিক' : 'Total Kicks', '${stats['totalKicks'] ?? 0}', isBangla)]);
  }

  static pw.Widget _buildContractionsSection(List<ContractionLogModel> contractions, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'সংকোচন লগ' : 'Contraction Log', isBangla), pw.SizedBox(height: 20), pw.Text('${isBangla ? 'মোট সংকোচন' : 'Total'}: ${contractions.length}')]);
  }

  static pw.Widget _buildPostpartumSection(List<PostpartumLogModel> logs, bool isBangla) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_buildSectionHeader(isBangla ? 'প্রসবোত্তর' : 'Postpartum', isBangla), pw.SizedBox(height: 20), pw.Text('${isBangla ? 'মোট লগ' : 'Total Logs'}: ${logs.length}')]);
  }

  static pw.Widget _buildSectionHeader(String title, bool isBangla) {
    return pw.Container(padding: const pw.EdgeInsets.symmetric(vertical: 10), decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E91E63'), width: 2))), child: pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#E91E63'))));
  }

  static pw.Widget _buildInfoRow(String label, String value, bool isBangla) {
    return pw.Container(margin: const pw.EdgeInsets.only(bottom: 10), child: pw.Row(children: [pw.Expanded(flex: 2, child: pw.Text('$label:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))), pw.Expanded(flex: 3, child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)))]));
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static Future<String> savePdf(pw.Document pdf, String fileName) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static Future<void> sharePdf(pw.Document pdf, String fileName) async {
    await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
  }

  static Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> previewPdf(pw.Document pdf, String title) async {
    await Printing.layoutPdf(name: title, onLayout: (format) async => pdf.save());
  }
}
