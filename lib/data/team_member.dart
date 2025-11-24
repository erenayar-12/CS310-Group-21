class TeamMember {
  const TeamMember({
    required this.id,
    required this.initials,
    required this.color,
    this.name,
    this.email,
  });

  final String id;
  final String initials;
  final int color; // Color value as int
  final String? name;
  final String? email;

  TeamMember copyWith({
    String? id,
    String? initials,
    int? color,
    String? name,
    String? email,
  }) {
    return TeamMember(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      color: color ?? this.color,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}



