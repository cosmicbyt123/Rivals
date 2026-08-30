import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/personal_training_model.dart';

class PtRepository {
  final SupabaseClient? _client;

  PtRepository([this._client]);

  SupabaseClient get client => _client ?? SupabaseConfig.client;

  Future<List<CoachModel>> getCoaches(String gymId) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client
            .from('profiles')
            .select('*')
            .eq('home_gym_id', gymId)
            .eq('role', 'trainer');

        if ((res as List).isNotEmpty) {
          return (res).map((row) => CoachModel.fromJson(row)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading coaches from Supabase: $e');
    }

    return [
      CoachModel(
        id: 'c1',
        name: 'Coach Vikram Rathore',
        role: 'Head Strength & Hypertrophy Coach',
        rating: '4.95',
        clients: 24,
        maxClients: 25,
        sessionsThisMonth: 78,
        revenue: '₹48,000',
        specialty: 'Powerlifting & Biomechanics',
        avatarText: 'VR',
        phone: '+91 98111 22334',
        isAvailable: true,
      ),
      CoachModel(
        id: 'c2',
        name: 'Coach Ananya Roy',
        role: 'Senior Functional & Conditioning Coach',
        rating: '4.91',
        clients: 19,
        maxClients: 20,
        sessionsThisMonth: 62,
        revenue: '₹38,000',
        specialty: 'HIIT, Kettlebell & Mobility',
        avatarText: 'AR',
        phone: '+91 98222 33445',
        isAvailable: true,
      ),
      CoachModel(
        id: 'c3',
        name: 'Coach Arjun Verma',
        role: 'Powerlifting & Heavy Tonnage Coach',
        rating: '4.88',
        clients: 15,
        maxClients: 18,
        sessionsThisMonth: 46,
        revenue: '₹30,000',
        specialty: 'Deadlift & Squat Mechanics',
        avatarText: 'AV',
        phone: '+91 98333 44556',
        isAvailable: true,
      ),
      CoachModel(
        id: 'c4',
        name: 'Coach Priya Sharma',
        role: 'Athletic Nutrition & Recovery Coach',
        rating: '4.96',
        clients: 12,
        maxClients: 15,
        sessionsThisMonth: 38,
        revenue: '₹24,000',
        specialty: 'Post-Injury Rehab & Dietetics',
        avatarText: 'PS',
        phone: '+91 98444 55667',
        isAvailable: false,
      ),
    ];
  }

  Future<List<PtSessionModel>> getTodaySessions(String gymId) async {
    return [
      PtSessionModel(
        id: 's1',
        time: '07:00 AM - 08:00 AM',
        coachName: 'Coach Vikram',
        athleteName: 'Arjun Verma',
        focus: 'Deadlift Peak & Heavy Lockouts',
        status: 'Completed',
        avatarText: 'AV',
      ),
      PtSessionModel(
        id: 's2',
        time: '08:30 AM - 09:30 AM',
        coachName: 'Coach Ananya',
        athleteName: 'Rahul Sen',
        focus: 'HIIT Conditioning & Core Circuit',
        status: 'Completed',
        avatarText: 'RS',
      ),
      PtSessionModel(
        id: 's3',
        time: '11:00 AM - 12:00 PM',
        coachName: 'Coach Vikram',
        athleteName: 'Devansh Chawla',
        focus: 'Squat Depth & Hip Mobility',
        status: 'In Progress',
        avatarText: 'DC',
      ),
      PtSessionModel(
        id: 's4',
        time: '05:30 PM - 06:30 PM',
        coachName: 'Coach Arjun',
        athleteName: 'Tanya Malik',
        focus: 'Bench Press Arch & Leg Drive',
        status: 'Upcoming',
        avatarText: 'TM',
      ),
      PtSessionModel(
        id: 's5',
        time: '07:00 PM - 08:00 PM',
        coachName: 'Coach Ananya',
        athleteName: 'Kavita Nair',
        focus: 'Full Body Functional Stamina',
        status: 'Upcoming',
        avatarText: 'KN',
      ),
    ];
  }

  Future<List<PtClientModel>> getPtClients(String gymId) async {
    return [
      PtClientModel(
        id: 'cl1',
        name: 'Arjun Verma',
        coach: 'Coach Vikram',
        program: 'Hypertrophy Block A (Month 3)',
        sessionsLeft: '8 / 12 left',
        progress: 0.67,
        renewalDue: '14 Sep 2026',
        avatarText: 'AV',
      ),
      PtClientModel(
        id: 'cl2',
        name: 'Rahul Sen',
        coach: 'Coach Ananya',
        program: 'Functional Athletic Cut',
        sessionsLeft: '4 / 12 left',
        progress: 0.33,
        renewalDue: '02 Sep 2026 (Expiring Soon)',
        avatarText: 'RS',
      ),
      PtClientModel(
        id: 'cl3',
        name: 'Tanya Malik',
        coach: 'Coach Vikram',
        program: 'Powerlifting Meet Prep',
        sessionsLeft: '10 / 12 left',
        progress: 0.83,
        renewalDue: '28 Sep 2026',
        avatarText: 'TM',
      ),
      PtClientModel(
        id: 'cl4',
        name: 'Devansh Chawla',
        coach: 'Coach Arjun',
        program: 'Squat Technique Overhaul',
        sessionsLeft: '2 / 12 left',
        progress: 0.17,
        renewalDue: '30 Aug 2026 (Renew Now)',
        avatarText: 'DC',
      ),
    ];
  }
}
