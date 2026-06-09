import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

void main() => runApp(VideoEditorPro());

class VideoEditorPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
        primaryColor: Color(0xFF00D4FF),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> drafts = ['فيديو 1', 'فيديو 2', 'مشروع 3'];

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result!= null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(videoPath: result.files.single.path!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Video Pro', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _pickVideo,
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color(0xFF00D4FF), width: 2),
                  boxShadow: [BoxShadow(color: Color(0xFF00D4FF).withOpacity(0.4), blurRadius: 20)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, size: 100, color: Color(0xFF00D4FF)),
                    SizedBox(height: 20),
                    Text('اضافة فيديو او جديد', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('اضغط لاختيار فيديو', style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[400])),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15),
              children: [
                _homeTool(Icons.explore, 'استكشاف', Colors.purple),
                _homeTool(Icons.camera_alt, 'الكاميرا', Colors.red),
                _homeTool(Icons.mic, 'تسجيل', Colors.orange),
                _homeTool(Icons.auto_fix_high, 'تحسين', Colors.green),
                _homeTool(Icons.psychology, 'الذكاء الاصطناعي', Colors.cyan),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('المسودات', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold))),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(15),
                    itemCount: drafts.length,
                    itemBuilder: (context, i) => Container(
                      width: 170,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(color: Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(20)),
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.videocam, size: 50, color: Color(0xFF00D4FF))),
                          Positioned(top: 8, right: 8, child: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => drafts.removeAt(i)))),
                          Positioned(bottom: 8, left: 8, child: IconButton(icon: Icon(Icons.edit, color: Color(0xFF00D4FF)), onPressed: _pickVideo)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeTool(IconData icon, String label, Color color) {
    return Container(
      width: 85,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(padding: EdgeInsets.all(18), decoration: BoxDecoration(color: color.withOpacity(0.25), borderRadius: BorderRadius.circular(22)), child: Icon(icon, size: 38, color: color)),
          SizedBox(height: 10),
          Text(label, style: GoogleFonts.cairo(fontSize: 13)),
        ],
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  final String videoPath;
  EditScreen({required this.videoPath});
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  VideoPlayerController? _controller;
  bool exporting = false;
  double progress = 0;

  List<Map> tools = [
    {'icon': Icons.content_cut, 'label': 'قص', 'color': Color(0xFFFF3B30)},
    {'icon': Icons.music_note, 'label': 'موسيقى', 'color': Color(0xFFAF52DE)},
    {'icon': Icons.text_fields, 'label': 'نص', 'color': Color(0xFF007AFF)},
    {'icon': Icons.emoji_emotions, 'label': 'ملصقات', 'color': Color(0xFFFF9500)},
    {'icon': Icons.auto_awesome, 'label': 'مؤثرات', 'color': Color(0xFF00D4FF)},
    {'icon': Icons.layers, 'label': 'دمج', 'color': Color(0xFFFF2D55)},
    {'icon': Icons.filter, 'label': 'فلاتر', 'color': Color(0xFF34C759)},
    {'icon': Icons.translate, 'label': 'ترجمة', 'color': Color(0xFFFFCC00)},
    {'icon': Icons.wallpaper, 'label': 'خلفية', 'color': Color(0xFF5AC8FA)},
    {'icon': Icons.speed, 'label': 'سرعة', 'color': Color(0xFF5856D6)},
    {'icon': Icons.crop, 'label': 'اقتصاص', 'color': Color(0xFF8E8E93)},
    {'icon': Icons.blur_on, 'label': 'موزاييك', 'color': Color(0xFFC7C7CC)},
    {'icon': Icons.mic, 'label': 'سجل صوت', 'color': Color(0xFF3B30)},
    {'icon': Icons.volume_up, 'label': 'حجم الصوت', 'color': Color(0xFF32ADE6)},
    {'icon': Icons.rotate_90_degrees_cw, 'label': 'تدوير', 'color': Color(0xFFFFB700)},
    {'icon': Icons.flip, 'label': 'قلب', 'color': Color(0xFF30D158)},
  ];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))..initialize().then((_) => setState(() {}));
  }

  Future<void> exportVideo() async {
    _showAd();
    setState(() {exporting = true; progress = 0;});
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/VideoPro_${DateTime.now().millisecondsSinceEpoch}.mp4';
    String command = '-i "${widget.videoPath}" -vcodec libx264 -preset ultrafast -crf 23 -acodec aac "$outputPath"';
    await FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      setState(() => exporting = false);
      if (ReturnCode.isSuccess(returnCode)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الحفظ: $outputPath'), backgroundColor: Colors.green, duration: Duration(seconds: 3)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التصدير'), backgroundColor: Colors.red));
      }
    }, null, (stats) {
      if (stats!= null && stats.getTime() > 0) {
        setState(() => progress = (stats.getTime() / 10000000).clamp(0.0, 1.0));
      }
    });
  }

  void _showAd() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: Color(0xFF1E1E2E),
      title: Text('إعلان', style: GoogleFonts.cairo(color: Colors.white)),
      content: Text('شاهد الإعلان 5 ثواني للتصدير بدون علامة مائية', style: GoogleFonts.cairo(color: Colors.grey[300])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('متابعة', style: GoogleFonts.cairo(color: Color(0xFF00D4FF))))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('تعديل الفيديو', style: GoogleFonts.cairo()),
        actions: [IconButton(icon: Icon(Icons.download_done, color: Color(0xFF00D4FF), size: 32), onPressed: exportVideo)],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: InteractiveViewer(maxScale: 5, child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(25)),
                  child: _controller!.value.isInitialized? AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)) : Center(child: CircularProgressIndicator()),
                )),
              ),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tools.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ToolPage(title: tools[i]['label'], icon: tools[i]['icon'], color: tools[i]['color']))),
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        children: [
                          Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: tools[i]['color'].withOpacity(0.2), borderRadius: BorderRadius.circular(18)), child: Icon(tools[i]['icon'], size: 34, color: tools[i]['color'])),
                          SizedBox(height: 8),
                          Text(tools[i]['label'], style: GoogleFonts.cairo(fontSize: 12), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
            ],
          ),
          if (exporting) Container(color: Colors.black.withOpacity(0.9), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(value: progress, color: Color(0xFF00D4FF), strokeWidth: 8),
            SizedBox(height: 30),
            Text('جاري التصدير... ${(progress * 100).toInt()}%', style: GoogleFonts.cairo(fontSize: 22, color: Colors.white)),
          ]))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class ToolPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  ToolPage({required this.title, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> allData = {
      'قص': ['قص البداية', 'قص النهاية', 'تقسيم'],
      'موسيقى': ['مكتبة', 'استيراد', 'تسجيل'],
      'نص': ['عنوان', 'ترجمة', 'تعليق'],
      'مؤثرات': ['VHS', 'نيون', 'سينمائي', 'قديم', 'ثلج', 'مطر', 'ضباب'],
      'فلاتر': ['أبيض وأسود', 'سيبيا', 'دافئ', 'بارد', 'حيوي'],
      'سرعة': ['0.5x', '1x', '2x', '4x'],
      'اقتصاص': ['1:1', '16:9', '9:16'],
      'قلب': ['أفقي', 'عمودي'],
    };
    List<String> data = allData[title]?? ['قسم $title'];
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(backgroundColor: Colors.black, title: Text(title, style: GoogleFonts.cairo())),
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 15, mainAxisSpacing: 15),
        itemCount: data.length,
        itemBuilder: (context, i) => Container(
          decoration: BoxDecoration(color: Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.4))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 38, color: color), SizedBox(height: 10), Text(data[i], style: GoogleFonts.cairo(fontSize: 13))]),
        ),
      ),
    );
  }
}
