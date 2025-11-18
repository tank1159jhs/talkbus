import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  // 1. SMS 코드 요청 (MOCK + Rate Limit)
  async requestSmsCode(phone: string) {
    // 최근 발급 이력 확인
    const recent = await this.prisma.sMSCode.findFirst({
      where: { phone },
      orderBy: { createdAt: 'desc' },
    });

    // 1분 이내 재요청 차단
    if (recent && Date.now() - recent.createdAt.getTime() < 60 * 1000) {
      throw new Error('Too many requests. Please wait a minute.');
    }

    // 인증 코드 생성
    const code = Math.floor(100000 + Math.random() * 900000).toString(); // 6자리 난수
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5분 유효

    await this.prisma.sMSCode.create({
      data: { phone, code, expiresAt },
    });

    // 👇 실제 SMS 발송 대신 콘솔 출력 (무료 MOCK 모드)
    console.log(`[MOCK SMS] ${phone} 로 인증 코드 전송: ${code}`);

    return {
      success: true,
      message: 'Verification code generated (mock mode)',
    };
  }

  // 2. 코드 검증 + JWT 발급
  async verifySmsCode(phone: string, code: string) {
    const smsCode = await this.prisma.sMSCode.findFirst({
      where: { phone, code, verified: false },
      orderBy: { createdAt: 'desc' },
    });

    if (!smsCode) throw new Error('Invalid code');
    if (smsCode.expiresAt < new Date()) throw new Error('Code expired');

    await this.prisma.sMSCode.update({
      where: { id: smsCode.id },
      data: { verified: true },
    });

    // 유저 없으면 자동 생성
    let user = await this.prisma.user.findUnique({ where: { email: phone } });
    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: phone,
          nickname: phone,
          passwordHash: 'sms-login',
        },
      });
    }

    // JWT 발급
    const payload = { sub: user.id, phone: user.email };
    const token = this.jwtService.sign(payload);

    return { success: true, token, user };
  }
}
