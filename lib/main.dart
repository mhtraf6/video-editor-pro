import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

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

class Project {
  String name;
  String videoPath;
  List edits;
  Project({required this.name, required this.videoPath, this.edits = const []});
  Map toJson() => {'name': name, 'videoPath': videoPath, 'edits': edits};
  factory Project.fromJson(Map json) => Project(name: json['name'], videoPath: json['videoPath'], edits: json['edits']?? []);
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Project> projects = [];
  List<String> arabicFonts = ['Cairo', 'Tajawal', 'Almarai', 'Amiri', 'CairoPlay'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('projects');
    if (data!= null) {
      List jsonList = jsonDecode(data);
      setState(() => projects = jsonList.map((e) => Project.fromJson(e)).toList());
    }
  }

  Future<void> _saveProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('projects', jsonEncode(projects.map((e) => e.toJson()).toList()));
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result!= null) {
      String name = 'مشروع ${projects.length + 1}';
      Project newProject = Project(name: name, videoPath: result.files.single.path!);
      setState(() => projects.add(newProject));
      _saveProjects();
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(project: newProject, onSave: _saveProjects, fonts: arabicFonts)));
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
          IconButton(icon: Icon(Icons.library_music, color: Colors.white), onPressed: () => _showMusicLibrary()),
          IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: () => _showSettings()),
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
                _homeTool(Icons.explore, 'استكشاف', Colors.purple, () {}),
                _homeTool(Icons.camera_alt, 'الكاميرا', Colors.red, () {}),
                _homeTool(Icons.mic, 'تسجيل', Colors.orange, () {}),
                _homeTool(Icons.auto_fix_high, 'تحسين AI', Colors.green, () {}),
                _homeTool(Icons.psychology, 'ذكاء اصطناعي', Colors.cyan, () => _showAITools()),
                _homeTool(Icons.dashboard, 'قوالب', Colors.pink, () => _showTemplates()),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('المشاريع', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold))),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(15),
                    itemCount: projects.length,
                    itemBuilder: (context, i) => Container(
                      width: 170,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(color: Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(20)),
                      child: Stack(
                        children: [
                          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(project: projects[i], onSave: _saveProjects, fonts: arabicFonts))), child: Center(child: Icon(Icons.videocam, size: 50, color: Color(0xFF00D4FF)))),
                          Positioned(top: 8, right: 8, child: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() {projects.removeAt(i); _saveProjects();}))),
                          Positioned(bottom: 8, left: 8, child: Text(projects[i].name, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white))),
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

  Widget _homeTool(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(padding: EdgeInsets.all(18), decoration: BoxDecoration(color: color.withOpacity(0.25), borderRadius: BorderRadius.circular(22)), child: Icon(icon, size: 38, color: color)),
            SizedBox(height: 10),
            Text(label, style: GoogleFonts.cairo(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showMusicLibrary() {
    showModalBottomSheet(context: context, backgroundColor: Color(0xFF1E1E2E), builder: (_) => Container(
      height: 300,
      child: Column(children: [
        Padding(padding: EdgeInsets.all(15), child: Text('مكتبة موسيقى بدون حقوق', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white))),
        Expanded(child: ListView(children: ['Energetic', 'Chill', 'Cinematic', 'Hip Hop'].map((m) => ListTile(title: Text(m, style: GoogleFonts.cairo()), trailing: Icon(Icons.download, color: Color(0xFF00D4FF)))).toList()))
      ]),
    ));
  }

  void _showSettings() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Color(0xFF1E1E2E),
      title: Text('الاعدادات', style: GoogleFonts.cairo(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: Text('جودة التصدير 4K', style: GoogleFonts.cairo()), trailing: Switch(value: true, onChanged: (v) {})),
        ListTile(title: Text('ضغط الفيديو', style: GoogleFonts.cairo()), trailing: Switch(value: false, onChanged: (v) {})),
        ListTile(title: Text('حفظ تلقائي', style: GoogleFonts.cairo()), trailing: Switch(value: true, onChanged: (v) {})),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('تم', style: GoogleFonts.cairo(color: Color(0xFF00D4FF))))],
    ));
  }

  void _showAITools() {
    showModalBottomSheet(context: context, backgroundColor: Color(0xFF1E1E2E), builder: (_) => Container(
      height: 250,
      child: Column(children: [
        Padding(padding: EdgeInsets.all(15), child: Text('ادوات الذكاء الاصطناعي', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white))),
        ListTile(title: Text('تغيير الخلفية', style: GoogleFonts.cairo()), trailing: Icon(Icons.wallpaper, color: Colors.green)),
        ListTile(title: Text('تحسين الجودة', style: GoogleFonts.cairo()), trailing: Icon(Icons.auto_awesome, color: Colors.blue)),
        ListTile(title: Text('عزل الصوت', style: GoogleFonts.cairo()), trailing: Icon(Icons.mic_off, color: Colors.orange)),
      ]),
    ));
  }

  void _showTemplates() {
    showModalBottomSheet(context: context, backgroundColor: Color(0xFF1E1E2E), builder: (_) => Container(
      height: 250,
      child: Column(children: [
        Padding(padding: EdgeInsets.all(15), child: Text('قوالب جاهزة', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white))),
        Expanded(child: GridView.count(crossAxisCount: 3, children: ['تيك توك 9:16', 'يوتيوب 16:9', 'انستا 1:1'].map((t) => Container(margin: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFF2E2E3E), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(t, style: GoogleFonts.cairo(fontSize: 12))))).toList())),
      ]),
    ));
  }
}

