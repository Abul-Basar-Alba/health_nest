import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../../services/pdf_export_service.dart';
import 'package:pdf/widgets.dart' as pw;

class PregnancyReportScreen extends StatefulWidget {
  const PregnancyReportScreen({super.key});
  @override
  State<PregnancyReportScreen> createState() => _PregnancyReportScreenState();
}

class _PregnancyReportScreenState extends State<PregnancyReportScreen> {
  bool _isGenerating = false;
  pw.Document? _generatedPdf;
  String? _generatedFileName;
  bool _includeSummary = true;
  bool _includeSymptoms = true;
  bool _includeVisits = true;
  bool _includePhotos = true;
  bool _includeKicks = true;
  bool _includeContractions = true;
  bool _includePostpartum = true;

  Future<void> _generateReport(BuildContext context) async {
    final pregnancyProvider = Provider.of<PregnancyProvider>(context, listen: false);
    final isBangla = pregnancyProvider.isBangla;
    if (pregnancyProvider.activePregnancy == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'কোন সক্রিয় গর্ভাবস্থা পাওয়া যায়নি' : 'No active pregnancy found'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final kickCountStats = {'totalSessions': pregnancyProvider.kickCounts.length, 'totalKicks': pregnancyProvider.kickCounts.fold<int>(0, (sum, kick) => sum + kick.kickCount), 'averageKicks': pregnancyProvider.kickCounts.isEmpty ? 0.0 : pregnancyProvider.kickCounts.fold<int>(0, (sum, kick) => sum + kick.kickCount) / pregnancyProvider.kickCounts.length, 'lastKickDate': pregnancyProvider.kickCounts.isNotEmpty ? pregnancyProvider.kickCounts.last.startTime : null};
      final pdf = await PdfExportService.generatePregnancyReport(pregnancy: pregnancyProvider.activePregnancy!, symptoms: _includeSymptoms ? pregnancyProvider.symptomLogs : null, doctorVisits: _includeVisits ? pregnancyProvider.doctorVisits : null, bumpPhotos: _includePhotos ? pregnancyProvider.bumpPhotos : null, kickCountStats: _includeKicks ? kickCountStats : null, contractions: _includeContractions ? pregnancyProvider.contractions : null, postpartumLogs: _includePostpartum ? pregnancyProvider.postpartumLogs : null, isBangla: isBangla, includeSummary: _includeSummary, includeSymptoms: _includeSymptoms, includeVisits: _includeVisits, includePhotos: _includePhotos, includeKicks: _includeKicks, includeContractions: _includeContractions, includePostpartum: _includePostpartum);
      setState(() {_generatedPdf = pdf; _generatedFileName = 'pregnancy_report_${DateTime.now().millisecondsSinceEpoch}.pdf'; _isGenerating = false;});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'রিপোর্ট সফলভাবে তৈরি হয়েছে!' : 'Report generated successfully!'), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => _isGenerating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'রিপোর্ট তৈরিতে ব্যর্থ: $e' : 'Failed to generate report: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _previewPdf(BuildContext context) async {
    if (_generatedPdf == null) return;
    final pregnancyProvider = Provider.of<PregnancyProvider>(context, listen: false);
    final isBangla = pregnancyProvider.isBangla;
    try {
      await PdfExportService.previewPdf(_generatedPdf!, isBangla ? 'গর্ভাবস্থার রিপোর্ট' : 'Pregnancy Report');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'পূর্বরূপ দেখাতে ব্যর্থ: $e' : 'Failed to preview: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _savePdf(BuildContext context) async {
    if (_generatedPdf == null || _generatedFileName == null) return;
    final pregnancyProvider = Provider.of<PregnancyProvider>(context, listen: false);
    final isBangla = pregnancyProvider.isBangla;
    try {
      final path = await PdfExportService.savePdf(_generatedPdf!, _generatedFileName!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'রিপোর্ট সংরক্ষিত হয়েছে: $path' : 'Report saved: $path'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'সংরক্ষণ করতে ব্যর্থ: $e' : 'Failed to save: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    if (_generatedPdf == null || _generatedFileName == null) return;
    final pregnancyProvider = Provider.of<PregnancyProvider>(context, listen: false);
    final isBangla = pregnancyProvider.isBangla;
    try {
      await PdfExportService.sharePdf(_generatedPdf!, _generatedFileName!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'শেয়ার করতে ব্যর্থ: $e' : 'Failed to share: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    if (_generatedPdf == null) return;
    final pregnancyProvider = Provider.of<PregnancyProvider>(context, listen: false);
    final isBangla = pregnancyProvider.isBangla;
    try {
      await PdfExportService.printPdf(_generatedPdf!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBangla ? 'প্রিন্ট করতে ব্যর্থ: $e' : 'Failed to print: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(builder: (context, pregnancyProvider, child) {
      final isBangla = pregnancyProvider.isBangla;
      return Scaffold(
        appBar: AppBar(title: Text(isBangla ? 'পিডিএফ রিপোর্ট' : 'PDF Report'), backgroundColor: const Color(0xFFF44336)),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(color: Colors.red.shade50, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(Icons.picture_as_pdf, size: 40, color: Colors.red.shade700), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isBangla ? 'সম্পূর্ণ গর্ভাবস্থার রিপোর্ট' : 'Complete Pregnancy Report', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(isBangla ? 'আপনার গর্ভাবস্থার সমস্ত তথ্য একটি পিডিএফ ফাইলে রপ্তানি করুন' : 'Export all your pregnancy data into a PDF file', style: const TextStyle(fontSize: 12))]))]))),
          const SizedBox(height: 24),
          Text(isBangla ? 'রিপোর্টে অন্তর্ভুক্ত করুন:' : 'Include in Report:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSectionCheckbox(title: isBangla ? 'গর্ভাবস্থার সারসংক্ষেপ' : 'Pregnancy Summary', value: _includeSummary, onChanged: (value) => setState(() => _includeSummary = value ?? true), icon: Icons.summarize),
          _buildSectionCheckbox(title: isBangla ? 'লক্ষণ লগ' : 'Symptom Log', value: _includeSymptoms, onChanged: (value) => setState(() => _includeSymptoms = value ?? true), icon: Icons.sick),
          _buildSectionCheckbox(title: isBangla ? 'ডাক্তার দেখানো' : 'Doctor Visits', value: _includeVisits, onChanged: (value) => setState(() => _includeVisits = value ?? true), icon: Icons.local_hospital),
          _buildSectionCheckbox(title: isBangla ? 'বাম্প ফটো' : 'Bump Photos', value: _includePhotos, onChanged: (value) => setState(() => _includePhotos = value ?? true), icon: Icons.photo_camera),
          _buildSectionCheckbox(title: isBangla ? 'কিক কাউন্ট পরিসংখ্যান' : 'Kick Count Statistics', value: _includeKicks, onChanged: (value) => setState(() => _includeKicks = value ?? true), icon: Icons.baby_changing_station),
          _buildSectionCheckbox(title: isBangla ? 'সংকোচন লগ' : 'Contraction Log', value: _includeContractions, onChanged: (value) => setState(() => _includeContractions = value ?? true), icon: Icons.timer),
          _buildSectionCheckbox(title: isBangla ? 'প্রসবোত্তর ট্র্যাকার' : 'Postpartum Tracker', value: _includePostpartum, onChanged: (value) => setState(() => _includePostpartum = value ?? true), icon: Icons.child_care),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(onPressed: _isGenerating ? null : () => _generateReport(context), icon: _isGenerating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome), label: Text(_isGenerating ? (isBangla ? 'তৈরি হচ্ছে...' : 'Generating...') : (isBangla ? 'রিপোর্ট তৈরি করুন' : 'Generate Report'), style: const TextStyle(fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          if (_generatedPdf != null) ...[const SizedBox(height: 24), Card(color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [Icon(Icons.check_circle, color: Colors.green.shade700), const SizedBox(width: 8), Expanded(child: Text(isBangla ? 'রিপোর্ট প্রস্তুত!' : 'Report Ready!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)))]), const SizedBox(height: 16), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _previewPdf(context), icon: const Icon(Icons.visibility), label: Text(isBangla ? 'পূর্বরূপ' : 'Preview'), style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () => _savePdf(context), icon: const Icon(Icons.save), label: Text(isBangla ? 'সংরক্ষণ' : 'Save'), style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green))))]), const SizedBox(height: 8), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _sharePdf(context), icon: const Icon(Icons.share), label: Text(isBangla ? 'শেয়ার' : 'Share'), style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () => _printPdf(context), icon: const Icon(Icons.print), label: Text(isBangla ? 'প্রিন্ট' : 'Print'), style: OutlinedButton.styleFrom(foregroundColor: Colors.purple, side: const BorderSide(color: Colors.purple))))])])))],
          const SizedBox(height: 24),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.info_outline, color: Colors.blue.shade700), const SizedBox(width: 8), Text(isBangla ? 'তথ্য' : 'Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700))]), const SizedBox(height: 12), Text(isBangla ? '• রিপোর্টে আপনার সম্পূর্ণ গর্ভাবস্থার তথ্য থাকবে\n• আপনি যে বিভাগগুলি অন্তর্ভুক্ত করতে চান তা নির্বাচন করুন\n• রিপোর্ট তৈরি হলে আপনি এটি সংরক্ষণ, শেয়ার বা প্রিন্ট করতে পারবেন\n• রিপোর্টটি ${isBangla ? 'বাংলা' : 'ইংরেজি'} ভাষায় তৈরি হবে' : '• Report will contain your complete pregnancy data\n• Select which sections you want to include\n• Once generated, you can save, share, or print it\n• Report will be generated in ${isBangla ? 'Bangla' : 'English'} language', style: const TextStyle(fontSize: 12))])))
        ])),
      );
    });
  }

  Widget _buildSectionCheckbox({required String title, required bool value, required ValueChanged<bool?> onChanged, required IconData icon}) {
    return Card(margin: const EdgeInsets.only(bottom: 8), child: CheckboxListTile(title: Row(children: [Icon(icon, size: 20, color: Colors.red.shade700), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontSize: 14)))]), value: value, onChanged: onChanged, activeColor: const Color(0xFFF44336), controlAffinity: ListTileControlAffinity.leading));
  }
}
