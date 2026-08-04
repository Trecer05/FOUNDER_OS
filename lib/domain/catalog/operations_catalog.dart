import '../entities/operations_models.dart';

abstract final class OperationsCatalog {
  static const List<SecurityControlOption> securityControls = [
    SecurityControlOption(
      id: 'secure_sdlc',
      name: 'Secure SDLC',
      description:
          'Threat modeling, обязательный code review и чек-листы безопасности перед релизом.',
      setupCost: 90000,
      monthlyCost: 18000,
      securityDelta: 7,
      reliabilityDelta: 0.002,
      incidentMultiplier: 0.86,
    ),
    SecurityControlOption(
      id: 'sast_dependency',
      name: 'SAST + dependency scanning',
      description:
          'Автоматический поиск уязвимостей кода и зависимостей в каждом build.',
      setupCost: 150000,
      monthlyCost: 42000,
      securityDelta: 11,
      reliabilityDelta: 0.001,
      incidentMultiplier: 0.76,
    ),
    SecurityControlOption(
      id: 'waf_ddos',
      name: 'WAF и DDoS protection',
      description:
          'Фильтрация атак на периметре и защита публичных API от перегрузки.',
      setupCost: 220000,
      monthlyCost: 95000,
      securityDelta: 8,
      reliabilityDelta: 0.005,
      incidentMultiplier: 0.68,
    ),
    SecurityControlOption(
      id: 'kms_encryption',
      name: 'KMS и шифрование данных',
      description:
          'Раздельные ключи, rotation и encryption at rest для пользовательских данных.',
      setupCost: 310000,
      monthlyCost: 78000,
      securityDelta: 15,
      reliabilityDelta: 0.002,
      incidentMultiplier: 0.61,
    ),
    SecurityControlOption(
      id: 'backup_dr',
      name: 'Backups и disaster recovery',
      description:
          'Проверяемые резервные копии, отдельный recovery-контур и план восстановления.',
      setupCost: 360000,
      monthlyCost: 110000,
      securityDelta: 5,
      reliabilityDelta: 0.012,
      incidentMultiplier: 0.74,
    ),
    SecurityControlOption(
      id: 'soc_response',
      name: 'SOC и incident response',
      description:
          'Мониторинг 24/7, централизованные логи и готовый сценарий локализации атаки.',
      setupCost: 620000,
      monthlyCost: 260000,
      securityDelta: 18,
      reliabilityDelta: 0.006,
      incidentMultiplier: 0.44,
    ),
  ];

  static const List<TrainingProgramOption> trainingPrograms = [
    TrainingProgramOption(
      id: 'architecture',
      name: 'Архитектура масштабируемых систем',
      focus: TrainingFocus.engineering,
      description:
          'Улучшает системное мышление и скорость технических решений.',
      cost: 85000,
      skillDelta: 5,
      speedDelta: 3,
      qualityDelta: 2,
      autonomyDelta: 3,
      communicationDelta: 0,
      reliabilityDelta: 1,
    ),
    TrainingProgramOption(
      id: 'quality',
      name: 'Качество и тестовая стратегия',
      focus: TrainingFocus.quality,
      description: 'Снижает дефекты и улучшает предсказуемость релизов.',
      cost: 65000,
      skillDelta: 2,
      speedDelta: 0,
      qualityDelta: 6,
      autonomyDelta: 1,
      communicationDelta: 1,
      reliabilityDelta: 4,
    ),
    TrainingProgramOption(
      id: 'security',
      name: 'Application Security',
      focus: TrainingFocus.security,
      description: 'Secure coding, threat modeling и реакция на инциденты.',
      cost: 110000,
      skillDelta: 4,
      speedDelta: 0,
      qualityDelta: 3,
      autonomyDelta: 2,
      communicationDelta: 0,
      reliabilityDelta: 6,
    ),
    TrainingProgramOption(
      id: 'leadership',
      name: 'Техническое лидерство',
      focus: TrainingFocus.leadership,
      description:
          'Повышает автономность, коммуникацию и устойчивость команды.',
      cost: 125000,
      skillDelta: 1,
      speedDelta: 1,
      qualityDelta: 1,
      autonomyDelta: 6,
      communicationDelta: 7,
      reliabilityDelta: 3,
    ),
  ];

  static SecurityControlOption securityControlById(String id) =>
      securityControls.firstWhere((item) => item.id == id);

  static TrainingProgramOption trainingProgramById(String id) =>
      trainingPrograms.firstWhere((item) => item.id == id);
}
