enum EventType { transit, visit, food, sightseeing, highlight, hotel }

class TripEvent {
  final String title;
  final String timeRange;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String description;
  final EventType type;
  final List<String> highlights;
  final String? bookingWarning;
  final String? externalLink;
  final String? location;

  const TripEvent({
    required this.title,
    required this.timeRange,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.description,
    required this.type,
    this.highlights = const [],
    this.bookingWarning,
    this.externalLink,
    this.location,
  });

  bool isActiveAt(DateTime time) {
    final eventStart = DateTime(
      time.year,
      time.month,
      time.day,
      startHour,
      startMinute,
    );
    final eventEnd = DateTime(
      time.year,
      time.month,
      time.day,
      endHour,
      endMinute,
    );
    return time.isAfter(eventStart) && time.isBefore(eventEnd) ||
        time.isAtSameMomentAs(eventStart);
  }

  bool isUpcomingAfter(DateTime time) {
    final eventStart = DateTime(
      time.year,
      time.month,
      time.day,
      startHour,
      startMinute,
    );
    return eventStart.isAfter(time);
  }
}

class TripDay {
  final int dayNumber;
  final DateTime date;
  final String dateString;
  final String title;
  final String transportDetail;
  final List<TripEvent> events;

  const TripDay({
    required this.dayNumber,
    required this.date,
    required this.dateString,
    required this.title,
    required this.transportDetail,
    required this.events,
  });
}

