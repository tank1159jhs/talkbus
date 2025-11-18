import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { GroupsService } from './groups.service';
import { TalksGateway } from '../talks/talks.gateway';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateGroupDto } from './dto/create-group.dto';
import { SendGroupMessageDto } from './dto/send-group-message.dto';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';

@ApiTags('groups')
@ApiBearerAuth()
@Controller('groups')
export class GroupsController {
  constructor(
    private readonly groupsService: GroupsService,
    private readonly talksGateway: TalksGateway,
  ) {}

  // 공개: 그룹 목록
  @Get()
  list() {
    return this.groupsService.list();
  }

  // 로그인 필요: 그룹 생성 (생성자는 OWNER로 등록)
  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiOperation({ summary: '그룹방 생성' })
  @ApiResponse({ status: 201, description: '그룹방 생성 성공' })
  @ApiResponse({ status: 400, description: '입력값 오류' })
  create(@Body() body: CreateGroupDto, @Req() req) {
    return this.groupsService.create(req.user.userId, body.title);
  }

  // 로그인 필요: 그룹 메시지 전송 (그룹 히스토리에만 저장)
  @UseGuards(JwtAuthGuard)
  @Post(':id/messages')
  async send(
    @Param('id') groupId: string,
    @Body() body: SendGroupMessageDto,
    @Req() req,
  ) {
    const message = await this.groupsService.sendMessage(groupId, req.user.userId, body.body);
    // WebSocket으로 브로드캐스트
    if (this.talksGateway.server) {
      this.talksGateway.server.to(groupId).emit('newMessage', message);
    }
    return message;
  }

  // 로그인 필요: 그룹에 참가 (멤버로 등록)
  @UseGuards(JwtAuthGuard)
  @Post(':id/join')
  async join(@Param('id') groupId: string, @Req() req) {
    return this.groupsService.joinGroup(groupId, req.user.userId);
  }

  // 공개: 그룹 메시지 조회
  @Get(':id/messages')
  messages(@Param('id') groupId: string) {
    return this.groupsService.getMessages(groupId);
  }
}
