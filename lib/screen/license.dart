import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
import 'package:loop/manager/temp_manager.dart';
import 'package:loop/network/client.dart';
import 'package:loop/network/request_model.dart';
import 'package:loop/network/response_model.dart';
import 'package:loop/screen/chat.dart';

class LicenseInputScreen extends StatefulWidget {
  final String? license;
  const LicenseInputScreen({super.key, required this.license});

  @override
  State<LicenseInputScreen> createState() => _LicenseInputScreenState();
}

class _LicenseInputScreenState extends State<LicenseInputScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final TempManager _tempManager = TempManager();
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  bool _isButtonEnabled = false;
  bool _isValidating = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 화면이 시작될 때 첫 번째 TextField에 포커스 설정
      FocusScope.of(context).requestFocus(_focusNodes[widget.license == null ? 0 : 3]);
    });
    for(int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(_checkFilled);
      if(widget.license != null) {
        _controllers[i].text = widget.license!.substring(i * 4 + 1 * i, i * 4 + 1 * i + 4);
      }
    }

    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      if(_tempManager.getKeyboardHeight() != 0 || height < 1) return;

      _tempManager.setKeyboardHeight(height);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index) {
    if (_controllers[index].text.length == 4 && index < _focusNodes.length - 1) {
      // 다음 TextField로 포커스 이동
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  void _checkFilled() {
    bool allFieldsFilled = _controllers.every((controller) => controller.text.length == 4);
    setState(() {
      _isButtonEnabled = allFieldsFilled;
    });
  }

  Future<bool> _validateLicense() async {
    setState(() {
      _errorMessage = '';
      _isValidating = true;
    });

    try {
      var response = await RestClient(Dio()).addLicense(LicenseRequest(license: "${_controllers[0].text}-${_controllers[1].text}-${_controllers[2].text}-${_controllers[3].text}"));
      
      //오류 발생 시 DioException으로 이어지기 때문에 사실상 필요 없음.
      if(!response.success) {
        setState(() {
          _errorMessage = response.msg;
          _isValidating = false;
        });
      }
      
      //성공
      return true;
    } on DioException catch (e, _) {
      if(e.response == null) {
        setState(() {
          _errorMessage = "서버에서 응답을 수신하지 못했습니다.";
          _isValidating = false;
        });
        return false;
      }
      LicenseResponse response = LicenseResponse.fromJson(e.response!.data as Map<String, dynamic>);
      setState(() {
        _errorMessage = response.msg;
        _isValidating = false;
      });

      return false;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white, // 네비게이션 바의 배경색
          systemNavigationBarDividerColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
          statusBarColor: Colors.transparent, // 상태 바의 배경색
          statusBarIconBrightness: Brightness.dark, // 상태 바 아이콘 색상
        ),
        elevation: 3.0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.5),
        title: const Text('라이센스 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.license == null ?
              "본 서비스를 이용하기 위해서는 라이센스 키가 필요합니다.\r\n발급받은 라이센스 키를 입력해주세요." :
              "이미 등록되어 있는 라이센스 키가 존재합니다.\r\n\r\n기존 라이센스 키를 삭제하지 않고 새로운\r\n라이센스 키를 등록하는 경우 기존 라이센스 키에 대한\r\n사용 횟수는 돌려받으실 수 없습니다.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 70,
                  height: 40,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        gapPadding: 0,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    cursorHeight: 16,
                    onChanged: (text) => _onTextChanged(index),
                    style: GoogleFonts.spaceMono(),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_isValidating) const CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty) Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            if (_errorMessage.isNotEmpty || _isValidating) const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isButtonEnabled && !_isValidating ? () async {
                if(await _validateLicense() && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                }
              } : null,
              child: const Text("라이센스 적용"),
            ),

          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}