class ItineraryData {
  static final List<TripDay> itinerary = [
    TripDay(
      dayNumber: 1,
      date: DateTime(2026, 6, 14),
      dateString: "Jun 14 (Sun)",
      title: "Departure BKK ➔ Guangzhou",
      transportDetail: "Flight BKK to CAN",
      events: [
        TripEvent(
          title: "Departure BKK to Guangzhou (Flight Selection)",
          timeRange: "15:55 - 23:00",
          startHour: 15,
          startMinute: 55,
          endHour: 23,
          endMinute: 0,
          type: EventType.transit,
          location:
              "Suvarnabhumi Airport (BKK) / Don Mueang (DMK) to Guangzhou Baiyun (CAN)",
          description:
              "เที่ยวบินเดินทางจากกรุงเทพฯ ไปยังกวางโจว มีตัวเลือกเที่ยวบินดังนี้:\n"
              "• China Southern Airline (CZ3082): 15:55 - 20:00 น.\n"
              "• Air Asia (FD530): 19:05 - 23:00 น. (จากดอนเมือง)",
          highlights: [
            "เตรียมพาสปอร์ตให้พร้อมสำหรับการเช็กอิน",
            "เที่ยวบินใช้เวลาประมาณ 3 ชั่วโมงถึง 4 ชั่วโมง",
            "แนะนำเผื่อเวลาเช็กอินล่วงหน้าอย่างน้อย 3 ชั่วโมงที่สนามบิน",
          ],
        ),
      ],
    ),
    TripDay(
      dayNumber: 2,
      date: DateTime(2026, 6, 15),
      dateString: "Jun 15 (Mon)",
      title: "GZ Explorer - Science & Culture",
      transportDetail: "เช่ารถเต็มวัน (Full-day Private Car Rental)",
      events: [
        TripEvent(
          title: "Visit HKUST-Guangzhou Campus",
          timeRange: "09:00 - 11:00",
          startHour: 9,
          startMinute: 0,
          endHour: 11,
          endMinute: 0,
          type: EventType.visit,
          location: "HKUST-GZ Nansha Campus",
          bookingWarning:
              "ใช้พาสปอร์ตทั้ง 8 เล่ม ลงทะเบียนที่ป้อมยามหน้าประตูแคมปัสเพื่อเข้าชมฟรีได้เลย",
          description:
              "เข้าชมวิทยาเขตอัจฉริยะยุคใหม่ของมหาวิทยาลัยวิทยาศาสตร์และเทคโนโลยีฮ่องกง ณ กวางโจว (HKUST-GZ) ที่เพิ่งเปิดใหม่เมื่อปี 2022 โดดเด่นด้วยสถาปัตยกรรมล้ำสมัยระดับโลก",
          highlights: [
            "สถาปัตยกรรมตึกทรงกลมไซไฟระดับแลนด์มาร์ก",
            "ระบบพลังงานสะอาดที่เป็นมิตรต่อสิ่งแวดล้อม",
            "ชมชมรถบัสไร้คนขับและหุ่นยนต์จัดส่งอัจฉริยะวิ่งทั่วมหาวิทยาลัย",
          ],
        ),
        TripEvent(
          title: "Lunch: มื้อเที่ยงง่ายๆ ใน Guangdong",
          timeRange: "11:00 - 12:00",
          startHour: 11,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
          type: EventType.food,
          location: "Guangdong Local Restaurant",
          description:
              "รับประทานอาหารกลางวันเมนูท้องถิ่นกวางตุ้งแบบง่ายๆ รวดเร็ว เพื่อเตรียมตัวไปตะลุยศูนย์วิทยาศาสตร์ต่อในช่วงบ่าย",
          highlights: [
            "อาหารจานด่วนสไตล์กวางตุ้งแท้ๆ",
            "ประหยัดเวลาและพลังงานเพื่อลุยกิจกรรมบ่าย",
          ],
        ),
        TripEvent(
          title: "Guangdong Science Center (ศูนย์วิทยาศาสตร์มณฑลกวางตุ้ง)",
          timeRange: "12:00 - 17:00",
          startHour: 12,
          startMinute: 0,
          endHour: 17,
          endMinute: 0,
          type: EventType.highlight,
          location: "Guangdong Science Center, Panyu District",
          externalLink: "https://www.youtube.com/watch?v=TJurGYV-wPA",
          description:
              "ศูนย์วิทยาศาสตร์ที่ได้รับการบันทึกสถิติโลกว่าใหญ่ที่สุดในโลก! เหมาะสำหรับผู้ที่ชื่นชอบเทคโนโลยี การจำลองเสมือนจริง และนวัตกรรมอวกาศ",
          highlights: [
            "Digital Pioneer Pavilion และ Robot World แสดงหุ่นยนต์เต้นและเล่นหมากรุก",
            "เครื่องเล่นแนวล้ำๆ ยานจำลองเสมือนจริง (VR Simulators) และรถไฟเหาะจำลอง",
            "โรงภาพยนตร์ 4D และโรงภาพยนตร์โดมลูกยักษ์ที่ล้ำสมัยมาก",
          ],
        ),
        TripEvent(
          title: "Tram City Tour Canton Tower ⇔ Wanshengwei",
          timeRange: "18:00 - 19:00",
          startHour: 18,
          startMinute: 0,
          endHour: 19,
          endMinute: 0,
          type: EventType.sightseeing,
          location: "Canton Tower Tram Station",
          externalLink:
              "https://www.tiktok.com/@9journeychina/video/7559427176676756754",
          description:
              "นั่งรถราง (Tram) ชมเมืองวิ่งเลียบแม่น้ำจูเจียง ไป-กลับระหว่างสถานี Canton Tower และ Wanshengwei สัมผัสทัศนียภาพของเมืองกวางโจวยุคใหม่ริมสองฝั่งน้ำ",
          highlights: [
            "วิวมุมกว้างของแม่น้ำและตึกระฟ้าตระการตา",
            "นั่งผ่านย่าน Pazhou Internet Innovation Zone ที่ตั้งของบิ๊กเทคจีน",
            "จบทริปที่แลนด์มาร์กอันงดงามอย่าง Canton Tower",
          ],
        ),
        TripEvent(
          title: "Pazhou Internet Innovation Zone & Riverside Walk",
          timeRange: "19:00 - 20:00",
          startHour: 19,
          startMinute: 0,
          endHour: 20,
          endMinute: 0,
          type: EventType.sightseeing,
          location: "Pazhou Riverside, Yuejiang Middle Road",
          description:
              "เดินเล่นรับลมยามค่ำคืนในย่านสำนักงานใหญ่เทคโนโลยีระดับโลก เช่น Alibaba, Tencent, และ Xiaomi ซึ่งประดับประดาด้วยระบบไฟดิจิทัลที่งดงาม ดีไซน์ตึกรูปทรงแปลกตา",
          highlights: [
            "จุดถ่ายภาพตึกระฟ้า Tech สะท้อนบนผิวน้ำจูเจียง",
            "มองเห็นรถรางสายโรแมนติกแล่นผ่านคู่กับสะพานสวยงาม",
            "บรรยากาศริมน้ำที่ผ่อนคลายและล้ำสมัยในเวลาเดียวกัน",
          ],
        ),
        TripEvent(
          title: "Dinner: Dianduode (Michelin Dimsum)",
          timeRange: "20:00 - 22:00",
          startHour: 20,
          startMinute: 0,
          endHour: 22,
          endMinute: 0,
          type: EventType.food,
          location: "Dianduode (点都德)",
          description:
              "ลิ้มลองติ่มซำกวางตุ้งแบบดั้งเดิมระดับมิชลินไกด์อันโด่งดัง เมนูหลากหลาย รสชาติละมุนลิ้น บรรยากาศร้านตกแต่งสไตล์คลาสสิก",
          highlights: [
            "เมนูขึ้นชื่อ: ก๋วยเตี๋ยวหลอดกุ้งทอดกรอบ (หนังบางแต่ไส้กรอบแน่น)",
            "ขนมจีบกุ้งจักรพรรดิคำโต และซาลาเปาลาวาไข่เค็มไส้ทะลัก",
            "มาเป็นกรุ๊ปใหญ่ 8 คน สั่งแชร์และชิมได้หลายเมนูอย่างสนุกสนาน",
          ],
        ),
      ],
    ),
    TripDay(
      dayNumber: 3,
      date: DateTime(2026, 6, 16),
      dateString: "Jun 16 (Tue)",
      title: "SZ Arrival - Tech Parks & Lights",
      transportDetail: "High Speed Train + Subway + Didi taxi",
      events: [
        TripEvent(
          title: "High Speed train: GZ South to Futian",
          timeRange: "10:00 - 11:30",
          startHour: 10,
          startMinute: 0,
          endHour: 11,
          endMinute: 30,
          type: EventType.transit,
          location:
              "Guangzhou South Railway Station to Futian Station, Shenzhen",
          bookingWarning:
              "ต้องจองล่วงหน้าผ่านแอป (เช่น Trip.com) 14 วันล่วงหน้า เพื่อล็อกที่นั่งตู้เดียวกันสำหรับกรุ๊ป 8 คน",
          description:
              "เดินทางเข้าสู่เมืองเซินเจิ้น (Shenzhen) ด้วยรถไฟความเร็วสูงที่ทันสมัยและเงียบสงบ ใช้เวลาเพียงประมาณ 1.5 ชั่วโมง มาลงใจกลางเมืองที่สถานีฟูเถียน (Futian)",
          highlights: [
            "ประสบการณ์เดินทางด้วยรถไฟความเร็วสูงสไตล์จีน",
            "ลงกลางย่าน CBD ที่สถานีใต้ดิน Futian ที่ใหญ่ที่สุดแห่งหนึ่ง",
          ],
        ),
        TripEvent(
          title: "Lunch: Anhui Kitchen (สาขา One Avenue)",
          timeRange: "12:00 - 14:00",
          startHour: 12,
          startMinute: 0,
          endHour: 14,
          endMinute: 0,
          type: EventType.food,
          location: "Anhui Kitchen, One Avenue Mall",
          description:
              "ทานมื้อเที่ยงสไตล์อันฮุยดั้งเดิมเกรดพรีเมียม (Anhui Cuisine) หนึ่งใน 8 ตระกูลอาหารจีนที่หาทานได้ยาก ตกแต่งร้านสไตล์หรูหราคลาสสิก",
          highlights: [
            "โต๊ะกลมขนาดใหญ่ที่พร้อมรองรับกรุ๊ป 8 คนแบบอบอุ่นและเป็นส่วนตัว",
            "เมนูห้ามพลาด: 'ไก่อบโอ่งฮวงซาน' (Huangshan Clay Pot Chicken) หนังบางกรอบ เนื้อฉ่ำน้ำชวนชิม",
            "เมนูเด่น: ปลาต้มซอสสูตรโบราณ รสชาติเข้มข้น กลมกล่อม เค็มมันลึกซึ้ง",
          ],
        ),
        TripEvent(
          title: "Visit HKU Business School at Media Finance Center",
          timeRange: "14:30 - 16:30",
          startHour: 14,
          startMinute: 30,
          endHour: 16,
          endMinute: 30,
          type: EventType.visit,
          location: "Media Finance Center, Futian",
          bookingWarning:
              "เข้าฟรี! เป็นอาคารนวัตกรรมในย่านธุรกิจ เดินชมสถาปัตยกรรมภายนอกและเข้าเยี่ยมบริเวณล็อบบี้ได้",
          description:
              "เข้าเยี่ยมชมสถาบันนวัตกรรมฝั่งจีนแผ่นดินใหญ่ของมหาวิทยาลัยฮ่องกง (HKU Business School - Shenzhen Campus) ตั้งอยู่บนตึกสูงทันสมัยใจกลางศูนย์กลางการเงิน",
          highlights: [
            "ศึกษาศูนย์กลางบ่มเพาะนวัตกรรมทางการเงินและไอทีระดับภูมิภาค",
            "การตกแต่งภายในที่เน้นเทคโนโลยี สไตล์มินิมอลและดูเป็นมืออาชีพ",
          ],
        ),
        TripEvent(
          title: "Shenzhen Talent Park (Drone & Robot Booth)",
          timeRange: "17:00 - 19:00",
          startHour: 17,
          startMinute: 0,
          endHour: 19,
          endMinute: 0,
          type: EventType.highlight,
          location: "Shenzhen Talent Park, Nanshan",
          externalLink: "https://www.youtube.com/watch?v=2UTNCsh9sPM",
          description:
              "สวนสาธารณะธีมเทคโนโลยีที่เป็นไฮไลต์สำคัญ ตั้งอยู่ริมชายฝั่งทะเลหนานซาน สัมผัสไลฟ์สไตล์การพักผ่อนควบคู่ไปกับนวัตกรรมล้ำหน้าของเซินเจิ้น",
          highlights: [
            "การสาธิตการจัดส่งของด้วยโดรนอัจฉริยะ (Meituan Drone Delivery)",
            "หุ่นยนต์และอุปกรณ์ตอบโต้ระบบ AI ที่บูธนวัตกรรมรอบสวน",
            "บรรยากาศชิลล์ๆ ชมสะพานและตึกสูงสวยงามในช่วงพลบค่ำ",
          ],
        ),
        TripEvent(
          title: "Dinner: Shenzhen Bay MixC Mall",
          timeRange: "19:00 - 20:00",
          startHour: 19,
          startMinute: 0,
          endHour: 20,
          endMinute: 0,
          type: EventType.food,
          location: "Shenzhen Bay MixC Mall",
          description:
              "เดินเท้าจากสวนสาธารณะไปยังห้างหรู MixC Mall ที่ตั้งอยู่ข้างกัน เลือกทานมื้อค่ำจากร้านอาหารชื่อดังมากมายในบรรยากาศพรีเมียม",
          highlights: [
            "แหล่งรวมร้านอาหารมิชลินและแบรนด์ดังระดับโลก",
            "ดีไซน์ห้างหรูหรา ทันสมัย มีพื้นที่อินดอร์และเอาท์ดอร์สวยงาม",
          ],
        ),
        TripEvent(
          title: "Shenzhen Talent Park (Lighting Show)",
          timeRange: "20:00 - 21:30",
          startHour: 20,
          startMinute: 0,
          endHour: 21,
          endMinute: 30,
          type: EventType.sightseeing,
          location: "Shenzhen Talent Park Lake View",
          description:
              "ชมการเปิดไฟระบบดิจิทัลและแสงสี (Digital Lighting Art) จากกลุ่มตึกระฟ้าของย่านโฮมคอร์ทแอลอีดีสะท้อนผิวน้ำในทะเลสาบของสวน สวยงามอลังการตาอย่างยิ่ง",
          highlights: [
            "ตึกสำนักงานใหญ่ของ China Resources (ตึกหน่อไม้ฝรั่ง) เปิดไฟวิบวับสวยงาม",
            "เงาสะท้อนน้ำที่ระยิบระยับเป็นมุมยอดนิยมในการถ่ายภาพหมู่",
          ],
        ),
      ],
    ),
    TripDay(
      dayNumber: 4,
      date: DateTime(2026, 6, 17),
      dateString: "Jun 17 (Wed)",
      title: "Robo-Taxis & Mind-Control Tech",
      transportDetail: "Robo taxi (Baidu) + Didi taxi",
      events: [
        TripEvent(
          title: "Visit CUHK-Shenzhen & Robo Taxi Experience",
          timeRange: "09:00 - 12:00",
          startHour: 9,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
          type: EventType.visit,
          location: "CUHK-Shenzhen Campus",
          bookingWarning:
              "แคมปัสเปิด ยื่นพาสปอร์ตลงทะเบียนเข้าชมฟรีอย่างอิสระได้ที่หน้าทางเข้า",
          description:
              "ชมมหาวิทยาลัยไชนีสแห่งฮ่องกง ณ เซินเจิ้น (CUHK-Shenzhen) ที่ผสมผสานความเป็นธรรมชาติและเทคโนโลยีสีเขียวได้อย่างลงตัว พร้อมทดลองเรียก Robo Taxi ไร้คนขับ",
          highlights: [
            "ห้องสมุดแลนด์มาร์กสุดตระการตาที่ออกแบบด้วยแรงบันดาลใจจากชั้นหินธรรมชาติ",
            "ระบบจัดการ Smart Campus และแคมปัสสีเขียวชอุ่มน่าเรียนรู้",
            "สัมผัส Robo Taxi: ลองใช้แอป Baidu Apollo Go (萝卜快跑) หรือฟีเจอร์ Autonomous Driving ในแอป Didi บริเวณมหาวิทยาลัย มุ่งหน้าสู่ห้าง Galaxy World COCO Park",
          ],
        ),
        TripEvent(
          title: "Lunch: Tai Er Sauerkraut Fish",
          timeRange: "12:00 - 14:00",
          startHour: 12,
          startMinute: 0,
          endHour: 14,
          endMinute: 0,
          type: EventType.food,
          location: "Tai Er Sauerkraut Fish, Galaxy World COCO Park",
          description:
              "ทานมื้อเที่ยงยอดนิยมของชาวจีนและนักท่องเที่ยวด้วยเมนูปลาต้มผักกาดดองรสเปรี้ยวเผ็ดจัดจ้านสะใจ น้ำซุปเข้มข้น หอมกลิ่นเครื่องเทศเสฉวน",
          highlights: [
            "เนื้อปลาช่อนเทศนุ่มไร้ก้าง ลอยในน้ำมันโรยกลีบเบญจมาศแสนสวย",
            "บริการด้วยระบบเทคโนโลยี QR สั่งซื้อและบริการผ่าน AI สะดวกสบาย",
          ],
        ),
        TripEvent(
          title: "Robot 6S Store at Galaxy World COCO Park",
          timeRange: "14:30 - 17:00",
          startHour: 14,
          startMinute: 30,
          endHour: 17,
          endMinute: 0,
          type: EventType.highlight,
          location: "Galaxy World COCO Park, Longgang",
          bookingWarning:
              "ซื้อหน้างานได้! ค่าเข้าโซนทัวร์เอง (Self-tour) ประมาณ 50 RMB/คน ซื้อและหยอดเหรียญหน้าตู้คลื่นสมองได้เลย",
          externalLink: "https://www.youtube.com/watch?v=Xunat7lf6AM",
          description:
              "ไฮไลต์ระดับสุดยอด! โชว์รูมหุ่นยนต์เชิงพาณิชย์ 6S แห่งแรกของโลก มีการนำหุ่นยนต์รูปแบบต่างๆ มาจัดแสดงและเปิดให้ผู้เข้าใช้งานได้มีปฏิสัมพันธ์จริง",
          highlights: [
            "14:30 น.: ไปถึงหน้าสโตร์เพื่อจองมุมถ่ายรูปสำหรับกลุ่ม 8 คน",
            "15:00 น.: ชมโชว์ฟรี! หุ่นยนต์ฮิวแมนนอยด์คู่กับสุนัขกล 4 ขาเต้นและแปรขบวนตามเพลงสุดเท่ (10 นาที)",
            "15:15 น.: ลุยด้านในสโตร์ ทดลองใช้จอยควบคุมสุนัขกลเดินและตีลังกา, สั่งไอศกรีม/เครปจีนที่ทำด้วยแขนกลอัจฉริยะ 100%, ชมหุ่นยนต์ขยับสีหน้าเลียนแบบมนุษย์, และลองนอนให้แขนกลอัจฉริยะนวดกดจุดแก้เมื่อย",
            "16:00 น. (โซนสมอง Brain-Hack): สวมอุปกรณ์ EEG Headband ทดลองเล่นเกมแข่งรถพลังจิต หรือคีบตุ๊กตาผ่านสมาธิและคลื่นสมองร่วมกัน",
          ],
        ),
        TripEvent(
          title: "Houlang Xintiandi Community Mall",
          timeRange: "17:15 - 18:15",
          startHour: 17,
          startMinute: 15,
          endHour: 18,
          endMinute: 15,
          type: EventType.sightseeing,
          location: "Houlang Xintiandi",
          description:
              "คอมมูนิตี้มอลล์ไลฟ์สไตล์แบบเปิดกว้าง แหล่งรวมตัวยอดฮิตของวัยรุ่นสร้างสรรค์ในเซินเจิ้น เดินชมนวัตกรรมการผสมผสานระหว่างเทคโนโลยีเข้ากับพื้นที่เมือง",
          highlights: [
            "Smart Pillar: เสาไฟอัจฉริยะอเนกประสงค์ระบบ 5G และเซนเซอร์รอบตัว",
            "AI 3D Car Park: ชมตึกจอดรถระบายพลังงานอัตโนมัติและเคลื่อนย้ายรถด้วยระบบหุ่นยนต์ 3 มิติสุดล้ำ",
          ],
        ),
        TripEvent(
          title: "Dinner & Cyberpunk Huaqiangbei Pedestrian Street",
          timeRange: "19:00 - 22:00",
          startHour: 19,
          startMinute: 0,
          endHour: 22,
          endMinute: 0,
          type: EventType.highlight,
          location: "Huaqiangbei & Zhonghangcheng Junction Mall",
          description:
              "สัมผัสยามค่ำคืนในบรรยากาศธีม Cyberpunk ไฟนีออนสีสันฉูดฉาด ถนนคนเดินที่เต็มไปด้วยแผงลอยแกดเจ็ตแปลกๆ ตู้คีบตุ๊กตาอัจฉริยะ และของกินสตรีทฟู้ดมื้อดึก",
          highlights: [
            "ถ่ายรูปกลุ่มคู่กับ 'จอ 3D ทะลุจอไร้แว่นตา' (Naked-Eye 3D Screen) ขนาดมหึมาหน้าห้าง Zhonghangcheng Junction Mall",
            "ห้างสรรพสินค้าเปิดถึง 22:00 น. สามารถเข้าชมเทคโนโลยีตกแต่งภายในที่ล้ำสมัย",
            "ชิมอาหารเสียบไม้และสตรีทฟู้ดสไตล์เซินเจิ้นยามดึกท่ามกลางตึกนีออน",
          ],
        ),
      ],
    ),
    TripDay(
      dayNumber: 5,
      date: DateTime(2026, 6, 18),
      dateString: "Jun 18 (Thu)",
      title: "Science, Electronics & Ocean View",
      transportDetail: "เช่ารถเต็มวัน (Full-day Private Car Rental)",
      events: [
        TripEvent(
          title: "Shenzhen Science and Technology Museum",
          timeRange: "09:00 - 12:00",
          startHour: 9,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
          type: EventType.visit,
          location: "Shenzhen Science & Technology Museum (New Building)",
          bookingWarning:
              "ต้องจองตั๋วล่วงหน้าพิเศษ 3-7 วัน ผ่านมินิโปรแกรมใน WeChat หรือแพลตฟอร์มท่องเที่ยวทางการ",
          description:
              "เข้าชมนิทรรศการในอาคารพิพิธภัณฑ์วิทยาศาสตร์และเทคโนโลยีแห่งใหม่ล่าสุด ดีไซน์แบบล้ำยุค ผนวกห้องแสดงนิทรรศการฟิสิกส์ ชีววิทยา อวกาศ และพลังงานหมุนเวียน",
          highlights: [
            "การจัดแสดงปฏิสัมพันธ์ด้านวิทยาศาสตร์ที่ตื่นตาและอัจฉริยะ",
            "ห้องปฏิบัติการและวิจัยจำลองด้านปัญญาประดิษฐ์ (AI Area)",
          ],
        ),
        TripEvent(
          title: "Lunch: Muwu Barbecue (สาขา Zhenhua)",
          timeRange: "12:00 - 14:00",
          startHour: 12,
          startMinute: 0,
          endHour: 14,
          endMinute: 0,
          type: EventType.food,
          location: "Muwu Barbecue, Zhenhua Road",
          description:
              "รับประทานปิ้งย่างสไตล์ป่าเตาถ่านหม่าล่ารสชาติจัดจ้าน ดุเดือด และดังที่สุดในเซินเจิ้น บรรยากาศสนุกสนาน ครึกครื้น สั่งแชร์กันเป็นสิบๆ ไม้",
          highlights: [
            "เมนูขึ้นชื่อ: หมูสามชั้นย่างกระเทียมพริกหม่าล่า เนื้อวัวสไลด์ย่าง และหอยนางรมย่างกระเทียมฉ่ำๆ เตาใหญ่",
            "เลือกผักย่างเสียบไม้คลุกผงปิ้งย่างสูตรเด็ดของทางร้าน",
          ],
        ),
        TripEvent(
          title: "Huaqiangbei Electronics Market Deep Dive",
          timeRange: "14:00 - 15:30",
          startHour: 14,
          startMinute: 0,
          endHour: 15,
          endMinute: 30,
          type: EventType.visit,
          location: "SEG Plaza / Huaqiang Electronic World",
          description:
              "เดินสำรวจเมกกะสินค้าและส่วนประกอบอิเล็กทรอนิกส์ที่ใหญ่ที่สุดในโลก เยี่ยมชมชั้นที่ขายชิ้นส่วนโครงสร้างหุ่นยนต์, บอร์ดควบคุม AI, และฮาร์ดแวร์ประมวลผลอัจฉริยะ",
          highlights: [
            "ละลานตาไปกับหุ่นยนต์ฮิวแมนนอยด์ขนาดเล็กและชิ้นส่วนกลไกที่มีให้เลือกสรรทุกแบบ",
            "สัมผัสเบื้องหลังกระบวนการผลิตและซัพพลายเชนฮาร์ดแวร์ระดับโลกของเซินเจิ้น",
          ],
        ),
        TripEvent(
          title: "OH Bay Shenzhen & Sunset Ferris Wheel",
          timeRange: "15:30 - 20:00",
          startHour: 15,
          startMinute: 30,
          endHour: 20,
          endMinute: 0,
          type: EventType.highlight,
          location: "OH Bay, Bao'an District",
          bookingWarning:
              "แนะนำให้กดซื้อตั๋ว E-ticket สำหรับชิงช้าสวรรค์ผ่านแอปบนโทรศัพท์มือถือขณะเดินทาง เพื่อเลี่ยงคิวสำหรับกลุ่มใหญ่ 8 คน",
          description:
              "ผ่อนคลายริมอ่าวพรีเมียม สัมผัสความผสมผสานระหว่างสถาปัตยกรรมล้ำสมัย ศิลปะ และธรรมชาติริมน้ำยามพระอาทิตย์ตกดิน",
          highlights: [
            "ร้านหนังสือ Zhongshuge: ดีไซน์ชั้นวางหนังสือเป็นบันไดเกลียวคดเคี้ยววนรอบห้อง ถ่ายรูปมุมอาร์ตสุดวิเศษ",
            "eVTOL Expo: ชมนิทรรศการและโมเดลจำลองของโดรนโดยสารไฟฟ้าอัจฉริยะ (Flying Taxi) ริมชายทะเล",
            "ชิงช้าสวรรค์ Bay Glory (Bao'an Ferris Wheel): นั่งชมวิวอ่าว 360 องศา พาโนรามาลอยฟ้าเหนือระดับน้ำทะเล",
            "ชมการประดับไฟ แสงสี และการแสดงโดรนเหนือน่านน้ำ (ขึ้นกับสภาพอากาศในวันนั้น)",
          ],
        ),
        TripEvent(
          title: "Dinner: Xinxian Beef Brisket Hotpot",
          timeRange: "20:00 - 22:00",
          startHour: 20,
          startMinute: 0,
          endHour: 22,
          endMinute: 0,
          type: EventType.food,
          location: "Xinxian Beef Brisket Hotpot",
          description:
              "หม้อไฟเนื้อตุ๋นระดับมิชลินไกด์คัดสรรวัตถุดิบเนื้อเกรดดีเยี่ยม น้ำซุปเนื้อต้มสมุนไพรหอมกรุ่น กลมกล่อม อุ่นสบายท้องหลังจากรับลมริมทะเล",
          highlights: [
            "เนื้อสามชั้นลายสวยสไลด์บางลวกจิ้มพอสุกละลายในปาก",
            "เนื้อตุ๋นส่วนแก้มและเอ็นเนื้อเปื่อยละมุนเข้มข้นถึงใจ",
          ],
        ),
      ],
    ),
    TripDay(
      dayNumber: 6,
      date: DateTime(2026, 6, 19),
      dateString: "Jun 19 (Fri)",
      title: "Digital Twins & Departure",
      transportDetail: "Didi 2 cars / Airport Transfer",
      events: [
        TripEvent(
          title: "MOCAPE (Museum of Contemporary Art & Urban Planning)",
          timeRange: "09:00 - 11:30",
          startHour: 9,
          startMinute: 0,
          endHour: 11,
          endMinute: 30,
          type: EventType.visit,
          location: "MOCAPE, Futian District",
          externalLink: "https://www.youtube.com/watch?v=2UTNCsh9sPM",
          description:
              "ตึกสถาปัตยกรรมรูปทรงอิสระ (Freeform Sci-Fi) ภายในนำเสนอศิลปะร่วมสมัยและแผนผังเมืองแห่งอนาคตของเซินเจิ้น",
          highlights: [
            "โมเดลเมืองเซินเจิ้นแบบ 3D Digital Twin ประกอบแสงสีเสียงดิจิทัลสุดตระการตา",
            "ชมการผสานระบบการจัดการ Smart City บิ๊กดาต้าเข้ากับวิถีชีวิตผู้คน",
            "สถาปัตยกรรมเหล็กคดเคี้ยวภายในตึกที่ได้รับการยอมรับระดับนานาชาติ",
          ],
        ),
        TripEvent(
          title: "Lunch: Ba Shu Feng Yue (อาหารเสถวน)",
          timeRange: "12:00 - 14:00",
          startHour: 12,
          startMinute: 0,
          endHour: 14,
          endMinute: 0,
          type: EventType.food,
          location: "Ba Shu Feng Yue (巴蜀风月)",
          description:
              "ลิ้มรสอาหารเสฉวนสไตล์ร่วมสมัย ตกแต่งร้านเรียบหรูสไตล์จีนโมเดิร์น รสจัดจ้าน เผ็ดชาเป็นเอกลักษณ์โดดเด่น",
          highlights: [
            "โต๊ะกลมขนาดใหญ่รองรับกลุ่ม 8 คนได้อย่างสบายใจและเป็นส่วนตัว",
            "เมนูขึ้นชื่อ: ไก่ผัดพริกแห้งเสฉวน (Laziji) กรอบนอกนุ่มใน หอมเผ็ดร้อนพริกเสฉวน",
            "เมนูเด่น: เต้าหู้มาโป (Mapo Tofu) รสชาติเข้มข้นสะใจ ทานคู่กับข้าวสวยร้อนๆ เข้ากันสุดๆ",
          ],
        ),
        TripEvent(
          title: "Shenzhen Civic Center Sightseeing",
          timeRange: "14:30 - 15:30",
          startHour: 14,
          startMinute: 30,
          endHour: 15,
          endMinute: 30,
          type: EventType.sightseeing,
          location: "Shenzhen Civic Center, Futian",
          description:
              "เยี่ยมชมและเก็บภาพกลุ่ม ณ พลาซ่าจัตุรัสกลางเมืองเซินเจิ้น โดดเด่นด้วยตึกที่ทำการหลังคาทรงปีกนกอินทรีย์เหยียดสยาย สัญลักษณ์แห่งการทะยานขึ้นของเมือง",
          highlights: [
            "จุดศูนย์กลางแนวราบเส้นแกนประธานของเซินเจิ้นที่ยาวเหยียดไร้ตึกบังสายตา",
            "ถ่ายภาพพาโนรามาคู่กับฉากหลังตึกระฟ้าของย่าน CBD",
          ],
        ),
        TripEvent(
          title: "Travel to Shenzhen Airport (SZX) & Flight to BKK",
          timeRange: "17:00 - 23:59",
          startHour: 17,
          startMinute: 0,
          endHour: 23,
          endMinute: 59,
          type: EventType.transit,
          location: "Shenzhen Bao'an International Airport (SZX) to BKK",
          description:
              "เดินทางไปสนามบินเตรียมเช็กอินเดินทางกลับกรุงเทพฯ (ไฟลท์เดินทางตอนค่ำ) สรุปตัวเลือกไฟลท์กลับ:\n"
              "• China Southern (CZ8083): 22:55 - 01:40 น.\n"
              "• AirAsia (FD597): 23:30 - 01:15 น.",
          highlights: [
            "ออกเดินทางไปสนามบินเผื่อเวลาล่วงหน้าอย่างน้อย 3 ชั่วโมง",
            "จัดการเคลียร์คืนอุปกรณ์ ช้อปปิ้งของฝากที่สนามบินช่วงค่ำก่อนขึ้นเครื่อง",
          ],
        ),
      ],
    ),
  ];

  static TripDay? getSelectedDayForDateTime(DateTime dt, List<TripDay> list) {
    for (var day in list) {
      if (day.date.year == dt.year &&
          day.date.month == dt.month &&
          day.date.day == dt.day) {
        return day;
      }
    }
    return null;
  }
}
