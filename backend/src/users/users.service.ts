import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  // ✅ 전체 유저 조회 (비밀번호 제외)
  async findAll() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        email: true,
        nickname: true,
        gender: true,
        birthDate: true,
        topic: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  // ✅ 유저 생성 (회원가입 시 사용)
  async create(data: {
    email: string;
    passwordHash: string;
    nickname: string;
  }) {
    return this.prisma.user.create({
      data: {
        email: data.email,
        passwordHash: data.passwordHash,
        nickname: data.nickname,
      },
      select: {
        id: true,
        email: true,
        nickname: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  // ✅ 특정 유저 조회
  async findOne(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        nickname: true,
        gender: true,
        birthDate: true,
        topic: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  // ✅ 내 프로필 업데이트
  async updateProfile(
    userId: string,
    data: {
      nickname?: string;
      gender?: string;
      birthDate?: Date;
      topic?: string;
    },
  ) {
    const parsedDate =
      data.birthDate &&
      typeof data.birthDate === 'string' &&
      !isNaN(Date.parse(data.birthDate))
        ? new Date(data.birthDate)
        : data.birthDate instanceof Date
          ? data.birthDate
          : undefined;

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        nickname: data.nickname,
        gender: data.gender,
        birthDate: parsedDate,
        topic: data.topic,
      },
      select: {
        id: true,
        email: true,
        nickname: true,
        gender: true,
        birthDate: true,
        topic: true,
        updatedAt: true,
      },
    });
  }
}
