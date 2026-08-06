import 'models.dart';

enum ContractStatus { active, completed, failed }

class ContractTemplate {
  const ContractTemplate({
    required this.id,
    required this.name,
    required this.client,
    required this.description,
    required this.reward,
    required this.developmentHours,
    required this.deadlineDays,
    required this.upfrontPercent,
    required this.requiredRoles,
    this.graceDays = 3,
  });

  final String id;
  final String name;
  final String client;
  final String description;
  final double reward;
  final double developmentHours;
  final int deadlineDays;
  final double upfrontPercent;
  final List<EmployeeRole> requiredRoles;
  final int graceDays;
}

class ClientContract {
  const ClientContract({
    required this.id,
    required this.templateId,
    required this.status,
    required this.progress,
    required this.acceptedAtMinutes,
    required this.deadlineAtMinutes,
    required this.reward,
    this.milestonePaid = false,
  });

  final String id;
  final String templateId;
  final ContractStatus status;
  final double progress;
  final int acceptedAtMinutes;
  final int deadlineAtMinutes;
  final double reward;
  final bool milestonePaid;

  ClientContract copyWith({
    ContractStatus? status,
    double? progress,
    bool? milestonePaid,
  }) => ClientContract(
    id: id,
    templateId: templateId,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    acceptedAtMinutes: acceptedAtMinutes,
    deadlineAtMinutes: deadlineAtMinutes,
    reward: reward,
    milestonePaid: milestonePaid ?? this.milestonePaid,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'templateId': templateId,
    'status': status.name,
    'progress': progress,
    'acceptedAtMinutes': acceptedAtMinutes,
    'deadlineAtMinutes': deadlineAtMinutes,
    'reward': reward,
    'milestonePaid': milestonePaid,
  };

  factory ClientContract.fromJson(Map<String, Object?> json) => ClientContract(
    id: json['id']! as String,
    templateId: json['templateId']! as String,
    status: ContractStatus.values.byName(json['status']! as String),
    progress: (json['progress']! as num).toDouble(),
    acceptedAtMinutes: (json['acceptedAtMinutes']! as num).toInt(),
    deadlineAtMinutes: (json['deadlineAtMinutes']! as num).toInt(),
    reward: (json['reward']! as num).toDouble(),
    milestonePaid: json['milestonePaid'] as bool? ?? false,
  );
}
