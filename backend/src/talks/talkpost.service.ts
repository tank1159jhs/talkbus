import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class TalkPostService {
  constructor(private prisma: PrismaService) {}

  // 게시글 등록
  async create(authorId: string, title: string, content: string) {
    return this.prisma.talkPost.create({
      data: { authorId, title, content },
    });
  }

  // 전체 게시글 리스트
  async list() {
    return this.prisma.talkPost.findMany({
      include: { author: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  // 단일 게시글 조회
  async get(id: string) {
    const post = await this.prisma.talkPost.findUnique({
      where: { id },
      include: { author: true },
    });
    if (!post) throw new NotFoundException('TalkPost not found');
    return post;
  }

  // 게시글 삭제 (본인 글만)
  async delete(id: string, userId: string) {
    const post = await this.prisma.talkPost.findUnique({ where: { id } });
    if (!post) throw new NotFoundException('TalkPost not found');
    if (post.authorId !== userId) throw new ForbiddenException('본인 글만 삭제할 수 있습니다');
    await this.prisma.talkPost.delete({ where: { id } });
    return { success: true };
  }
}
