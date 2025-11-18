import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { TalksService } from './talks.service';
import { TalksGateway } from './talks.gateway';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { StartTalkDto } from './dto/start-talk.dto';
import { CreateChatDto } from './dto/create-chat.dto';

@UseGuards(JwtAuthGuard)
@Controller('talks')
export class TalksController {
  constructor(
    private readonly talksService: TalksService,
    private readonly talksGateway: TalksGateway,
  ) {}

  // 내가 참여 중인 1:1 토크 목록
  @Get()
  list(@Req() req) {
    return this.talksService.listMyTalks(req.user.userId);
  }

  // 상대와 토크 시작 (이미 있으면 재사용). initialMessage를 넘기면 즉시 1:1 메시지 전송.
  @Post()
  async start(@Body() body: StartTalkDto, @Req() req) {
    const result = await this.talksService.startTalk(
      req.user.userId,
      body.otherUserId,
      body.initialMessage,
    );
    
    // WebSocket으로 브로드캐스트 (초기 메시지가 있으면)
    if (body.initialMessage && body.initialMessage.trim().length > 0 && this.talksGateway.server) {
      const message = await this.talksService.getChats(result.id, req.user.userId).then(msgs => msgs[msgs.length - 1]);
      this.talksGateway.server.to(result.id).emit('newMessage', message);
    }
    
    return result;
  }

  // 특정 토크의 메시지(Chats) 조회
  @Get(':id/chats')
  chats(@Param('id') talkId: string, @Req() req) {
    return this.talksService.getChats(talkId, req.user.userId);
  }

  // 특정 토크로 메시지 전송
  @Post(':id/chats')
  async send(@Param('id') talkId: string, @Body() body: CreateChatDto, @Req() req) {
    const message = await this.talksService.sendChat(talkId, req.user.userId, body.body);
    // WebSocket으로 브로드캐스트
    if (this.talksGateway.server) {
      this.talksGateway.server.to(talkId).emit('newMessage', message);
    }
    return message;
  }
}