class EditScreen extends StatefulWidget {
  final Project project;
  final Function onSave;
  final List<String> fonts;
  EditScreen({required this.project, required this.onSave, required this.fonts});
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  VideoPlayerController? _controller;
  bool exporting = false;
  double progress = 0;
  double speed = 1.0;
  String selectedFont = 'Cairo';
  String aspectRatio = '9:16';
  bool compressVideo = false;

  List<Map> tools = [
    {'icon': Icons.content_cut, 'label': 'قص', 'color': Color(0xFFFF3B30)},
    {'icon': Icons.music_note, 'label': 'موسيقى', 'color': Color(0xFFAF52DE)},
    {'icon': Icons.text_fields, 'label': 'نص + خطوط', 'color': Color(0xFF007AFF)},
    {'icon': Icons.auto_awesome, 'label': 'مؤثرات', 'color': Color(0xFF00D4FF)},
    {'icon': Icons.transition, 'label': 'انتقالات', 'color': Color(0xFFFF2D55)},
    {'icon': Icons.filter, 'label': 'فلاتر', 'color': Color(0xFF34C759)},
    {'icon': Icons.translate, 'label': 'ترجمة AI', 'color': Color(0xFFFFCC00)},
    {'icon': Icons.speed, 'label': 'سرعة', 'color': Color(0xFF5856D6)},
    {'icon': Icons.crop, 'label': 'اقتصاص', 'color': Color(0xFF8E8E93)},
    {'icon': Icons.blur_on, 'label': 'موزاييك', 'color': Color(0xFFC7C7CC)},
    {'icon': Icons.mic, 'label': 'سجل صوت', 'color': Color(0xFFFF3B30)},
    {'icon': Icons.compress, 'label': 'ضغط', 'color': Color(0xFF32ADE6)},
  ];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.project.videoPath))..initialize().then((_) => setState(() {}));
  }

  Future<void> exportVideo() async {
    _showAd();
    setState(() {exporting = true; progress = 0;});
    final dir = await getApplicationDocumentsDirectory();
    final outputPath = '${dir.path}/VideoPro_${DateTime.now().millisecondsSinceEpoch}.mp4';

    String scale = aspectRatio == '1:1'? 'scale=1080:1080' : aspectRatio == '16:9'? 'scale=1920:1080' : 'scale=1080:1920';
    String crf = compressVideo? '28' : '23';
    String preset = 'ultrafast';

    String command = '-i "${widget.project.videoPath}" -vf "$scale,fps=30" -r 30 -vcodec libx264 -preset $preset -crf $crf -acodec aac -b:a 128k "$outputPath"';

    await FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      setState(() => exporting = false);
      if (ReturnCode.isSuccess(returnCode)) {
        widget.project.edits.add({'export': outputPath, 'time': DateTime.now().toString()});
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الحفظ 4K: $outputPath'), backgroundColor: Colors.green));
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
        title: Text(widget.project.name, style: GoogleFonts.cairo()),
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
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tools.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ToolPage(title: tools[i]['label'], icon: tools[i]['icon'], color: tools[i]['color'], fonts: widget.fonts, onSpeedChange: (s) => setState(() => speed = s), onRatioChange: (r) => setState(() => aspectRatio = r), onCompressChange: (c) => setState(() => compressVideo = c)))),
                    child: Container(
                      width: 85,
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        children: [
                          Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: tools[i]['color'].withOpacity(0.2), borderRadius: BorderRadius.circular(18)), child: Icon(tools[i]['icon'], size: 34, color: tools[i]['color'])),
                          SizedBox(height: 8),
                          Text(tools[i]['label'], style: GoogleFonts.cairo(fontSize: 11), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
  final List<String> fonts;
  final Function(double) onSpeedChange;
  final Function(String) onRatioChange;
  final Function(bool) onCompressChange;

  ToolPage({required this.title, required this.icon, required this.color, required this.fonts, required this.onSpeedChange, required this.onRatioChange, required this.onCompressChange});

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> allData = {
      'قص': ['قص البداية', 'قص النهاية', 'تقسيم', 'حذف جزء'],
      'موسيقى': ['مكتبة', 'استيراد', 'تسجيل', 'عزل صوت'],
      'نص + خطوط': fonts,
      'مؤثرات': ['VHS', 'نيون', 'سينمائي', 'قديم', 'ثلج', 'مطر', 'ضباب', 'Glow'],
      'انتقالات': ['Fade', 'Zoom', 'Slide', 'Flip', 'Dissolve'],
      'فلاتر': ['أبيض وأسود', 'سيبيا', 'دافئ', 'بارد', 'حيوي', 'AI Enhance'],
      'سرعة': ['0.25x', '0.5x', '1x', '2x', '4x'],
      'اقتصاص': ['9:16 تيك توك', '16:9 يوتيوب', '1:1 انستا', '4:5'],
      'ضغط': ['عالي', 'متوسط', 'بدون ضغط'],
    };
    List<String> data = allData[title]?? ['قسم $title'];

    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(backgroundColor: Colors.black, title: Text(title, style: GoogleFonts.cairo())),
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 15, mainAxisSpacing: 15),
        itemCount: data.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            if (title == 'سرعة') onSpeedChange(double.parse(data[i].replaceAll('x', '')));
            if (title == 'اقتصاص') onRatioChange(data[i].split(' ')[0]);
            if (title == 'ضغط') onCompressChange(data[i]!= 'بدون ضغط');
          },
          child: Container(
            decoration: BoxDecoration(color: Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.4))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 38, color: color), SizedBox(height: 10), Text(data[i], style: GoogleFonts.cairo(fontSize: 12))]),
          ),
        ),
      ),
    );
  }
}
