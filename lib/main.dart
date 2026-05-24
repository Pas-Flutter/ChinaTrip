import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'trip_data.dart';

void main() {
  runApp(const ChinaTripApp());
}

class ChinaTripApp extends StatelessWidget {
  const ChinaTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'China Trip Sci-Fi Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E5FF),
        scaffoldBackgroundColor: const Color(0xFF090C15),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF9E00FF),
          surface: Color(0xFF121824),
          background: Color(0xFF090C15),
          error: Color(0xFFFF3366),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MainTripDashboard(),
    );
  }
}

class MainTripDashboard extends StatefulWidget {
  const MainTripDashboard({super.key});

  @override
  State<MainTripDashboard> createState() => _MainTripDashboardState();
}

class _MainTripDashboardState extends State<MainTripDashboard> {
  // Mock Date and Time controls
  late bool _isMockTimeEnabled;
  DateTime _mockTime = DateTime(
    2026,
    6,
    15,
    10,
    0,
  ); // Default to Monday, June 15, 2026, 10:00 AM

  // Time-based timer to update every second if using real time
  Timer? _ticker;

  // Selected view day
  TripDay? _currentSelectedDay;

  // Key to control Scaffold drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isRealDateInTrip {
    final now = DateTime.now();
    return ItineraryData.getSelectedDayForDateTime(
          now,
          ItineraryData.itinerary,
        ) !=
        null;
  }

  bool get _shouldShowBottomPanel {
    // Show if simulator is active, or if today is NOT a real trip day
    return _isMockTimeEnabled || !_isRealDateInTrip;
  }

  @override
  void initState() {
    super.initState();
    // Default to false (live device time) if today is an actual date of the trip,
    // otherwise default to true (mocking) so they can test/see simulated trip events.
    _isMockTimeEnabled = !_isRealDateInTrip;
    _updateSelectedDayFromCurrentTime();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMockTimeEnabled) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime get _activeTime => _isMockTimeEnabled ? _mockTime : DateTime.now();

  List<TripDay> get _activeItinerary => ItineraryData.itinerary;

  // Detects the day from active time, and falls back to Day 1 if outside the trip
  void _updateSelectedDayFromCurrentTime() {
    final active = _activeTime;
    final found = ItineraryData.getSelectedDayForDateTime(
      active,
      _activeItinerary,
    );
    setState(() {
      _currentSelectedDay = found ?? _activeItinerary.first;
    });
  }

  // Active event on the current day
  TripEvent? _getCurrentlyHappeningEvent(TripDay day, DateTime activeTime) {
    // Only calculate if the active date matches this day's date
    if (day.date.year != activeTime.year ||
        day.date.month != activeTime.month ||
        day.date.day != activeTime.day) {
      return null;
    }
    for (var event in day.events) {
      if (event.isActiveAt(activeTime)) {
        return event;
      }
    }
    return null;
  }

  // Next event on the current day
  TripEvent? _getNextEvent(TripDay day, DateTime activeTime) {
    if (day.date.year != activeTime.year ||
        day.date.month != activeTime.month ||
        day.date.day != activeTime.day) {
      return null;
    }
    TripEvent? next;
    for (var event in day.events) {
      if (event.isUpcomingAfter(activeTime)) {
        if (next == null) {
          next = event;
        } else {
          // Find the earliest upcoming event
          final currentNextStart = DateTime(
            activeTime.year,
            activeTime.month,
            activeTime.day,
            next.startHour,
            next.startMinute,
          );
          final eventStart = DateTime(
            activeTime.year,
            activeTime.month,
            activeTime.day,
            event.startHour,
            event.startMinute,
          );
          if (eventStart.isBefore(currentNextStart)) {
            next = event;
          }
        }
      }
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final activeTime = _activeTime;
    final currentDayInItinerary = ItineraryData.getSelectedDayForDateTime(
      activeTime,
      _activeItinerary,
    );

    // Calculate events happening right now and next
    TripEvent? happeningNow;
    TripEvent? upNext;

    if (currentDayInItinerary != null) {
      happeningNow = _getCurrentlyHappeningEvent(
        currentDayInItinerary,
        activeTime,
      );
      upNext = _getNextEvent(currentDayInItinerary, activeTime);
    }

    final displayDay = _currentSelectedDay ?? _activeItinerary.first;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSidebarDrawer(context),
      body: Stack(
        children: [
          // Background glows
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9E00FF).withOpacity(0.06),
                    blurRadius: 150,
                    spreadRadius: 75,
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(displayDay),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Active info banner (happening now / next)
                      _buildNowNextStatusPanel(
                        happeningNow,
                        upNext,
                        currentDayInItinerary,
                      ),
                      const SizedBox(height: 16),
                      // Day title & transport overview
                      _buildDayOverviewCard(displayDay),
                      const SizedBox(height: 20),
                      // Timeline of events
                      _buildDayTimeline(displayDay, activeTime),
                      SizedBox(
                        height: _shouldShowBottomPanel ? 100 : 20,
                      ), // extra padding for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar containing Mock Controls & Active Time Indicators
          if (_shouldShowBottomPanel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomPanel(),
            ),
        ],
      ),
    );
  }

  // HEADER WITH DAY SELECTOR BUTTON & CURRENT TRIP TIME
  Widget _buildHeader(TripDay selectedDay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF090C15).withOpacity(0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E2638), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Menu button to select day
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF9E00FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_month, size: 18, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    'Select Day',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center/Right: Beautiful glowing app logo & subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'STEM UNLOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: const Color(0xFF00E5FF).withOpacity(0.8),
                ),
              ),
              const Text(
                'SHENZHEN 2050',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0xFF9E00FF),
                      blurRadius: 4,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STATUS CARD SHOWING CURRENTLY HAPPENING / NEXT EVENTS
  Widget _buildNowNextStatusPanel(
    TripEvent? now,
    TripEvent? next,
    TripDay? currentDay,
  ) {
    if (currentDay == null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1715),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFFFB300), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outside Trip Window',
                    style: TextStyle(
                      color: Color(0xFFFFB300),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Real date is outside Jun 14-19, 2026. Use Time Mocking at the bottom to test "Live Trip Mode"!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF131926),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: now != null
                  ? const Color(0xFF00E5FF).withOpacity(0.4)
                  : const Color(0xFF1E2B3E),
              width: 1.5,
            ),
            boxShadow: now != null
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Happening Now Section
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: now != null
                          ? const Color(0xFF00FF87)
                          : Colors.grey,
                      boxShadow: now != null
                          ? [
                              const BoxShadow(
                                color: Color(0xFF00FF87),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    now != null ? 'HAPPENING NOW' : 'NO ACTIVE EVENT NOW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: now != null
                          ? const Color(0xFF00FF87)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (now != null) ...[
                GestureDetector(
                  onTap: () => _navigateToEventDetail(now),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              now.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_filled,
                                  size: 13,
                                  color: Color(0xFF00E5FF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  now.timeRange,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF00E5FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (now.location != null) ...[
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.place,
                                    size: 13,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      now.location!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF00E5FF),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Relaxing / Free time in GZ/SZ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const Divider(color: Color(0xFF1E283C), height: 20),

              // Up Next Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UP NEXT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: next != null
                                ? const Color(0xFF9E00FF)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (next != null) ...[
                          GestureDetector(
                            onTap: () => _navigateToEventDetail(next),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    next.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  next.timeRange.split(
                                    ' ',
                                  )[0], // Start time only
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E00FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'No more events scheduled today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // OVERVIEW OF THE ACTIVE VIEW DAY
  Widget _buildDayOverviewCard(TripDay day) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF141A29), const Color(0xFF0F131E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E283C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'DAY ${day.dayNumber}',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                day.dateString,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            day.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.directions_car,
                size: 14,
                color: Color(0xFF9E00FF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  day.transportDetail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TIMELINE RENDERING
  Widget _buildDayTimeline(TripDay day, DateTime activeTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'TODAY TIMELINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: day.events.length,
          itemBuilder: (context, index) {
            final event = day.events[index];
            final isCurrent =
                event.isActiveAt(activeTime) &&
                day.date.year == activeTime.year &&
                day.date.month == activeTime.month &&
                day.date.day == activeTime.day;

            return _buildTimelineItem(
              event,
              index == day.events.length - 1,
              isCurrent,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimelineItem(TripEvent event, bool isLast, bool isCurrent) {
    // Select color based on event type
    Color accentColor;
    IconData icon;

    switch (event.type) {
      case EventType.transit:
        accentColor = const Color(0xFF9E00FF); // Transit: Purple
        icon = Icons.flight_takeoff;
        break;
      case EventType.food:
        accentColor = const Color(0xFFFFB300); // Food: Amber
        icon = Icons.restaurant;
        break;
      case EventType.visit:
        accentColor = const Color(0xFF00E5FF); // Visit: Cyan
        icon = Icons.domain;
        break;
      case EventType.highlight:
        accentColor = const Color(0xFF00FF87); // Highlight: Glowing Emerald
        icon = Icons.stars;
        break;
      case EventType.sightseeing:
        accentColor = const Color(0xFF4FACFE); // Sightseeing: Blue
        icon = Icons.photo_camera;
        break;
      case EventType.hotel:
        accentColor = const Color(0xFFFF7B00); // Hotel: Orange
        icon = Icons.hotel;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left column: Dot and vertical line
          Column(
            children: [
              // Circle node
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrent ? accentColor : const Color(0xFF141926),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent
                        ? Colors.white
                        : accentColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: isCurrent ? Colors.black : accentColor,
                ),
              ),
              // Vertical line connector
              Expanded(
                child: isLast
                    ? const SizedBox(height: 24)
                    : Container(
                        width: 2,
                        color: isCurrent
                            ? accentColor
                            : const Color(0xFF1E283C),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Right column: Content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _navigateToEventDetail(event),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF161F2E)
                        : const Color(0xFF121724),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent ? accentColor : const Color(0xFF1E283C),
                      width: isCurrent ? 1.5 : 1.0,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.05),
                              blurRadius: 12,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time Label
                          Text(
                            event.timeRange,
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          // Specific highlight marker tag
                          if (event.type == EventType.highlight)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF00FF87,
                                ).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(
                                    0xFF00FF87,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                'HIGHLIGHT',
                                style: TextStyle(
                                  color: Color(0xFF00FF87),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (event.bookingWarning != null)
                            const Icon(
                              Icons.warning,
                              size: 14,
                              color: Color(0xFFFFB300),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.55),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Read Details',
                            style: TextStyle(
                              fontSize: 11,
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION PANEL WITH MOCK CONTROLS & DATE/TIME BAR
  Widget _buildBottomPanel() {
    final active = _activeTime;
    final dateStr =
        "${active.year}-${active.month.toString().padLeft(2, '0')}-${active.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${active.hour.toString().padLeft(2, '0')}:${active.minute.toString().padLeft(2, '0')}";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C101A),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E283D), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsible/Expandable Control Slider sheet for Mock Date/Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF090D15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mock Time Toggle Switch
                Row(
                  children: [
                    const Icon(
                      Icons.timeline,
                      size: 18,
                      color: Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Time Travel Simulator',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        activeColor: const Color(0xFF00E5FF),
                        value: _isMockTimeEnabled,
                        onChanged: (val) {
                          setState(() {
                            _isMockTimeEnabled = val;
                            _updateSelectedDayFromCurrentTime();
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _isMockTimeEnabled
                        ? const Color(0xFF00E5FF).withOpacity(0.1)
                        : const Color(0xFF00FF87).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isMockTimeEnabled
                          ? const Color(0xFF00E5FF).withOpacity(0.4)
                          : const Color(0xFF00FF87).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _isMockTimeEnabled
                        ? 'SIMULATOR ACTIVE'
                        : 'LIVE DEVICE TIME',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: _isMockTimeEnabled
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF00FF87),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // If Mock Time is active, show the quick controller adjustment tools
          if (_isMockTimeEnabled) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              color: const Color(0xFF090D15),
              child: Column(
                children: [
                  const Divider(color: Color(0xFF1E283C), height: 10),
                  // Day slider (Jun 14 to Jun 19)
                  Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Select Date:',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_activeItinerary.length, (
                            index,
                          ) {
                            final dateDay = _activeItinerary[index].date.day;
                            final isSel = _mockTime.day == dateDay;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mockTime = DateTime(
                                    2026,
                                    6,
                                    dateDay,
                                    _mockTime.hour,
                                    _mockTime.minute,
                                  );
                                  _updateSelectedDayFromCurrentTime();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF9E00FF)
                                      : const Color(0xFF141926),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel
                                        ? Colors.white
                                        : const Color(0xFF222C3F),
                                  ),
                                ),
                                child: Text(
                                  "Jun $dateDay",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Hour adjustment slider
                  Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Hour (Time):',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF00E5FF),
                            inactiveTrackColor: const Color(0xFF1D283C),
                            thumbColor: Colors.white,
                            overlayColor: const Color(
                              0xFF00E5FF,
                            ).withOpacity(0.2),
                            trackHeight: 3.0,
                          ),
                          child: Slider(
                            min: 0,
                            max: 23,
                            divisions: 23,
                            value: _mockTime.hour.toDouble(),
                            onChanged: (val) {
                              setState(() {
                                _mockTime = DateTime(
                                  2026,
                                  6,
                                  _mockTime.day,
                                  val.toInt(),
                                  _mockTime.minute,
                                );
                                _updateSelectedDayFromCurrentTime();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          "${_mockTime.hour.toString().padLeft(2, '0')}:00",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Display Bar: active time status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0E1322),
              border: Border(top: BorderSide(color: Color(0xFF1D283E))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_alarm,
                      size: 16,
                      color: Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Trip Clock:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$dateStr  @ $timeStr',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E5FF),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  _isMockTimeEnabled ? 'MOCKING 2026' : 'SYSTEM LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _isMockTimeEnabled
                        ? const Color(0xFF9E00FF)
                        : const Color(0xFF00FF87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SIDEBAR SELECTOR DRAWER
  Widget _buildSidebarDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0C0F1A),
          border: Border(
            right: BorderSide(color: Color(0xFF1E283F), width: 1.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'SELECT A DAY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Trip Calendar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // List of Days
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _activeItinerary.length,
                itemBuilder: (context, index) {
                  final day = _activeItinerary[index];
                  final isSelected =
                      _currentSelectedDay?.dayNumber == day.dayNumber;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentSelectedDay = day;
                        });
                        Navigator.of(context).pop(); // smoothly close drawer!
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00E5FF).withOpacity(0.08)
                              : const Color(0xFF121724),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF1D283C),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF1E283C),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'D${day.dayNumber}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day.dateString,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFF00E5FF)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    day.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Time Travel Simulator toggle
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF141A29),
                    Color(0xFF0F131E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isMockTimeEnabled
                      ? const Color(0xFF00E5FF).withOpacity(0.5)
                      : const Color(0xFF1E283C),
                  width: 1.2,
                ),
                boxShadow: _isMockTimeEnabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.timeline,
                          size: 18,
                          color: _isMockTimeEnabled
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TIME SIMULATOR',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: _isMockTimeEnabled
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Time Travel Simulator',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      activeColor: const Color(0xFF00E5FF),
                      value: _isMockTimeEnabled,
                      onChanged: (val) {
                        setState(() {
                          _isMockTimeEnabled = val;
                          _updateSelectedDayFromCurrentTime();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Close button
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pop(), // smoothly close drawer!
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E283F),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Close Sidebar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NAVIGATION TO DETAILS PAGE
  void _navigateToEventDetail(TripEvent event) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventDetailPage(event: event),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// EVENT DETAIL PAGE WITH RICH TEXT DETAILS
class EventDetailPage extends StatelessWidget {
  final TripEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    String typeLabel;
    IconData typeIcon;

    switch (event.type) {
      case EventType.transit:
        typeColor = const Color(0xFF9E00FF);
        typeLabel = "TRANSIT & FLIGHT";
        typeIcon = Icons.flight;
        break;
      case EventType.food:
        typeColor = const Color(0xFFFFB300);
        typeLabel = "MICHELIN & DINING";
        typeIcon = Icons.restaurant_menu;
        break;
      case EventType.visit:
        typeColor = const Color(0xFF00E5FF);
        typeLabel = "CAMPUS & INNOVATION";
        typeIcon = Icons.domain;
        break;
      case EventType.highlight:
        typeColor = const Color(0xFF00FF87);
        typeLabel = "FUTURISTIC HIGHLIGHT";
        typeIcon = Icons.stars;
        break;
      case EventType.sightseeing:
        typeColor = const Color(0xFF4FACFE);
        typeLabel = "SIGHTSEEING CITY TOUR";
        typeIcon = Icons.photo_camera;
        break;
      case EventType.hotel:
        typeColor = const Color(0xFFFF7B00);
        typeLabel = "HOTEL CHECK-IN";
        typeIcon = Icons.hotel;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090C15),
      body: Stack(
        children: [
          // Background subtle glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Main Scrollable Area
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Immersive Cyberpunk App Bar with Event Category colors
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF090C15),
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Cover representing "Future Hub"
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              typeColor.withOpacity(0.3),
                              const Color(0xFF090C15),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Core category symbol
                      Center(
                        child: Icon(
                          typeIcon,
                          size: 70,
                          color: typeColor.withOpacity(0.6),
                        ),
                      ),
                      // Glass overlays
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: typeColor.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: typeColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time and Location Quick Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickInfoCard(
                              Icons.access_time_filled,
                              'TIME SCHEDULE',
                              event.timeRange,
                              typeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (event.location != null)
                            Expanded(
                              child: _buildQuickInfoCard(
                                Icons.place,
                                'LOCATION',
                                event.location!,
                                const Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // BOOKING ALERTS (WeChat mini-programs / Reservations)
                      if (event.bookingWarning != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF261912),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFB300).withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.gavel,
                                    color: Color(0xFFFFB300),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'BOOKING & ACCESS RULES (การจอง)',
                                    style: TextStyle(
                                      color: Color(0xFFFFB300),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.bookingWarning!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description Section (Thai Details)
                      const Text(
                        'ITINERARY INSTRUCTIONS (รายละเอียดกิจกรรม)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121622),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF1E263D)),
                        ),
                        child: Text(
                          event.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Highlights bullet points
                      if (event.highlights.isNotEmpty) ...[
                        const Text(
                          'KEY HIGHLIGHTS & TIPS (จุดห้ามพลาด & เกร็ดความรู้)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121622),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E263D)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: event.highlights.map((highlight) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: Icon(
                                        Icons.check_circle_outline,
                                        size: 14,
                                        color: typeColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        highlight,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Web/Media Resource links
                      if (event.externalLink != null) ...[
                        const Text(
                          'VIDEO & RESEARCH LINKS (คลิปตัวอย่าง & ลิงก์)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101B2B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.smart_display,
                                color: Color(0xFF00E5FF),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Watch Clip / Video Guide',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event.externalLink!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF00E5FF,
                                        ).withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // View details
                              const Icon(
                                Icons.open_in_new,
                                color: Color(0xFF00E5FF),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(
    IconData icon,
    String label,
    String value,
    Color themeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121622),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E263D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: themeColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
