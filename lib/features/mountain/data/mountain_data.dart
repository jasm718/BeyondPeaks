import '../models/mountain.dart';

class MountainData {
  const MountainData._();

  static final fixedMountains = List<Mountain>.unmodifiable([
    Mountain(
      name: '珠穆朗玛峰',
      region: '喜马拉雅山脉',
      elevationMeters: 8848,
      latitude: 27.9881,
      longitude: 86.9250,
      defaultRouteName: '南坡经典路线',
      routeSummary: '经昆布冰川、洛子壁与南坳抵达顶峰的传统路线摘要。',
    ),
    Mountain(
      name: '乔戈里峰',
      region: '喀喇昆仑山脉',
      elevationMeters: 8611,
      latitude: 35.8808,
      longitude: 76.5158,
      defaultRouteName: '阿布鲁齐山脊',
      routeSummary: '沿东南山脊推进，穿越黑金字塔与肩部营地的路线摘要。',
    ),
    Mountain(
      name: '马特洪峰',
      region: '阿尔卑斯山脉',
      elevationMeters: 4478,
      latitude: 45.9763,
      longitude: 7.6586,
      defaultRouteName: '赫恩利山脊',
      routeSummary: '从采尔马特一侧沿赫恩利山脊攀登至顶峰的路线摘要。',
    ),
  ]);
}
