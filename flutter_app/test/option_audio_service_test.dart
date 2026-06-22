import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/services/option_audio_service.dart';

void main() {
  group('OptionAudioService', () {
    test('normalizes option text into stable asset keys', () {
      expect(OptionAudioService.normalizeOptionText('ric'), 'ric');
      expect(OptionAudioService.normalizeOptionText('de nihil'), 'de_nihil');
      expect(OptionAudioService.normalizeOptionText('tu veni'), 'tu_veni');
      expect(
        OptionAudioService.normalizeOptionText('rico(s); rica(s)'),
        'rico_s_rica_s',
      );
      expect(
        OptionAudioService.normalizeOptionText('  Ànche çò?  '),
        'anche_co',
      );
    });

    test('builds the expected asset path', () {
      expect(
        OptionAudioService.assetPathForOption('de nihil'),
        'assets/audios/interlingua/de_nihil.wav',
      );
    });
  });
}
