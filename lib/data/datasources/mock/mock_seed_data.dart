// NgakaAssist
// Mock data seed.
// Designed to feel like a Botswana public hospital workflow (calm, high-trust).

import '../../../domain/entities/icd10_suggestion.dart';
import '../../../domain/entities/patient.dart';
import '../../../domain/entities/soap_draft_note.dart';

class MockSeedData {
  static List<Patient> patients() => const [
        Patient(
          id: 'p_1001',
          firstName: 'Dineo',
          lastName: 'Kgosidintsi',
          dateOfBirth: null,
          gender: 'female',
          nationalId: 'BW-********',
          phone: '+267 7X XXX XXX',
        ),
        Patient(
          id: 'p_1002',
          firstName: 'Kabo',
          lastName: 'Mogapi',
          dateOfBirth: null,
          gender: 'male',
          nationalId: 'BW-********',
          phone: '+267 7X XXX XXX',
        ),
        Patient(
          id: 'p_1003',
          firstName: 'Amantle',
          lastName: 'Molefe',
          dateOfBirth: null,
          gender: 'female',
          nationalId: 'BW-********',
          phone: '+267 7X XXX XXX',
        ),
      ];

  static String transcript() =>
      'Clinician: Dumela mma, o ntse jang gompieno?\n'
      'Patient: Ke na le go opiwa ke tlhogo le go tlhakanelwa ke tlhogwana.\n'
      'Clinician: Go simolotse leng?\n'
      'Patient: Malatsi a le mararo a fetileng.\n'
      'Clinician: Go na le feberu kgotsa go tsekela?\n'
      'Patient: Feberu e nnye bosigo.\n'
      'Clinician: Re tla lekola BP, temperature le go go naya kalafi.\n';

  static SoapDraftNote soapDraft(String encounterId) {
    return SoapDraftNote(
      encounterId: encounterId,
      subjective: 'Headache x3 days, mild fever at night. No red flags reported.',
      objective: 'Vitals pending. General appearance stable.\nTODO(ngakaassist): Pull vitals from device/EMR.',
      assessment: 'Acute tension-type headache vs viral illness.\nTODO(ngakaassist): Differential diagnosis engine + guideline links.',
      plan: 'Check vitals, hydration advice, paracetamol PRN. Return precautions explained.',
      transcript: transcript(),
      aiGenerated: true,
      updatedAt: DateTime.now(),
    );
  }

  static List<Icd10Suggestion> icd10() => const [
        Icd10Suggestion(code: 'R51', description: 'Headache', confidence: 0.72, accepted: false),
        Icd10Suggestion(code: 'B34.9', description: 'Viral infection, unspecified', confidence: 0.58, accepted: false),
        Icd10Suggestion(code: 'R50.9', description: 'Fever, unspecified', confidence: 0.49, accepted: false),
      ];
}
