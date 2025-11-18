import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  Req,
  UseGuards,
} from '@nestjs/common';
import { TalkPostService } from './talkpost.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TalksGateway } from './talks.gateway'; 

@UseGuards(JwtAuthGuard)
@Controller('talkposts')
export class TalkPostController {
  constructor(
    private readonly talkPostService: TalkPostService,
    private readonly talksGateway: TalksGateway, // 추가
  ) {}

  // 게시글 등록
  @Post()
  async create(@Body() body, @Req() req) {
    const post = await this.talkPostService.create(req.user.userId, body.title, body.content);
    this.talksGateway.server.emit('talkCreated', post); // 실시간 이벤트 emit
    return post;
  }

  // 전체 게시글 리스트
  @Get()
  list() {
    return this.talkPostService.list();
  }

  // 단일 게시글 조회
  @Get(':id')
  get(@Param('id') id: string) {
    return this.talkPostService.get(id);
  }

  // 게시글 삭제
  @Delete(':id')
  async delete(@Param('id') id: string, @Req() req) {
    const result = await this.talkPostService.delete(id, req.user.userId);
    this.talksGateway.server.emit('talkDeleted', { id }); // 실시간 이벤트 emit
    return result;
  }
}
