import {
  Controller,
  Get,
  Put,
  Body,
  Param,
  UseGuards,
  Req,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ✅ 특정 유저 프로필 조회 (공개)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  // ✅ 내 정보 조회 (로그인 필요)
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getMe(@Req() req) {
    return this.usersService.findOne(req.user.userId);
  }

  // ✅ 내 프로필 수정 (로그인 필요)
  @UseGuards(JwtAuthGuard)
  @Put('update-profile')
  updateProfile(
    @Req() req,
    @Body()
    body: {
      displayName?: string;
      gender?: string;
      birthDate?: Date;
      topic?: string;
    },
  ) {
    return this.usersService.updateProfile(req.user.userId, body);
  }
}
