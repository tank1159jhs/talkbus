import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class TalksService {
  constructor(private prisma: PrismaService) {}

  async listMyTalks(userId: string) {
    return this.prisma.directRoom.findMany({
      where: {
        OR: [{ userAId: userId }, { userBId: userId }],
      },
      include: {
        userA: true,
        userB: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async ensureTalk(userId: string, otherUserId: string) {
    let directRoom = await this.prisma.directRoom.findFirst({
      where: {
        OR: [
          { userAId: userId, userBId: otherUserId },
          { userAId: otherUserId, userBId: userId },
        ],
      },
    });
    if (!directRoom) {
      directRoom = await this.prisma.directRoom.create({
        data: { userAId: userId, userBId: otherUserId },
      });
    }
    return directRoom;
  }

  async startTalk(
    userId: string,
    otherUserId: string,
    initialMessage?: string,
  ) {
    const directRoom = await this.ensureTalk(userId, otherUserId);

    if (initialMessage && initialMessage.trim().length > 0) {
      await this.prisma.directMessage.create({
        data: {
          directRoomId: directRoom.id,
          senderId: userId,
          body: initialMessage,
        },
      });
    }

    return directRoom;
  }

  async assertParticipant(directRoomId: string, userId: string) {
    const directRoom = await this.prisma.directRoom.findUnique({
      where: { id: directRoomId },
    });
    if (!directRoom) throw new NotFoundException('DirectRoom not found');
    if (directRoom.userAId !== userId && directRoom.userBId !== userId) {
      throw new ForbiddenException('Not a participant of this direct room');
    }
    return directRoom;
  }

  async getChats(directRoomId: string, userId: string) {
    await this.assertParticipant(directRoomId, userId);
    return this.prisma.directMessage.findMany({
      where: { directRoomId },
      include: { sender: true },
      orderBy: { createdAt: 'asc' },
    });
  }

  async sendChat(directRoomId: string, userId: string, body: string) {
    await this.assertParticipant(directRoomId, userId);
    return this.prisma.directMessage.create({
      data: {
        directRoomId,
        senderId: userId,
        body,
      },
    });
  }

  /**
   * WebSocket gateway용: 그룹/1:1 메시지 생성
   * roomId: 그룹방ID 또는 1:1 DirectRoomId
   * userId: 메시지 보낸 유저
   * content: 메시지 본문
   */
  async createMessage({
    roomId,
    userId,
    content,
  }: {
    roomId: string;
    userId: string;
    content: string;
  }) {
    // 그룹방 존재 여부 확인
    const groupRoom = await this.prisma.groupRoom.findUnique({
      where: { id: roomId },
    });
    if (groupRoom) {
      // 그룹 멤버십 체크
      const member = await this.prisma.membership.findFirst({
        where: { groupRoomId: roomId, userId },
      });
      if (!member) throw new ForbiddenException('Not a group member');
      // 메시지 저장
      return this.prisma.groupMessage.create({
        data: {
          groupRoomId: roomId,
          authorId: userId,
          body: content,
        },
        include: { author: true },
      });
    }
    // 1:1 DirectRoom 존재 여부 확인
    const directRoom = await this.prisma.directRoom.findUnique({
      where: { id: roomId },
    });
    if (directRoom) {
      if (directRoom.userAId !== userId && directRoom.userBId !== userId) {
        throw new ForbiddenException('Not a participant of this direct room');
      }
      // 메시지 저장
      return this.prisma.directMessage.create({
        data: {
          directRoomId: roomId,
          senderId: userId,
          body: content,
        },
        include: { sender: true },
      });
    }
    throw new NotFoundException('Room not found');
  }
}
