import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  async list() {
    return this.prisma.groupRoom.findMany({
      include: {
        memberships: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(ownerId: string, title: string) {
    const groupRoom = await this.prisma.groupRoom.create({
      data: { title },
    });

    // 생성자를 OWNER로 등록
    await this.prisma.membership.create({
      data: {
        userId: ownerId,
        groupRoomId: groupRoom.id,
        role: 'OWNER',
      },
    });

    return groupRoom;
  }

  async ensureMember(groupRoomId: string, userId: string) {
    const found = await this.prisma.membership.findUnique({
      where: { userId_groupRoomId: { userId, groupRoomId } },
    });
    if (!found) {
      throw new ForbiddenException('Not a member of this group');
    }
  }

  async joinGroup(groupRoomId: string, userId: string) {
    // 그룹이 존재하는지 확인
    const groupRoom = await this.prisma.groupRoom.findUnique({
      where: { id: groupRoomId },
    });
    if (!groupRoom) throw new NotFoundException('Group not found');

    // 이미 멤버인지 확인
    const existingMember = await this.prisma.membership.findUnique({
      where: { userId_groupRoomId: { userId, groupRoomId } },
    });
    if (existingMember) {
      return existingMember; // 이미 멤버면 그냥 반환
    }

    // 새로운 멤버로 등록 (role: MEMBER)
    return this.prisma.membership.create({
      data: {
        userId,
        groupRoomId,
        role: 'MEMBER',
      },
    });
  }

  async sendMessage(groupRoomId: string, authorId: string, body: string) {
    // 멤버만 메시지 가능
    await this.ensureMember(groupRoomId, authorId);

    return this.prisma.groupMessage.create({
      data: { groupRoomId, authorId, body },
    });
  }

  async getMessages(groupRoomId: string) {
    const groupRoom = await this.prisma.groupRoom.findUnique({
      where: { id: groupRoomId },
    });
    if (!groupRoom) throw new NotFoundException('Group not found');

    return this.prisma.groupMessage.findMany({
      where: { groupRoomId },
      include: { author: true },
      orderBy: { createdAt: 'asc' },
    });
  }
}
