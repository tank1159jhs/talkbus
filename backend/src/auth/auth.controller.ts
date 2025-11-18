import {
  Body,
  Controller,
  Post,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Controller('auth')
export class AuthController {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  // ✅ 게스트 로그인
  @Post('guest')
  async guestLogin() {
    // 랜덤 닉네임 생성
    const nickname = `게스트${Math.floor(1000 + Math.random() * 9000)}`;

    const user = await this.prisma.user.create({
      data: {
        nickname,
        isGuest: true,
      },
    });

    const payload = { sub: user.id, guest: true };
    const token = this.jwtService.sign(payload);

    return {
      success: true,
      token,
      user: {
        id: user.id,
        nickname: user.nickname,
        isGuest: user.isGuest,
      },
    };
  }

  // ✅ 회원가입 (게스트 → 정식 계정 업그레이드 포함)
  @Post('register')
  async register(
    @Body('email') email: string,
    @Body('password') password: string,
    @Body('guestId') guestId?: string, // 게스트 업그레이드용
  ) {
    // 이메일 중복 체크
    const exists = await this.prisma.user.findUnique({ where: { email } });
    if (exists) {
      throw new BadRequestException('이미 가입된 이메일입니다.');
    }

    if (!password || password.length < 6) {
      throw new BadRequestException('비밀번호는 최소 6자 이상이어야 합니다.');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    let user;
    if (guestId) {
      // 게스트 계정 업그레이드
      user = await this.prisma.user.update({
        where: { id: guestId },
        data: {
          email,
          passwordHash: hashedPassword,
          isGuest: false,
        },
      });
    } else {
      // 신규 계정 생성
      user = await this.prisma.user.create({
        data: {
          email,
          passwordHash: hashedPassword,
          isGuest: false,
        },
      });
    }

    const { passwordHash, ...safeUser } = user;
    return { success: true, user: safeUser };
  }

  // ✅ 로그인
  @Post('login')
  async login(
    @Body('email') email: string,
    @Body('password') password: string,
  ) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) throw new UnauthorizedException('존재하지 않는 사용자');

    if (!user.passwordHash) {
      throw new UnauthorizedException('게스트 계정은 이메일/비번 로그인 불가');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('비밀번호 불일치');
    }

    const payload = { sub: user.id, email: user.email };
    const token = this.jwtService.sign(payload);

    const { passwordHash, ...safeUser } = user;
    return { success: true, token, user: safeUser };
  }
}
